From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 3 of 5][ATM]: [nicstar] small cleanup for some globals
Date: Wed, 26 Jan 2005 11:57:29 -0500
Message-ID: <200501261657.j0QGvSuw018864@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/25 09:29:05-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [nicstar] small cleanup for some globals
#   
#     Signed-off-by: Adrian Bunk <bunk@stusta.de>
#     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/nicstarmac.c
#   2005/01/25 09:28:46-05:00 chas@relax.cmf.nrl.navy.mil +4 -2
#   [ATM]: [nicstar] small cleanup for some globals
#   
#     Signed-off-by: Adrian Bunk <bunk@stusta.de>
#     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/nicstar.c
#   2005/01/25 09:28:46-05:00 chas@relax.cmf.nrl.navy.mil +0 -1
#   [ATM]: [nicstar] small cleanup for some globals
#   
#     Signed-off-by: Adrian Bunk <bunk@stusta.de>
#     Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# BitKeeper/deleted/.del-nicstarmac.h~194ffda535e62654
#   2005/01/25 09:27:38-05:00 chas@relax.cmf.nrl.navy.mil +0 -0
#   Delete: drivers/atm/nicstarmac.h
# 
diff -Nru a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
--- a/drivers/atm/nicstar.c	2005-01-25 09:38:21 -05:00
+++ b/drivers/atm/nicstar.c	2005-01-25 09:38:21 -05:00
@@ -54,7 +54,6 @@
 #include <asm/uaccess.h>
 #include <asm/atomic.h>
 #include "nicstar.h"
-#include "nicstarmac.h"
 #ifdef CONFIG_ATM_NICSTAR_USE_SUNI
 #include "suni.h"
 #endif /* CONFIG_ATM_NICSTAR_USE_SUNI */
diff -Nru a/drivers/atm/nicstarmac.c b/drivers/atm/nicstarmac.c
--- a/drivers/atm/nicstarmac.c	2005-01-25 09:38:21 -05:00
+++ b/drivers/atm/nicstarmac.c	2005-01-25 09:38:21 -05:00
@@ -7,6 +7,8 @@
  * Read this ForeRunner's MAC address from eprom/eeprom
  */
 
+typedef void __iomem *virt_addr_t;
+
 #define CYCLE_DELAY 5
 
 /* This was the original definition
@@ -213,7 +215,7 @@
 }
 
 
-void
+static void
 nicstar_init_eprom( virt_addr_t base )
 {
     u_int32_t val;
@@ -246,7 +248,7 @@
  * above.
  */ 
 
-void
+static void
 nicstar_read_eprom(
     virt_addr_t	base,
     u_int8_t	prom_offset,
diff -Nru a/drivers/atm/nicstarmac.h b/drivers/atm/nicstarmac.h
--- a/drivers/atm/nicstarmac.h	2005-01-25 09:38:21 -05:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,13 +0,0 @@
-/******************************************************************************
- *
- * nicstarmac.h
- *
- * Header file for nicstarmac.c
- *
- ******************************************************************************/
-
-
-typedef void __iomem *virt_addr_t;
-
-void nicstar_init_eprom( virt_addr_t base );
-void nicstar_read_eprom( virt_addr_t, u_int8_t, u_int8_t *, u_int32_t);
