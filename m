From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [firestream] remove dead code (from Francois Romieu <romieu@fr.zoreil.com>)
Date: Thu, 21 Oct 2004 07:27:41 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410211127.i9LBReF3008853@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com, romieu@fr.zoreil.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6

thanks!

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/18 16:33:47-04:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [firestream] remove dead code (from Francois Romieu <romieu@fr.zoreil.com>)
# 
# drivers/atm/firestream.c
#   2004/10/18 16:33:31-04:00 chas@relax.cmf.nrl.navy.mil +0 -59
#   [ATM]: [firestream] remove dead code (from Francois Romieu <romieu@fr.zoreil.com>)
# 
diff -Nru a/drivers/atm/firestream.c b/drivers/atm/firestream.c
--- a/drivers/atm/firestream.c	2004-10-18 16:52:17 -04:00
+++ b/drivers/atm/firestream.c	2004-10-18 16:52:17 -04:00
@@ -2013,65 +2013,6 @@
 }
 
 
-#if 0
-int __init fs_detect(void)
-{
-	struct pci_dev  *pci_dev;
-	int devs = 0;
-
-	func_enter ();
-	pci_dev = NULL;
-	while ((pci_dev = pci_find_device(PCI_VENDOR_ID_FUJITSU_ME,
-					  PCI_DEVICE_ID_FUJITSU_FS50, 
-					  pci_dev))) {
-		if (fs_register_and_init (pci_dev, &fs_pci_tbl[0]))
-			break;
-		devs++;
-	}
-
-	while ((pci_dev = pci_find_device(PCI_VENDOR_ID_FUJITSU_ME,
-					  PCI_DEVICE_ID_FUJITSU_FS155, 
-					  pci_dev))) {
-		if (fs_register_and_init (pci_dev, FS_IS155)) 
-			break;
-		devs++;
-	}
-	func_exit ();
-	return devs;
-}
-#else
-
-#if 0
-int __init init_PCI (void)
-{ /* Begin init_PCI */
-	
-	int pci_count;
-	printk ("init_PCI\n");
-	/*
-	  memset (&firestream_driver, 0, sizeof (firestream_driver));
-	  firestream_driver.name = "firestream";
-	  firestream_driver.id_table = firestream_pci_tbl;
-	  firestream_driver.probe = fs_register_and_init;
-	*/
-	pci_count = pci_register_driver (&firestream_driver);
-	
-	if (pci_count <= 0) {
-		pci_unregister_driver (&firestream_driver);
-		pci_count = 0;
-	}
-
-	return(pci_count);
-
-} /* End init_PCI */
-#endif
-#endif
-
-/*
-#ifdef MODULE
-#define firestream_init init_module
-#endif 
-*/
-
 static struct pci_device_id firestream_pci_tbl[] = {
 	{ PCI_VENDOR_ID_FUJITSU_ME, PCI_DEVICE_ID_FUJITSU_FS50, 
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, FS_IS50},
