create database quanlybanhang;
use quanlybanhang ;

create table Customers(
	Customer_id int auto_increment primary key ,
    Customer_name varchar(100) not null ,
    phone varchar(20) not null unique,
    address varchar(255) 
);

create table products (
	product_id int auto_increment primary key ,
    product_name varchar(100) not null unique,
    price decimal(10,2),
    quantity int not null check(quantity > 0 ),
    category varchar(50)
);

create table employees (
	employee_id int auto_increment primary key ,
    employee_name varchar(100) not null ,
    birthday date ,
    position varchar(50) not null,
    salary decimal(10,2),
    revenue decimal(10,2) default  0
);

create table Orders (
	order_id int auto_increment primary key ,
    Customer_id int ,
    employee_id int ,
    order_date datetime default current_timestamp,
    total_mount decimal(10,2),
    foreign key (Customer_id) references customers(Customer_id),
    foreign key (employee_id) references employees(employee_id)
);

create table OrderDetails(
	order_detail_id int auto_increment primary key ,
    order_id int ,
    product_id  int ,
    quantity int not null check (quantity >0),
    unit_price decimal(10,2) not null ,
    foreign key (order_id) references Orders(order_id),
    foreign key (product_id) references products(product_id)
);

-- câu 3
alter table Customers add column email varchar(100);
alter table employees drop column birthday;

-- câu 4 
INSERT INTO Customers (Customer_name, email, phone, address) VALUES
('Nguyễn Văn A','nguyenvana@gmail.com', '0987654321', 'Hà Nội'),
('Trần Thị B','tranthib@gmail.com', '0976543210', 'Hồ Chí Minh'),
('Lê Văn C','levanc@gmail.com', '0965432109', 'Đà Nẵng'),
('Phạm Thị D', 'phamthid@gmail.com','0954321098', 'Hải Phòng'),
('Hoàng Văn E', 'hoangvane@hmail.com ', '0943210987', 'Cần Thơ');

INSERT INTO Products (product_name, price, quantity, category) VALUES
('Laptop Dell', 20000000.00, 10, 'Electronics'),
('Điện thoại iPhone', 25000000.00, 15, 'Electronics'),
('Máy giặt LG', 7000000.00, 8, 'Home Appliances'),
('Tivi Samsung', 15000000.00, 12, 'Electronics'),
('Tủ lạnh Panasonic', 12000000.00, 5, 'Home Appliances');

INSERT INTO Employees (employee_name,  position, salary, revenue) VALUES
('Nguyễn Văn X', 'Nhân viên bán hàng', 12000000.00, 5000000.00),
('Trần Thị Y', 'Quản lý', 20000000.00, 10000000.00),
('Lê Văn Z', 'Nhân viên kho', 10000000.00, 3000000.00),
('Phạm Thị K', 'Nhân viên tư vấn', 13000000.00, 7000000.00),
('Hoàng Văn M', 'Nhân viên bảo trì', 11000000.00, 4000000.00);


INSERT INTO Orders (Customer_id, employee_id, order_date, total_mount) VALUES
(1, 1, '2025-02-01 10:30:00', 45000000.00),
(2, 2, '2025-02-02 15:45:00', 7000000.00),
(3, 3, '2025-02-03 09:20:00', 25000000.00),
(4, 4, '2025-02-04 18:10:00', 12000000.00),
(5, 5, '2025-02-05 13:00:00', 15000000.00);

INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 2, 20000000.00),
(1, 2, 1, 25000000.00),
(2, 3, 1, 7000000.00),
(3, 2, 1, 25000000.00),
(4, 5, 1, 12000000.00),
(5, 4, 1, 15000000.00);

-- câu 5 
select customer_id , customer_name , phone ,address from customers ;
 
update products 
set product_name = 'Laptop Dell XPS' and price =99.99
where product_id = 1;

select od.product_id , c.customer_name , e.employee_name , o.total_mount ,o.order_date
from  orders o 
join OrderDetails od on o.order_id = od.order_id
join  customers c on c.Customer_id = o.Customer_id
join employees e on e.employee_id = o.employee_id;

-- câu 6 
select c.customer_id , c.customer_name , count(o.order_id)
from  orders o 
join  customers c on c.Customer_id = o.Customer_id
group by c.customer_id;

select employee_id,employee_name, revenue
from employees ;

select p.product_id ,p.product_name,(p.quantity - od.quantity) as total_product
from products p 
join OrderDetails od on p.product_id = od.product_id
where (p.quantity - od.quantity) > 100 
order by total_product desc; 

-- câu 7
	
select customer_id, customer_name
from customers
where customer_id not in (select distinct customer_id from orders);

SELECT product_name 
FROM products 
WHERE price > (SELECT AVG(price) FROM products);

select customers.customer_id, customers.customer_name, sum(orders.total_amount) as total_spent
from orders
join customers on orders.customer_id = customers.customer_id
group by customers.customer_id, customers.customer_name
having total_spent = (select max(total_spent) from (select sum(total_amount) as total_spent from orders group by customer_id) as temp);

-- câu 8 
create view view_order_list
as select od.product_id , c.customer_name , e.employee_name , o.total_mount ,o.order_date
from  orders o 
join OrderDetails od on o.order_id = od.order_id
join  customers c on c.Customer_id = o.Customer_id
join employees e on e.employee_id = o.employee_id;

create view view_order_detail_product 
as select od.order_detail_id , p.product_name , od.quantity, od.unit_price
from products p 
join OrderDetails od on p.product_id = od.product_id ;

delimiter //
create procedure proc_insert_employee(
    in p_employee_name varchar(100),
    in p_position varchar(50),
    in p_salary decimal(10,2)
)
begin
    insert into employees(employee_name, position, salary) 
    values (p_employee_name, p_position, p_salary);
    
    select last_insert_id() as employee_id;
end //
delimiter ;

delimiter //
create procedure proc_get_orderdetails(
    in p_order_id int
)
begin
    select * from orderdetails where order_id = p_order_id;
end //
delimiter ;

delimiter //
	create procedure proc_cal_total_amount_by_order( od_id_in int )
    begin
		select quantity
        from OrderDetails
        where order_detail_id = od_id_in;
    end;
// delimiter ; 

-- câu 10

delimiter // 
	create trigger trigger_after_insert_order_details
    after insert on OrderDetails
    for each row
    begin
		if(select quantity from products where productid = new.product_id) < new.quantity then 
			SIGNAL SQLSTATE '45000' 
			SET MESSAGE_TEXT = 'Số lượng sản phẩm trong kho không đủ ';
        else 	
			update OrderDetails
            set quantity = quantity - new.quantity
            where productid = new.product_id;
        end if;
    end;
// delimiter ;

-- câu 11

delimiter //
create procedure proc_insert_order_details(
    in p_order_id int,
    in p_product_id int,
    in p_quantity int,
    in p_unit_price decimal(10,2)
)
begin
    declare v_order_exists int;
 
    select count(*) into v_order_exists 
    from orders 
    where order_id = p_order_id;
    
    if v_order_exists = 0 then
        signal sqlstate '45000' 
        set message_text = 'không tồn tại mã hóa đơn';
    end if;

    start transaction;

    insert into orderdetails(order_id, product_id, quantity, unit_price)
    values (p_order_id, p_product_id, p_quantity, p_unit_price);

    update orders 
    set total_amount = (
        select sum(quantity * unit_price) 
        from orderdetails 
        where order_id = p_order_id
    ) 
    where order_id = p_order_id;

    commit;
end //
delimiter ;

