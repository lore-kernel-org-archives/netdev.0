From: domen@coderock.org
Subject: [patch 22/26] drivers/net/tulip/*: convert to pci_register_driver
Date: Sun, 06 Mar 2005 11:33:50 +0100
Message-ID: <20050306103350.A40731F1F0@trashy.coderock.org>
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


 kj-domen/drivers/net/tulip/de2104x.c         |    2 +-
 kj-domen/drivers/net/tulip/de4x5.c           |    2 +-
 kj-domen/drivers/net/tulip/dmfe.c            |    2 +-
 kj-domen/drivers/net/tulip/tulip_core.c      |    2 +-
 kj-domen/drivers/net/tulip/winbond-840.c     |    2 +-
 kj-domen/drivers/net/tulip/xircom_tulip_cb.c |    2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff -puN drivers/net/tulip/de2104x.c~pci_register_driver-drivers_net_tulip drivers/net/tulip/de2104x.c
--- kj/drivers/net/tulip/de2104x.c~pci_register_driver-drivers_net_tulip	2005-03-05 16:12:39.000000000 +0100
+++ kj-domen/drivers/net/tulip/de2104x.c	2005-03-05 16:12:39.000000000 +0100
@@ -2175,7 +2175,7 @@ static int __init de_init (void)
 #ifdef MODULE
 	printk("%s", version);
 #endif
-	return pci_module_init (&de_driver);
+	return pci_register_driver (&de_driver);
 }
 
 static void __exit de_exit (void)
diff -puN drivers/net/tulip/de4x5.c~pci_register_driver-drivers_net_tulip drivers/net/tulip/de4x5.c
--- kj/drivers/net/tulip/de4x5.c~pci_register_driver-drivers_net_tulip	2005-03-05 16:12:39.000000000 +0100
+++ kj-domen/drivers/net/tulip/de4x5.c	2005-03-05 16:12:39.000000000 +0100
@@ -5754,7 +5754,7 @@ static int __init de4x5_module_init (voi
 	int err = 0;
 
 #ifdef CONFIG_PCI
-	err = pci_module_init (&de4x5_pci_driver);
+	err = pci_register_driver(&de4x5_pci_driver);
 #endif
 #ifdef CONFIG_EISA
 	err |= eisa_driver_register (&de4x5_eisa_driver);
diff -puN drivers/net/tulip/dmfe.c~pci_register_driver-drivers_net_tulip drivers/net/tulip/dmfe.c
--- kj/drivers/net/tulip/dmfe.c~pci_register_driver-drivers_net_tulip	2005-03-05 16:12:39.000000000 +0100
+++ kj-domen/drivers/net/tulip/dmfe.c	2005-03-05 16:12:39.000000000 +0100
@@ -2042,7 +2042,7 @@ static int __init dmfe_init_module(void)
 	if (HPNA_NoiseFloor > 15)
 		HPNA_NoiseFloor = 0;
 
-	rc = pci_module_init(&dmfe_driver);
+	rc = pci_register_driver(&dmfe_driver);
 	if (rc < 0)
 		return rc;
 
diff -puN drivers/net/tulip/tulip_core.c~pci_register_driver-drivers_net_tulip drivers/net/tulip/tulip_core.c
--- kj/drivers/net/tulip/tulip_core.c~pci_register_driver-drivers_net_tulip	2005-03-05 16:12:39.000000000 +0100
+++ kj-domen/drivers/net/tulip/tulip_core.c	2005-03-05 16:12:39.000000000 +0100
@@ -1844,7 +1844,7 @@ static int __init tulip_init (void)
 	tulip_max_interrupt_work = max_interrupt_work;
 
 	/* probe for and init boards */
-	return pci_module_init (&tulip_driver);
+	return pci_register_driver (&tulip_driver);
 }
 
 
diff -puN drivers/net/tulip/winbond-840.c~pci_register_driver-drivers_net_tulip drivers/net/tulip/winbond-840.c
--- kj/drivers/net/tulip/winbond-840.c~pci_register_driver-drivers_net_tulip	2005-03-05 16:12:39.000000000 +0100
+++ kj-domen/drivers/net/tulip/winbond-840.c	2005-03-05 16:12:39.000000000 +0100
@@ -1704,7 +1704,7 @@ static struct pci_driver w840_driver = {
 static int __init w840_init(void)
 {
 	printk(version);
-	return pci_module_init(&w840_driver);
+	return pci_register_driver(&w840_driver);
 }
 
 static void __exit w840_exit(void)
diff -puN drivers/net/tulip/xircom_tulip_cb.c~pci_register_driver-drivers_net_tulip drivers/net/tulip/xircom_tulip_cb.c
--- kj/drivers/net/tulip/xircom_tulip_cb.c~pci_register_driver-drivers_net_tulip	2005-03-05 16:12:39.000000000 +0100
+++ kj-domen/drivers/net/tulip/xircom_tulip_cb.c	2005-03-05 16:12:39.000000000 +0100
@@ -1727,7 +1727,7 @@ static int __init xircom_init(void)
 #ifdef MODULE
 	printk(version);
 #endif
-	return pci_module_init(&xircom_driver);
+	return pci_register_driver(&xircom_driver);
 }
 
 
_
