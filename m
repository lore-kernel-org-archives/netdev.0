From: domen@coderock.org
Subject: [patch 25/26] drivers/net/wireless/*: convert to pci_register_driver
Date: Sun, 06 Mar 2005 11:34:00 +0100
Message-ID: <20050306103400.B58BC1F23B@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, c.lucas@ifrance.com
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


convert from pci_module_init to pci_register_driver
(from:http://kerneljanitors.org/TODO).

Signed-off-by: Christophe Lucas <c.lucas@ifrance.com>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/wireless/atmel_pci.c   |    2 +-
 kj-domen/drivers/net/wireless/orinoco_pci.c |    2 +-
 kj-domen/drivers/net/wireless/orinoco_plx.c |    2 +-
 kj-domen/drivers/net/wireless/orinoco_tmd.c |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff -puN drivers/net/wireless/atmel_pci.c~pci_register_driver-drivers_net_wireless drivers/net/wireless/atmel_pci.c
--- kj/drivers/net/wireless/atmel_pci.c~pci_register_driver-drivers_net_wireless	2005-03-05 16:12:43.000000000 +0100
+++ kj-domen/drivers/net/wireless/atmel_pci.c	2005-03-05 16:12:43.000000000 +0100
@@ -79,7 +79,7 @@ static void __devexit atmel_pci_remove(s
 
 static int __init atmel_init_module(void)
 {
-	return pci_module_init(&atmel_driver);
+	return pci_register_driver(&atmel_driver);
 }
 
 static void __exit atmel_cleanup_module(void)
diff -puN drivers/net/wireless/orinoco_pci.c~pci_register_driver-drivers_net_wireless drivers/net/wireless/orinoco_pci.c
--- kj/drivers/net/wireless/orinoco_pci.c~pci_register_driver-drivers_net_wireless	2005-03-05 16:12:43.000000000 +0100
+++ kj-domen/drivers/net/wireless/orinoco_pci.c	2005-03-05 16:12:43.000000000 +0100
@@ -393,7 +393,7 @@ MODULE_LICENSE("Dual MPL/GPL");
 static int __init orinoco_pci_init(void)
 {
 	printk(KERN_DEBUG "%s\n", version);
-	return pci_module_init(&orinoco_pci_driver);
+	return pci_register_driver(&orinoco_pci_driver);
 }
 
 static void __exit orinoco_pci_exit(void)
diff -puN drivers/net/wireless/orinoco_plx.c~pci_register_driver-drivers_net_wireless drivers/net/wireless/orinoco_plx.c
--- kj/drivers/net/wireless/orinoco_plx.c~pci_register_driver-drivers_net_wireless	2005-03-05 16:12:43.000000000 +0100
+++ kj-domen/drivers/net/wireless/orinoco_plx.c	2005-03-05 16:12:43.000000000 +0100
@@ -347,7 +347,7 @@ MODULE_LICENSE("Dual MPL/GPL");
 static int __init orinoco_plx_init(void)
 {
 	printk(KERN_DEBUG "%s\n", version);
-	return pci_module_init(&orinoco_plx_driver);
+	return pci_register_driver(&orinoco_plx_driver);
 }
 
 static void __exit orinoco_plx_exit(void)
diff -puN drivers/net/wireless/orinoco_tmd.c~pci_register_driver-drivers_net_wireless drivers/net/wireless/orinoco_tmd.c
--- kj/drivers/net/wireless/orinoco_tmd.c~pci_register_driver-drivers_net_wireless	2005-03-05 16:12:43.000000000 +0100
+++ kj-domen/drivers/net/wireless/orinoco_tmd.c	2005-03-05 16:12:43.000000000 +0100
@@ -213,7 +213,7 @@ MODULE_LICENSE("Dual MPL/GPL");
 static int __init orinoco_tmd_init(void)
 {
 	printk(KERN_DEBUG "%s\n", version);
-	return pci_module_init(&orinoco_tmd_driver);
+	return pci_register_driver(&orinoco_tmd_driver);
 }
 
 static void __exit orinoco_tmd_exit(void)
_
