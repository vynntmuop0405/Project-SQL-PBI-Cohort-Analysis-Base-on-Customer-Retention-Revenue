-- Select cohorn year, in this analyst, we will choose the year 2018
WITH 
t0 AS  
(  SELECT  *
            , EXTRACT(YEAR FROM `order_date`) AS order_year
    FROM `superstoresales-411507.superstoresales.superstoresales`
    WHERE EXTRACT(YEAR FROM `order_date`) = 2017
),
-- Now we select what columns we need
t1 AS 
(   SELECT `order_id`,`order_date`,`customer_id`,`sales`, FORMAT_DATE('%Y-%m-01',`order_date`) AS order_month
    FROM t0
)
-- SELECT * FROM t1
-- Find the cohort_month (first month customer purchased)
, t2 AS
(   SELECT customer_id, MIN(`order_month`) AS cohort_month
    FROM t1
    GROUP BY `customer_id`
)
-- SELECT * FROM t2
-- Find the cohort_index by order_month - cohort_month, remember to +1 (cohort_index: number of months the customers still purchased at store)
, t3 AS 
(   SELECT t1.*, t2.cohort_month, DATE_DIFF(CAST(t1.order_month AS datetime), CAST(t2.cohort_month AS datetime), MONTH)+1 AS cohort_index
    FROM t1
    JOIN t2 ON t1.customer_id = t2.customer_id
)
-- SELECT * FROM t3
-- Count number of customer in each month
, t4 AS 
(   SELECT `cohort_month`,`order_month`,`cohort_index`, COUNT(DISTINCT `customer_id`) AS count_customerid
    FROM t3
    GROUP BY `order_month`,`cohort_month`,`cohort_index`
    ORDER BY `cohort_month`
)
-- SELECT * FROM t4
-- NEW: Create t4 for Cohort based on Sum Sales (Money Spent by cohort customer)
, t4_2 AS
(   SELECT `cohort_month`,`order_month`,`cohort_index`, SUM(`Sales`) AS total_sales
    FROM t3
    GROUP BY `order_month`,`cohort_month`,`cohort_index`
    ORDER BY `cohort_month`
)
-- SELECT * FROM t4_2
-- NEW: Create t5 as a pivot table and  it to show the percentage
, t5 AS
(   SELECT *
    FROM 
    (
      SELECT `cohort_month`,`cohort_index`,`count_customerid`
      FROM t4
    ) AS p
    PIVOT ( SUM(`count_customerid`)
            FOR `cohort_index` IN (1 AS `1`,2 `2`,3`3`,4`4`,5`5`,6`6`,7`7`,8`8`,9`9`,10`10`,11`11`,12`12`)
    ) AS piv
    ORDER BY `cohort_month`
)
-- SELECT * FROM t5
-- Now change to percentage
SELECT  `cohort_month`,
        ROUND(1.0* `1`/`1`, 2) AS `1`
        , ROUND(1.0* `2`/`1`, 2) AS `2`
        , ROUND(1.0* `3`/`1`, 2) AS `3`
        , ROUND(1.0* `4`/`1`, 2) AS `4`
        , ROUND(1.0* `5`/`1`, 2) AS `5`
        , ROUND(1.0* `6`/`1`, 2) AS `6`
        , ROUND(1.0* `7`/`1`, 2) AS `7`
        , ROUND(1.0* `8`/`1`, 2) AS `8`
        , ROUND(1.0* `9`/`1`, 2) AS `9`
        , ROUND(1.0* `10`/`1`, 2) AS `10`
        , ROUND(1.0* `11`/`1`, 2) AS `11`
        , ROUND(1.0* `12`/`1`, 2) AS `12`
FROM t5


