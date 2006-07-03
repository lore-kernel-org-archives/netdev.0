From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] drivers/net/*: conversion to pci_register_driver()
Date: Mon, 3 Jul 2006 21:39:15 +0400
Message-ID: <20060703173915.GA7581@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christophe Lucas <c.lucas@ifrance.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:4847 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751220AbWGCRjS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 13:39:18 -0400
Received: by nf-out-0910.google.com with SMTP id k26so474011nfc
        for <netdev@vger.kernel.org>; Mon, 03 Jul 2006 10:39:17 -0700 (PDT)
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe Lucas <c.lucas@ifrance.com>

Signed-off-by: Christophe Lucas <c.lucas@ifrance.com>
Signed-off-by: Domen Puncer <domen@coderock.org>
Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/3c59x.c                           |    2 +-
 drivers/net/8139cp.c                          |    2 +-
 drivers/net/8139too.c                         |    2 +-
 drivers/net/acenic.c                          |    2 +-
 drivers/net/amd8111e.c                        |    2 +-
 drivers/net/arcnet/com20020-pci.c             |    2 +-
 drivers/net/b44.c                             |    2 +-
 drivers/net/bnx2.c                            |    2 +-
 drivers/net/cassini.c                         |    2 +-
 drivers/net/chelsio/cxgb2.c                   |    2 +-
 drivers/net/defxx.c                           |    2 +-
 drivers/net/dl2k.c                            |    2 +-
 drivers/net/e100.c                            |    2 +-
 drivers/net/e1000/e1000_main.c                |    2 +-
 drivers/net/eepro100.c                        |    2 +-
 drivers/net/epic100.c                         |    2 +-
 drivers/net/fealnx.c                          |    2 +-
 drivers/net/forcedeth.c                       |    2 +-
 drivers/net/hp100.c                           |    2 +-
 drivers/net/ixgb/ixgb_main.c                  |    2 +-
 drivers/net/natsemi.c                         |    2 +-
 drivers/net/ne2k-pci.c                        |    2 +-
 drivers/net/ns83820.c                         |    2 +-
 drivers/net/pci-skeleton.c                    |    2 +-
 drivers/net/pcnet32.c                         |    2 +-
 drivers/net/r8169.c                           |    2 +-
 drivers/net/rrunner.c                         |    2 +-
 drivers/net/s2io.c                            |    2 +-
 drivers/net/saa9730.c                         |    2 +-
 drivers/net/sis190.c                          |    2 +-
 drivers/net/sis900.c                          |    2 +-
 drivers/net/sk98lin/skge.c                    |    2 +-
 drivers/net/skfp/skfddi.c                     |    2 +-
 drivers/net/skge.c                            |    2 +-
 drivers/net/starfire.c                        |    2 +-
 drivers/net/sundance.c                        |    2 +-
 drivers/net/sungem.c                          |    2 +-
 drivers/net/sunhme.c                          |    2 +-
 drivers/net/tc35815.c                         |    2 +-
 drivers/net/tg3.c                             |    2 +-
 drivers/net/tokenring/3c359.c                 |    2 +-
 drivers/net/tokenring/lanstreamer.c           |    2 +-
 drivers/net/tokenring/olympic.c               |    2 +-
 drivers/net/tulip/de2104x.c                   |    2 +-
 drivers/net/tulip/de4x5.c                     |    2 +-
 drivers/net/tulip/dmfe.c                      |    2 +-
 drivers/net/tulip/tulip_core.c                |    2 +-
 drivers/net/tulip/uli526x.c                   |    2 +-
 drivers/net/tulip/winbond-840.c               |    2 +-
 drivers/net/tulip/xircom_tulip_cb.c           |    2 +-
 drivers/net/typhoon.c                         |    2 +-
 drivers/net/via-rhine.c                       |    2 +-
 drivers/net/via-velocity.c                    |    2 +-
 drivers/net/wan/dscc4.c                       |    2 +-
 drivers/net/wan/farsync.c                     |    2 +-
 drivers/net/wan/lmc/lmc_main.c                |    2 +-
 drivers/net/wan/pc300_drv.c                   |    2 +-
 drivers/net/wan/pci200syn.c                   |    2 +-
 drivers/net/wan/wanxl.c                       |    2 +-
 drivers/net/wireless/atmel_pci.c              |    2 +-
 drivers/net/wireless/ipw2100.c                |    2 +-
 drivers/net/wireless/ipw2200.c                |    2 +-
 drivers/net/wireless/orinoco_nortel.c         |    2 +-
 drivers/net/wireless/orinoco_pci.c            |    2 +-
 drivers/net/wireless/orinoco_plx.c            |    2 +-
 drivers/net/wireless/orinoco_tmd.c            |    2 +-
 drivers/net/wireless/prism54/islpci_hotplug.c |    2 +-
 drivers/net/yellowfin.c                       |    2 +-
 68 files changed, 68 insertions(+), 68 deletions(-)

--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -3335,7 +3335,7 @@ static int __init vortex_init(void)
 {
 	int pci_rc, eisa_rc;
 
-	pci_rc = pci_module_init(&vortex_driver);
+	pci_rc = pci_register_driver(&vortex_driver);
 	eisa_rc = vortex_eisa_init();
 
 	if (pci_rc == 0)
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -2095,7 +2095,7 @@ static int __init cp_init (void)
 #ifdef MODULE
 	printk("%s", version);
 #endif
-	return pci_module_init (&cp_driver);
+	return pci_register_driver (&cp_driver);
 }
 
 static void __exit cp_exit (void)
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -2626,7 +2626,7 @@ #ifdef MODULE
 	printk (KERN_INFO RTL8139_DRIVER_NAME "\n");
 #endif
 
-	return pci_module_init (&rtl8139_pci_driver);
+	return pci_register_driver (&rtl8139_pci_driver);
 }
 
 
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -725,7 +725,7 @@ static struct pci_driver acenic_pci_driv
 
 static int __init acenic_init(void)
 {
-	return pci_module_init(&acenic_pci_driver);
+	return pci_register_driver(&acenic_pci_driver);
 }
 
 static void __exit acenic_exit(void)
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -2158,7 +2158,7 @@ static struct pci_driver amd8111e_driver
 
 static int __init amd8111e_init(void)
 {
-	return pci_module_init(&amd8111e_driver);
+	return pci_register_driver(&amd8111e_driver);
 }
 
 static void __exit amd8111e_cleanup(void)
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -177,7 +177,7 @@ static struct pci_driver com20020pci_dri
 static int __init com20020pci_init(void)
 {
 	BUGLVL(D_NORMAL) printk(VERSION);
-	return pci_module_init(&com20020pci_driver);
+	return pci_register_driver(&com20020pci_driver);
 }
 
 static void __exit com20020pci_cleanup(void)
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -2357,7 +2357,7 @@ static int __init b44_init(void)
 	dma_desc_align_mask = ~(dma_desc_align_size - 1);
 	dma_desc_sync_size = max_t(unsigned int, dma_desc_align_size, sizeof(struct dma_desc));
 
-	return pci_module_init(&b44_driver);
+	return pci_register_driver(&b44_driver);
 }
 
 static void __exit b44_cleanup(void)
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6015,7 +6015,7 @@ static struct pci_driver bnx2_pci_driver
 
 static int __init bnx2_init(void)
 {
-	return pci_module_init(&bnx2_pci_driver);
+	return pci_register_driver(&bnx2_pci_driver);
 }
 
 static void __exit bnx2_cleanup(void)
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -5250,7 +5250,7 @@ static int __init cas_init(void)
 	else
 		link_transition_timeout = 0;
 
-	return pci_module_init(&cas_driver);
+	return pci_register_driver(&cas_driver);
 }
 
 static void __exit cas_cleanup(void)
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -1243,7 +1243,7 @@ static struct pci_driver driver = {
 
 static int __init t1_init_module(void)
 {
-	return pci_module_init(&driver);
+	return pci_register_driver(&driver);
 }
 
 static void __exit t1_cleanup_module(void)
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -3444,7 +3444,7 @@ static int __init dfx_init(void)
 {
 	int rc_pci, rc_eisa;
 
-	rc_pci = pci_module_init(&dfx_driver);
+	rc_pci = pci_register_driver(&dfx_driver);
 	if (rc_pci >= 0) dfx_have_pci = 1;
 	
 	rc_eisa = dfx_eisa_init();
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -1854,7 +1854,7 @@ static struct pci_driver rio_driver = {
 static int __init
 rio_init (void)
 {
-	return pci_module_init (&rio_driver);
+	return pci_register_driver (&rio_driver);
 }
 
 static void __exit
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2873,7 +2873,7 @@ static int __init e100_init_module(void)
 		printk(KERN_INFO PFX "%s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
 		printk(KERN_INFO PFX "%s\n", DRV_COPYRIGHT);
 	}
-	return pci_module_init(&e100_driver);
+	return pci_register_driver(&e100_driver);
 }
 
 static void __exit e100_cleanup_module(void)
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -239,7 +239,7 @@ e1000_init_module(void)
 
 	printk(KERN_INFO "%s\n", e1000_copyright);
 
-	ret = pci_module_init(&e1000_driver);
+	ret = pci_register_driver(&e1000_driver);
 
 	return ret;
 }
--- a/drivers/net/eepro100.c
+++ b/drivers/net/eepro100.c
@@ -2385,7 +2385,7 @@ static int __init eepro100_init_module(v
 #ifdef MODULE
 	printk(version);
 #endif
-	return pci_module_init(&eepro100_driver);
+	return pci_register_driver(&eepro100_driver);
 }
 
 static void __exit eepro100_cleanup_module(void)
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -1655,7 +1655,7 @@ #ifdef MODULE
 		version, version2, version3);
 #endif
 
-	return pci_module_init (&epic_driver);
+	return pci_register_driver (&epic_driver);
 }
 
 
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -1982,7 +1982,7 @@ #ifdef MODULE
 	printk(version);
 #endif
 
-	return pci_module_init(&fealnx_driver);
+	return pci_register_driver(&fealnx_driver);
 }
 
 static void __exit fealnx_exit(void)
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -4513,7 +4513,7 @@ static struct pci_driver driver = {
 static int __init init_nic(void)
 {
 	printk(KERN_INFO "forcedeth.c: Reverse Engineered nForce ethernet driver. Version %s.\n", FORCEDETH_VERSION);
-	return pci_module_init(&driver);
+	return pci_register_driver(&driver);
 }
 
 static void __exit exit_nic(void)
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -3032,7 +3032,7 @@ #ifdef CONFIG_EISA
 		goto out2;
 #endif
 #ifdef CONFIG_PCI
-	err = pci_module_init(&hp100_pci_driver);
+	err = pci_register_driver(&hp100_pci_driver);
 	if (err && err != -ENODEV) 
 		goto out3;
 #endif
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -162,7 +162,7 @@ ixgb_init_module(void)
 
 	printk(KERN_INFO "%s\n", ixgb_copyright);
 
-	return pci_module_init(&ixgb_driver);
+	return pci_register_driver(&ixgb_driver);
 }
 
 module_init(ixgb_init_module);
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -3357,7 +3357,7 @@ #ifdef MODULE
 	printk(version);
 #endif
 
-	return pci_module_init (&natsemi_driver);
+	return pci_register_driver (&natsemi_driver);
 }
 
 static void __exit natsemi_exit_mod (void)
--- a/drivers/net/ne2k-pci.c
+++ b/drivers/net/ne2k-pci.c
@@ -701,7 +701,7 @@ static int __init ne2k_pci_init(void)
 #ifdef MODULE
 	printk(version);
 #endif
-	return pci_module_init (&ne2k_driver);
+	return pci_register_driver (&ne2k_driver);
 }
 
 
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -2175,7 +2175,7 @@ #endif
 static int __init ns83820_init(void)
 {
 	printk(KERN_INFO "ns83820.c: National Semiconductor DP83820 10/100/1000 driver.\n");
-	return pci_module_init(&driver);
+	return pci_register_driver(&driver);
 }
 
 static void __exit ns83820_exit(void)
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -1962,7 +1962,7 @@ static int __init netdrv_init_module (vo
 #ifdef MODULE
 	printk(version);
 #endif
-	return pci_module_init (&netdrv_pci_driver);
+	return pci_register_driver (&netdrv_pci_driver);
 }
 
 
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -2725,7 +2725,7 @@ static int __init pcnet32_init_module(vo
 		tx_start = tx_start_pt;
 
 	/* find the PCI devices */
-	if (!pci_module_init(&pcnet32_driver))
+	if (!pci_register_driver(&pcnet32_driver))
 		pcnet32_have_pci = 1;
 
 	/* should we find any remaining VLbus devices ? */
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2817,7 +2817,7 @@ #endif
 static int __init
 rtl8169_init_module(void)
 {
-	return pci_module_init(&rtl8169_pci_driver);
+	return pci_register_driver(&rtl8169_pci_driver);
 }
 
 static void __exit
--- a/drivers/net/rrunner.c
+++ b/drivers/net/rrunner.c
@@ -1736,7 +1736,7 @@ static struct pci_driver rr_driver = {
 
 static int __init rr_init_module(void)
 {
-	return pci_module_init(&rr_driver);
+	return pci_register_driver(&rr_driver);
 }
 
 static void __exit rr_cleanup_module(void)
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -7274,7 +7274,7 @@ static void __devexit s2io_rem_nic(struc
 
 int __init s2io_starter(void)
 {
-	return pci_module_init(&s2io_driver);
+	return pci_register_driver(&s2io_driver);
 }
 
 /**
--- a/drivers/net/saa9730.c
+++ b/drivers/net/saa9730.c
@@ -1131,7 +1131,7 @@ static struct pci_driver saa9730_driver 
 
 static int __init saa9730_init(void)
 {
-	return pci_module_init(&saa9730_driver);
+	return pci_register_driver(&saa9730_driver);
 }
 
 static void __exit saa9730_cleanup(void)
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1871,7 +1871,7 @@ static struct pci_driver sis190_pci_driv
 
 static int __init sis190_init_module(void)
 {
-	return pci_module_init(&sis190_pci_driver);
+	return pci_register_driver(&sis190_pci_driver);
 }
 
 static void __exit sis190_cleanup_module(void)
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -2495,7 +2495,7 @@ #ifdef MODULE
 	printk(version);
 #endif
 
-	return pci_module_init(&sis900_pci_driver);
+	return pci_register_driver(&sis900_pci_driver);
 }
 
 static void __exit sis900_cleanup_module(void)
--- a/drivers/net/sk98lin/skge.c
+++ b/drivers/net/sk98lin/skge.c
@@ -5133,7 +5133,7 @@ static struct pci_driver skge_driver = {
 
 static int __init skge_init(void)
 {
-	return pci_module_init(&skge_driver);
+	return pci_register_driver(&skge_driver);
 }
 
 static void __exit skge_exit(void)
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -2280,7 +2280,7 @@ static struct pci_driver skfddi_pci_driv
 
 static int __init skfd_init(void)
 {
-	return pci_module_init(&skfddi_pci_driver);
+	return pci_register_driver(&skfddi_pci_driver);
 }
 
 static void __exit skfd_exit(void)
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3511,7 +3511,7 @@ #endif
 
 static int __init skge_init_module(void)
 {
-	return pci_module_init(&skge_driver);
+	return pci_register_driver(&skge_driver);
 }
 
 static void __exit skge_cleanup_module(void)
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -2170,7 +2170,7 @@ #endif
 		return -ENODEV;
 	}
 
-	return pci_module_init (&starfire_driver);
+	return pci_register_driver (&starfire_driver);
 }
 
 
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -1814,7 +1814,7 @@ static int __init sundance_init(void)
 #ifdef MODULE
 	printk(version);
 #endif
-	return pci_module_init(&sundance_driver);
+	return pci_register_driver(&sundance_driver);
 }
 
 static void __exit sundance_exit(void)
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -3194,7 +3194,7 @@ #endif /* CONFIG_PM */
 
 static int __init gem_init(void)
 {
-	return pci_module_init(&gem_driver);
+	return pci_register_driver(&gem_driver);
 }
 
 static void __exit gem_cleanup(void)
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -3275,7 +3275,7 @@ static struct pci_driver hme_pci_driver 
 
 static int __init happy_meal_pci_init(void)
 {
-	return pci_module_init(&hme_pci_driver);
+	return pci_register_driver(&hme_pci_driver);
 }
 
 static void happy_meal_pci_exit(void)
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1725,7 +1725,7 @@ static struct pci_driver tc35815_driver 
 
 static int __init tc35815_init_module(void)
 {
-	return pci_module_init(&tc35815_driver);
+	return pci_register_driver(&tc35815_driver);
 }
 
 static void __exit tc35815_cleanup_module(void)
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11739,7 +11739,7 @@ static struct pci_driver tg3_driver = {
 
 static int __init tg3_init(void)
 {
-	return pci_module_init(&tg3_driver);
+	return pci_register_driver(&tg3_driver);
 }
 
 static void __exit tg3_cleanup(void)
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -1815,7 +1815,7 @@ static struct pci_driver xl_3c359_driver
 
 static int __init xl_pci_init (void)
 {
-	return pci_module_init (&xl_3c359_driver);
+	return pci_register_driver (&xl_3c359_driver);
 }
 
 
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -1998,7 +1998,7 @@ static struct pci_driver streamer_pci_dr
 };
 
 static int __init streamer_init_module(void) {
-  return pci_module_init(&streamer_pci_driver);
+  return pci_register_driver(&streamer_pci_driver);
 }
 
 static void __exit streamer_cleanup_module(void) {
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -1771,7 +1771,7 @@ static struct pci_driver olympic_driver 
 
 static int __init olympic_pci_init(void) 
 {
-	return pci_module_init (&olympic_driver) ; 
+	return pci_register_driver (&olympic_driver);
 }
 
 static void __exit olympic_pci_cleanup(void)
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -2172,7 +2172,7 @@ static int __init de_init (void)
 #ifdef MODULE
 	printk("%s", version);
 #endif
-	return pci_module_init (&de_driver);
+	return pci_register_driver (&de_driver);
 }
 
 static void __exit de_exit (void)
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -5754,7 +5754,7 @@ static int __init de4x5_module_init (voi
 	int err = 0;
 
 #ifdef CONFIG_PCI
-	err = pci_module_init (&de4x5_pci_driver);
+	err = pci_register_driver (&de4x5_pci_driver);
 #endif
 #ifdef CONFIG_EISA
 	err |= eisa_driver_register (&de4x5_eisa_driver);
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -2039,7 +2039,7 @@ static int __init dmfe_init_module(void)
 	if (HPNA_NoiseFloor > 15)
 		HPNA_NoiseFloor = 0;
 
-	rc = pci_module_init(&dmfe_driver);
+	rc = pci_register_driver(&dmfe_driver);
 	if (rc < 0)
 		return rc;
 
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -1849,7 +1849,7 @@ #endif
 	tulip_max_interrupt_work = max_interrupt_work;
 
 	/* probe for and init boards */
-	return pci_module_init (&tulip_driver);
+	return pci_register_driver (&tulip_driver);
 }
 
 
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -1725,7 +1725,7 @@ static int __init uli526x_init_module(vo
 		break;
 	}
 
-	rc = pci_module_init(&uli526x_driver);
+	rc = pci_register_driver(&uli526x_driver);
 	if (rc < 0)
 		return rc;
 
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -1692,7 +1692,7 @@ #endif
 static int __init w840_init(void)
 {
 	printk(version);
-	return pci_module_init(&w840_driver);
+	return pci_register_driver(&w840_driver);
 }
 
 static void __exit w840_exit(void)
--- a/drivers/net/tulip/xircom_tulip_cb.c
+++ b/drivers/net/tulip/xircom_tulip_cb.c
@@ -1726,7 +1726,7 @@ static int __init xircom_init(void)
 #ifdef MODULE
 	printk(version);
 #endif
-	return pci_module_init(&xircom_driver);
+	return pci_register_driver(&xircom_driver);
 }
 
 
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -2660,7 +2660,7 @@ #endif
 static int __init
 typhoon_init(void)
 {
-	return pci_module_init(&typhoon_driver);
+	return pci_register_driver(&typhoon_driver);
 }
 
 static void __exit
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -2046,7 +2046,7 @@ static int __init rhine_init(void)
 #ifdef MODULE
 	printk(version);
 #endif
-	return pci_module_init(&rhine_driver);
+	return pci_register_driver(&rhine_driver);
 }
 
 
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2252,7 +2252,7 @@ static int __init velocity_init_module(v
 	int ret;
 
 	velocity_register_notifier();
-	ret = pci_module_init(&velocity_driver);
+	ret = pci_register_driver(&velocity_driver);
 	if (ret < 0)
 		velocity_unregister_notifier();
 	return ret;
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -2062,7 +2062,7 @@ static struct pci_driver dscc4_driver = 
 
 static int __init dscc4_init_module(void)
 {
-	return pci_module_init(&dscc4_driver);
+	return pci_register_driver(&dscc4_driver);
 }
 
 static void __exit dscc4_cleanup_module(void)
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -2697,7 +2697,7 @@ fst_init(void)
 	for (i = 0; i < FST_MAX_CARDS; i++)
 		fst_card_array[i] = NULL;
 	spin_lock_init(&fst_work_q_lock);
-	return pci_module_init(&fst_driver);
+	return pci_register_driver(&fst_driver);
 }
 
 static void __exit
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1790,7 +1790,7 @@ static struct pci_driver lmc_driver = {
 
 static int __init init_lmc(void)
 {
-    return pci_module_init(&lmc_driver);
+    return pci_register_driver(&lmc_driver);
 }
 
 static void __exit exit_lmc(void)
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -3677,7 +3677,7 @@ static struct pci_driver cpc_driver = {
 
 static int __init cpc_init(void)
 {
-	return pci_module_init(&cpc_driver);
+	return pci_register_driver(&cpc_driver);
 }
 
 static void __exit cpc_cleanup_module(void)
--- a/drivers/net/wan/pci200syn.c
+++ b/drivers/net/wan/pci200syn.c
@@ -476,7 +476,7 @@ #endif
 		printk(KERN_ERR "pci200syn: Invalid PCI clock frequency\n");
 		return -EINVAL;
 	}
-	return pci_module_init(&pci200_pci_driver);
+	return pci_register_driver(&pci200_pci_driver);
 }
 
 
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -834,7 +834,7 @@ static int __init wanxl_init_module(void
 #ifdef MODULE
 	printk(KERN_INFO "%s\n", version);
 #endif
-	return pci_module_init(&wanxl_pci_driver);
+	return pci_register_driver(&wanxl_pci_driver);
 }
 
 static void __exit wanxl_cleanup_module(void)
--- a/drivers/net/wireless/atmel_pci.c
+++ b/drivers/net/wireless/atmel_pci.c
@@ -76,7 +76,7 @@ static void __devexit atmel_pci_remove(s
 
 static int __init atmel_init_module(void)
 {
-	return pci_module_init(&atmel_driver);
+	return pci_register_driver(&atmel_driver);
 }
 
 static void __exit atmel_cleanup_module(void)
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -6531,7 +6531,7 @@ static int __init ipw2100_init(void)
 	printk(KERN_INFO DRV_NAME ": %s, %s\n", DRV_DESCRIPTION, DRV_VERSION);
 	printk(KERN_INFO DRV_NAME ": %s\n", DRV_COPYRIGHT);
 
-	ret = pci_module_init(&ipw2100_pci_driver);
+	ret = pci_register_driver(&ipw2100_pci_driver);
 
 #ifdef CONFIG_IPW2100_DEBUG
 	ipw2100_debug_level = debug;
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -11774,7 +11774,7 @@ static int __init ipw_init(void)
 	printk(KERN_INFO DRV_NAME ": " DRV_DESCRIPTION ", " DRV_VERSION "\n");
 	printk(KERN_INFO DRV_NAME ": " DRV_COPYRIGHT "\n");
 
-	ret = pci_module_init(&ipw_driver);
+	ret = pci_register_driver(&ipw_driver);
 	if (ret) {
 		IPW_ERROR("Unable to initialize PCI module\n");
 		return ret;
--- a/drivers/net/wireless/orinoco_nortel.c
+++ b/drivers/net/wireless/orinoco_nortel.c
@@ -304,7 +304,7 @@ MODULE_LICENSE("Dual MPL/GPL");
 static int __init orinoco_nortel_init(void)
 {
 	printk(KERN_DEBUG "%s\n", version);
-	return pci_module_init(&orinoco_nortel_driver);
+	return pci_register_driver(&orinoco_nortel_driver);
 }
 
 static void __exit orinoco_nortel_exit(void)
--- a/drivers/net/wireless/orinoco_pci.c
+++ b/drivers/net/wireless/orinoco_pci.c
@@ -244,7 +244,7 @@ MODULE_LICENSE("Dual MPL/GPL");
 static int __init orinoco_pci_init(void)
 {
 	printk(KERN_DEBUG "%s\n", version);
-	return pci_module_init(&orinoco_pci_driver);
+	return pci_register_driver(&orinoco_pci_driver);
 }
 
 static void __exit orinoco_pci_exit(void)
--- a/drivers/net/wireless/orinoco_plx.c
+++ b/drivers/net/wireless/orinoco_plx.c
@@ -351,7 +351,7 @@ MODULE_LICENSE("Dual MPL/GPL");
 static int __init orinoco_plx_init(void)
 {
 	printk(KERN_DEBUG "%s\n", version);
-	return pci_module_init(&orinoco_plx_driver);
+	return pci_register_driver(&orinoco_plx_driver);
 }
 
 static void __exit orinoco_plx_exit(void)
--- a/drivers/net/wireless/orinoco_tmd.c
+++ b/drivers/net/wireless/orinoco_tmd.c
@@ -228,7 +228,7 @@ MODULE_LICENSE("Dual MPL/GPL");
 static int __init orinoco_tmd_init(void)
 {
 	printk(KERN_DEBUG "%s\n", version);
-	return pci_module_init(&orinoco_tmd_driver);
+	return pci_register_driver(&orinoco_tmd_driver);
 }
 
 static void __exit orinoco_tmd_exit(void)
--- a/drivers/net/wireless/prism54/islpci_hotplug.c
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c
@@ -313,7 +313,7 @@ prism54_module_init(void)
 
 	__bug_on_wrong_struct_sizes ();
 
-	return pci_module_init(&prism54_driver);
+	return pci_register_driver(&prism54_driver);
 }
 
 /* by the time prism54_module_exit() terminates, as a postcondition
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -1457,7 +1457,7 @@ static int __init yellowfin_init (void)
 #ifdef MODULE
 	printk(version);
 #endif
-	return pci_module_init (&yellowfin_driver);
+	return pci_register_driver (&yellowfin_driver);
 }
 
 

