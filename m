From: domen@coderock.org
Subject: [patch 23/26] drivers/net/wan/*: convert to pci_register_driver
Date: Sun, 06 Mar 2005 11:33:53 +0100
Message-ID: <20050306103354.3D0BD1F204@trashy.coderock.org>
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


 kj-domen/drivers/net/wan/dscc4.c     |    2 +-
 kj-domen/drivers/net/wan/farsync.c   |    2 +-
 kj-domen/drivers/net/wan/pc300_drv.c |    2 +-
 kj-domen/drivers/net/wan/pci200syn.c |    2 +-
 kj-domen/drivers/net/wan/wanxl.c     |    2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff -puN drivers/net/wan/dscc4.c~pci_register_driver-drivers_net_wan drivers/net/wan/dscc4.c
--- kj/drivers/net/wan/dscc4.c~pci_register_driver-drivers_net_wan	2005-03-05 16:12:41.000000000 +0100
+++ kj-domen/drivers/net/wan/dscc4.c	2005-03-05 16:12:41.000000000 +0100
@@ -2062,7 +2062,7 @@ static struct pci_driver dscc4_driver = 
 
 static int __init dscc4_init_module(void)
 {
-	return pci_module_init(&dscc4_driver);
+	return pci_register_driver(&dscc4_driver);
 }
 
 static void __exit dscc4_cleanup_module(void)
diff -puN drivers/net/wan/farsync.c~pci_register_driver-drivers_net_wan drivers/net/wan/farsync.c
--- kj/drivers/net/wan/farsync.c~pci_register_driver-drivers_net_wan	2005-03-05 16:12:41.000000000 +0100
+++ kj-domen/drivers/net/wan/farsync.c	2005-03-05 16:12:41.000000000 +0100
@@ -2699,7 +2699,7 @@ fst_init(void)
 	for (i = 0; i < FST_MAX_CARDS; i++)
 		fst_card_array[i] = NULL;
 	spin_lock_init(&fst_work_q_lock);
-	return pci_module_init(&fst_driver);
+	return pci_register_driver(&fst_driver);
 }
 
 static void __exit
diff -puN drivers/net/wan/pc300_drv.c~pci_register_driver-drivers_net_wan drivers/net/wan/pc300_drv.c
--- kj/drivers/net/wan/pc300_drv.c~pci_register_driver-drivers_net_wan	2005-03-05 16:12:41.000000000 +0100
+++ kj-domen/drivers/net/wan/pc300_drv.c	2005-03-05 16:12:41.000000000 +0100
@@ -3674,7 +3674,7 @@ static struct pci_driver cpc_driver = {
 
 static int __init cpc_init(void)
 {
-	return pci_module_init(&cpc_driver);
+	return pci_register_driver(&cpc_driver);
 }
 
 static void __exit cpc_cleanup_module(void)
diff -puN drivers/net/wan/pci200syn.c~pci_register_driver-drivers_net_wan drivers/net/wan/pci200syn.c
--- kj/drivers/net/wan/pci200syn.c~pci_register_driver-drivers_net_wan	2005-03-05 16:12:41.000000000 +0100
+++ kj-domen/drivers/net/wan/pci200syn.c	2005-03-05 16:12:41.000000000 +0100
@@ -468,7 +468,7 @@ static int __init pci200_init_module(voi
 		printk(KERN_ERR "pci200syn: Invalid PCI clock frequency\n");
 		return -EINVAL;
 	}
-	return pci_module_init(&pci200_pci_driver);
+	return pci_register_driver(&pci200_pci_driver);
 }
 
 
diff -puN drivers/net/wan/wanxl.c~pci_register_driver-drivers_net_wan drivers/net/wan/wanxl.c
--- kj/drivers/net/wan/wanxl.c~pci_register_driver-drivers_net_wan	2005-03-05 16:12:41.000000000 +0100
+++ kj-domen/drivers/net/wan/wanxl.c	2005-03-05 16:12:41.000000000 +0100
@@ -827,7 +827,7 @@ static int __init wanxl_init_module(void
 #ifdef MODULE
 	printk(KERN_INFO "%s\n", version);
 #endif
-	return pci_module_init(&wanxl_pci_driver);
+	return pci_register_driver(&wanxl_pci_driver);
 }
 
 static void __exit wanxl_cleanup_module(void)
_
