From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4 1/3] tg3: use module_param
Date: Fri, 15 Oct 2004 13:44:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015134452.08fccaf8@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

get rid of deprecated use of MODULE_PARM

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c	2004-10-15 12:19:54 -07:00
+++ b/drivers/net/tg3.c	2004-10-15 12:19:54 -07:00
@@ -12,7 +12,7 @@
 #include <linux/config.h>
 
 #include <linux/module.h>
-
+#include <linux/moduleparam.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/compiler.h>
@@ -141,10 +141,10 @@
 MODULE_AUTHOR("David S. Miller (davem@redhat.com) and Jeff Garzik (jgarzik@pobox.com)");
 MODULE_DESCRIPTION("Broadcom Tigon3 ethernet driver");
 MODULE_LICENSE("GPL");
-MODULE_PARM(tg3_debug, "i");
-MODULE_PARM_DESC(tg3_debug, "Tigon3 bitmapped debugging message enable value");
 
 static int tg3_debug = -1;	/* -1 == use TG3_DEF_MSG_ENABLE as value */
+module_param(tg3_debug, int, 0);
+MODULE_PARM_DESC(tg3_debug, "Tigon3 bitmapped debugging message enable value");
 
 static struct pci_device_id tg3_pci_tbl[] = {
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5700,
