From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 13/16] Host AP: pci_register_driver() return value changes
Date: Sat, 13 Nov 2004 21:22:56 -0800
Message-ID: <20041114052256.GE14810@jm.kir.nu>
References: <20041108070156.GA1076@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041108070156.GA1076@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Changed pci_register_driver() calls to match with the new behavior
in Linux 2.6.10-rc1.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


diff -Nru a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
--- a/drivers/net/wireless/hostap/hostap_pci.c	2004-11-13 20:56:25 -08:00
+++ b/drivers/net/wireless/hostap/hostap_pci.c	2004-11-13 20:56:25 -08:00
@@ -414,14 +414,7 @@
 {
 	printk(KERN_INFO "%s: %s\n", dev_info, version);
 
-	if (pci_register_driver(&prism2_pci_drv_id) <= 0) {
-		printk("hostap_pci: No devices found, driver not "
-		       "installed.\n");
-		pci_unregister_driver(&prism2_pci_drv_id);
-		return -ENODEV;
-	}
-
-	return 0;
+	return pci_register_driver(&prism2_pci_drv_id);
 }
 
 
diff -Nru a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
--- a/drivers/net/wireless/hostap/hostap_plx.c	2004-11-13 20:56:25 -08:00
+++ b/drivers/net/wireless/hostap/hostap_plx.c	2004-11-13 20:56:25 -08:00
@@ -575,14 +575,7 @@
 {
 	printk(KERN_INFO "%s: %s\n", dev_info, version);
 
-	if (pci_register_driver(&prism2_plx_drv_id) <= 0) {
-		printk("hostap_plx: No devices found, driver not "
-		       "installed.\n");
-		pci_unregister_driver(&prism2_plx_drv_id);
-		return -ENODEV;
-	}
-
-	return 0;
+	return pci_register_driver(&prism2_plx_drv_id);
 }
 
 

-- 
Jouni Malinen                                            PGP id EFC895FA
