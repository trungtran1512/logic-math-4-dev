# module CsvImporter
module CsvImporter
  def read_file(file_csv)
    file      = File.open(file_csv)
    file.readlines.map.with_index do |line, index|
      next if index == 0
      line.split(',').map(&:strip)
    end.compact
  rescue
    []
  end
end

# TaxService
class TaxService
  include CsvImporter

  NO_TAX          = 0
  BASIC_SALES_TAX = 0.1
  IMPORT_DUTY_TAX = 0.05
  PRODUCTS_EXEMPT = %w(book chocolate pills).freeze

  def initialize(quantity, product, price)
    @quantity = quantity
    @product  = product
    @price    = price
  end

  def tax_cal
    basic_sales_tax = products_exempt? ? NO_TAX : BASIC_SALES_TAX
    import_duty_tax = imported_duty_tax? ? IMPORT_DUTY_TAX : NO_TAX
    return tax = basic_sales_tax + import_duty_tax
  end

  def products_exempt?
    PRODUCTS_EXEMPT.any? { |p_e| @product.include?(p_e) }
  end

  def imported_duty_tax?
    @product.start_with?('imported')
  end

  def price_includes_tax
    price = @price.to_f
    rounded_tax = rounded_val(price * tax_cal)
    return price_tax = (price + rounded_tax).round(2)
  end

  def line_item
    "#{@quantity}, #{@product}, #{price_includes_tax}"
  end

  def sale_tax
    rounded_val(@price.to_f * tax_cal)
  end

  private

  def rounded_val(value)
    (value * 20).ceil / 20.0
  end
end

# Output Data
class OutputData
  include CsvImporter

  def main(datas)
    return unless datas

    totals = 0
    sales_tax = 0

    datas.map do |data|
      quantity = data[0]
      product  = data[1]
      price    = data[2]
      tax = TaxService.new(quantity, product, price)

      puts tax.line_item

      sales_tax += tax.sale_tax
      totals += tax.price_includes_tax
    end

    puts "Sales Taxes: #{sales_tax.round(2)}"
    puts "Total: #{totals.round(2)}"
  end
end

out_data = OutputData.new

datas_1 = out_data.read_file('csv/input_01.csv')
datas_2 = out_data.read_file('csv/input_02.csv')
datas_3 = out_data.read_file('csv/input_03.csv')

puts 'Output 1'
puts out_data.main(datas_1)
puts '--------------------'
puts 'Output 2'
puts out_data.main(datas_2)
puts '--------------------'
puts 'Output 3'
puts out_data.main(datas_3)
puts '--------------------'
