From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4 1/3] ns83820: use module_param
Date: Fri, 15 Oct 2004 15:40:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015154006.432602a6@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replace MODULE_PARM with module_param

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/drivers/net/ns83820.c b/drivers/net/ns83820.c
--- a/drivers/net/ns83820.c	2004-10-15 15:05:25 -07:00
+++ b/drivers/net/ns83820.c	2004-10-15 15:05:25 -07:00
@@ -96,6 +96,7 @@
 
 #include <linux/config.h>
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/types.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
@@ -119,7 +120,7 @@
 
 #define DRV_NAME "ns83820"
 
-/* Global parameters.  See MODULE_PARM near the bottom. */
+/* Global parameters.  See module_param near the bottom. */
 static int ihr = 2;
 static int reset_phy = 0;
 static int lnksts = 0;		/* CFG_LNKSTS bit polarity */
@@ -2209,13 +2210,13 @@
 
 MODULE_DEVICE_TABLE(pci, ns83820_pci_tbl);
 
-MODULE_PARM(lnksts, "i");
+module_param(lnksts, int, 0);
 MODULE_PARM_DESC(lnksts, "Polarity of LNKSTS bit");
 
-MODULE_PARM(ihr, "i");
+module_param(ihr, int, 0);
 MODULE_PARM_DESC(ihr, "Time in 100 us increments to delay interrupts (range 0-127)");
 
-MODULE_PARM(reset_phy, "i");
+module_param(reset_phy, int, 0);
 MODULE_PARM_DESC(reset_phy, "Set to 1 to reset the PHY on startup");
 
 module_init(ns83820_init);
