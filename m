From: maximilian attems <janitor@sternwelten.at>
Subject: [patch] prism54 remove unused macro
Date: Fri, 3 Sep 2004 08:46:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040903064651.GB1856@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

the TRACE macro was noticed because of it's string concatenation.
this patch removes it as it's unused.

Signed-off-by: Maximilian Attems <janitor@sternwelten.at>


--- linux-2.6.9-rc1-bk7-orig/drivers/net/wireless/prism54/islpci_mgt.h	2004-08-14 12:54:51.000000000 +0200
+++ linux-2.6.9-rc1-bk7/drivers/net/wireless/prism54/islpci_mgt.h	2004-09-03 08:35:30.000000000 +0200
@@ -31,8 +31,6 @@
 #define K_DEBUG(f, m, args...) do { if(f & m) printk(KERN_DEBUG args); } while(0)
 #define DEBUG(f, args...) K_DEBUG(f, pc_debug, args)
 
-#define TRACE(devname)   K_DEBUG(SHOW_TRACING, VERBOSE, "%s:  -> " __FUNCTION__ "()\n", devname)
-
 extern int pc_debug;
 #define init_wds 0	/* help compiler optimize away dead code */
 
--- linux-2.6.9-rc1-bk7-orig/drivers/net/wireless/prism54/islpci_hotplug.c	2004-08-14 12:55:32.000000000 +0200
+++ linux-2.6.9-rc1-bk7/drivers/net/wireless/prism54/islpci_hotplug.c	2004-09-03 08:35:45.000000000 +0200
@@ -107,8 +107,6 @@ prism54_probe(struct pci_dev *pdev, cons
 	islpci_private *priv;
 	int rvalue;
 
-	/* TRACE(DRV_NAME); */
-	
 	
 	/* Enable the pci device */
 	if (pci_enable_device(pdev)) {
