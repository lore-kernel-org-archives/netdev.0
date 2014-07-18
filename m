From: Benoit Taine <benoit.taine@lip6.fr>
Subject: [PATCH 22/25] drivers/net: Replace DEFINE_PCI_DEVICE_TABLE macro use
Date: Fri, 18 Jul 2014 17:27:09 +0200
Message-ID: <1405697232-11785-23-git-send-email-benoit.taine@lip6.fr>
References: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Cc: benoit.taine@lip6.fr, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405697232-11785-1-git-send-email-benoit.taine@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should prefer `struct pci_device_id` over `DEFINE_PCI_DEVICE_TABLE` to meet
kernel coding style guidelines. This issue was reported by checkpatch.

Signed-off-by: Benoit Taine <benoit.taine@lip6.fr>

---
Tested by compilation without errors.

 drivers/net/arcnet/com20020-pci.c                    |    2 +-
 drivers/net/ethernet/chelsio/cxgb/subr.c             |    2 +-
 drivers/net/ethernet/dlink/dl2k.h                    |    2 +-
 drivers/net/ethernet/fealnx.c                        |    2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c            |    2 +-
 drivers/net/ethernet/micrel/ksz884x.c                |    2 +-
 drivers/net/ethernet/natsemi/ns83820.c               |    2 +-
 drivers/net/ethernet/nvidia/forcedeth.c              |    2 +-
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c |    2 +-
 drivers/net/ethernet/packetengines/hamachi.c         |    2 +-
 drivers/net/ethernet/packetengines/yellowfin.c       |    2 +-
 drivers/net/ethernet/realtek/8139cp.c                |    2 +-
 drivers/net/ethernet/realtek/8139too.c               |    2 +-
 drivers/net/ethernet/silan/sc92031.c                 |    2 +-
 drivers/net/ethernet/smsc/epic100.c                  |    2 +-
 drivers/net/ethernet/sun/cassini.c                   |    2 +-
 drivers/net/ethernet/sun/niu.c                       |    2 +-
 drivers/net/ethernet/sun/sungem.c                    |    2 +-
 drivers/net/ethernet/sun/sunhme.c                    |    2 +-
 drivers/net/ethernet/toshiba/tc35815.c               |    2 +-
 drivers/net/fddi/skfp/skfddi.c                       |    2 +-
 drivers/net/wan/lmc/lmc_main.c                       |    2 +-
 22 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index cbc44f5..7bb292e 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -144,7 +144,7 @@ static void com20020pci_remove(struct pci_dev *pdev)
 	free_netdev(dev);
 }
 
-static DEFINE_PCI_DEVICE_TABLE(com20020pci_id_table) = {
+static const struct pci_device_id com20020pci_id_table[] = {
 	{ 0x1571, 0xa001, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ 0x1571, 0xa002, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ 0x1571, 0xa003, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
diff --git a/drivers/net/ethernet/chelsio/cxgb/subr.c b/drivers/net/ethernet/chelsio/cxgb/subr.c
index 8167193..ea0f874 100644
--- a/drivers/net/ethernet/chelsio/cxgb/subr.c
+++ b/drivers/net/ethernet/chelsio/cxgb/subr.c
@@ -522,7 +522,7 @@ static const struct board_info t1_board[] = {
 
 };
 
-DEFINE_PCI_DEVICE_TABLE(t1_pci_tbl) = {
+const struct pci_device_id t1_pci_tbl[] = {
 	CH_DEVICE(8, 0, CH_BRD_T110_1CU),
 	CH_DEVICE(8, 1, CH_BRD_T110_1CU),
 	CH_DEVICE(7, 0, CH_BRD_N110_1F),
diff --git a/drivers/net/ethernet/dlink/dl2k.h b/drivers/net/ethernet/dlink/dl2k.h
index 7d07a0f..23c07b0 100644
--- a/drivers/net/ethernet/dlink/dl2k.h
+++ b/drivers/net/ethernet/dlink/dl2k.h
@@ -408,7 +408,7 @@ struct netdev_private {
         driver_data             Data private to the driver.
 */
 
-static DEFINE_PCI_DEVICE_TABLE(rio_pci_tbl) = {
+static const struct pci_device_id rio_pci_tbl[] = {
 	{0x1186, 0x4000, PCI_ANY_ID, PCI_ANY_ID, },
 	{0x13f0, 0x1021, PCI_ANY_ID, PCI_ANY_ID, },
 	{ }
diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index 4b22a95..b1b9eba 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -1936,7 +1936,7 @@ static int netdev_close(struct net_device *dev)
 	return 0;
 }
 
-static DEFINE_PCI_DEVICE_TABLE(fealnx_pci_tbl) = {
+static const struct pci_device_id fealnx_pci_tbl[] = {
 	{0x1516, 0x0800, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x1516, 0x0803, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1},
 	{0x1516, 0x0891, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 2},
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 82ab427..e854b79 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2705,7 +2705,7 @@ int mlx4_restart_one(struct pci_dev *pdev)
 	return __mlx4_init_one(pdev, pci_dev_data);
 }
 
-static DEFINE_PCI_DEVICE_TABLE(mlx4_pci_table) = {
+static const struct pci_device_id mlx4_pci_table[] = {
 	/* MT25408 "Hermon" SDR */
 	{ PCI_VDEVICE(MELLANOX, 0x6340), MLX4_PCI_DEV_FORCE_SENSE_PORT },
 	/* MT25408 "Hermon" DDR */
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index cd5f106..f1ebed6c 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -7221,7 +7221,7 @@ static int pcidev_suspend(struct pci_dev *pdev, pm_message_t state)
 
 static char pcidev_name[] = "ksz884xp";
 
-static DEFINE_PCI_DEVICE_TABLE(pcidev_table) = {
+static const struct pci_device_id pcidev_table[] = {
 	{ PCI_VENDOR_ID_MICREL_KS, 0x8841,
 		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ PCI_VENDOR_ID_MICREL_KS, 0x8842,
diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index 19bb824..2552e55 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -2260,7 +2260,7 @@ static void ns83820_remove_one(struct pci_dev *pci_dev)
 	free_netdev(ndev);
 }
 
-static DEFINE_PCI_DEVICE_TABLE(ns83820_pci_tbl) = {
+static const struct pci_device_id ns83820_pci_tbl[] = {
 	{ 0x100b, 0x0022, PCI_ANY_ID, PCI_ANY_ID, 0, .driver_data = 0, },
 	{ 0, },
 };
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 9afc536..925b296 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -6185,7 +6185,7 @@ static void nv_shutdown(struct pci_dev *pdev)
 #define nv_shutdown NULL
 #endif /* CONFIG_PM */
 
-static DEFINE_PCI_DEVICE_TABLE(pci_tbl) = {
+static const struct pci_device_id pci_tbl[] = {
 	{	/* nForce Ethernet Controller */
 		PCI_DEVICE(0x10DE, 0x01C3),
 		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 73e6683..3b98b263b 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2743,7 +2743,7 @@ static struct pch_gbe_privdata pch_gbe_minnow_privdata = {
 	.platform_init = pch_gbe_minnow_platform_init,
 };
 
-static DEFINE_PCI_DEVICE_TABLE(pch_gbe_pcidev_id) = {
+static const struct pci_device_id pch_gbe_pcidev_id[] = {
 	{.vendor = PCI_VENDOR_ID_INTEL,
 	 .device = PCI_DEVICE_ID_INTEL_IOH1_GBE,
 	 .subvendor = PCI_VENDOR_ID_CIRCUITCO,
diff --git a/drivers/net/ethernet/packetengines/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
index 9a997e4..319d9d4 100644
--- a/drivers/net/ethernet/packetengines/hamachi.c
+++ b/drivers/net/ethernet/packetengines/hamachi.c
@@ -1911,7 +1911,7 @@ static void hamachi_remove_one(struct pci_dev *pdev)
 	}
 }
 
-static DEFINE_PCI_DEVICE_TABLE(hamachi_pci_tbl) = {
+static const struct pci_device_id hamachi_pci_tbl[] = {
 	{ 0x1318, 0x0911, PCI_ANY_ID, PCI_ANY_ID, },
 	{ 0, }
 };
diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index 69a8dc0..2d6b148 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -236,7 +236,7 @@ static const struct pci_id_info pci_id_tbl[] = {
 	{ }
 };
 
-static DEFINE_PCI_DEVICE_TABLE(yellowfin_pci_tbl) = {
+static const struct pci_device_id yellowfin_pci_tbl[] = {
 	{ 0x1000, 0x0702, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ 0x1000, 0x0701, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
 	{ }
diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index 2bc728e..8af9460 100644
--- a/drivers/net/ethernet/realtek/8139cp.c
+++ b/drivers/net/ethernet/realtek/8139cp.c
@@ -382,7 +382,7 @@ static int cp_get_eeprom(struct net_device *dev,
 static int cp_set_eeprom(struct net_device *dev,
 			 struct ethtool_eeprom *eeprom, u8 *data);
 
-static DEFINE_PCI_DEVICE_TABLE(cp_pci_tbl) = {
+static const struct pci_device_id cp_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	PCI_DEVICE_ID_REALTEK_8139), },
 	{ PCI_DEVICE(PCI_VENDOR_ID_TTTECH,	PCI_DEVICE_ID_TTTECH_MC322), },
 	{ },
diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index 2e5df14..007b38c 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -234,7 +234,7 @@ static const struct {
 };
 
 
-static DEFINE_PCI_DEVICE_TABLE(rtl8139_pci_tbl) = {
+static const struct pci_device_id rtl8139_pci_tbl[] = {
 	{0x10ec, 0x8139, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x10ec, 0x8138, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x1113, 0x1211, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
diff --git a/drivers/net/ethernet/silan/sc92031.c b/drivers/net/ethernet/silan/sc92031.c
index 7daa7d4..7426f8b 100644
--- a/drivers/net/ethernet/silan/sc92031.c
+++ b/drivers/net/ethernet/silan/sc92031.c
@@ -1561,7 +1561,7 @@ out:
 	return 0;
 }
 
-static DEFINE_PCI_DEVICE_TABLE(sc92031_pci_device_id_table) = {
+static const struct pci_device_id sc92031_pci_device_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SILAN, 0x2031) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SILAN, 0x8139) },
 	{ PCI_DEVICE(0x1088, 0x2031) },
diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 8ae1f8a7..443f1da 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -173,7 +173,7 @@ static const struct epic_chip_info pci_id_tbl[] = {
 };
 
 
-static DEFINE_PCI_DEVICE_TABLE(epic_pci_tbl) = {
+static const struct pci_device_id epic_pci_tbl[] = {
 	{ 0x10B8, 0x0005, 0x1092, 0x0AB4, 0, 0, SMSC_83C170_0 },
 	{ 0x10B8, 0x0005, PCI_ANY_ID, PCI_ANY_ID, 0, 0, SMSC_83C170 },
 	{ 0x10B8, 0x0006, PCI_ANY_ID, PCI_ANY_ID,
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index b9ac20f..37f87ff 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -229,7 +229,7 @@ static u16 link_modes[] = {
 	CAS_BMCR_SPEED1000|BMCR_FULLDPLX /* 5 : 1000bt full duplex */
 };
 
-static DEFINE_PCI_DEVICE_TABLE(cas_pci_tbl) = {
+static const struct pci_device_id cas_pci_tbl[] = {
 	{ PCI_VENDOR_ID_SUN, PCI_DEVICE_ID_SUN_CASSINI,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_NS, PCI_DEVICE_ID_NS_SATURN,
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 79606f47a..0251d47 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -59,7 +59,7 @@ static void writeq(u64 val, void __iomem *reg)
 }
 #endif
 
-static DEFINE_PCI_DEVICE_TABLE(niu_pci_tbl) = {
+static const struct pci_device_id niu_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_SUN, 0xabcd)},
 	{}
 };
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index 102a66f..f7415b6 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -85,7 +85,7 @@ MODULE_LICENSE("GPL");
 
 #define GEM_MODULE_NAME	"gem"
 
-static DEFINE_PCI_DEVICE_TABLE(gem_pci_tbl) = {
+static const struct pci_device_id gem_pci_tbl[] = {
 	{ PCI_VENDOR_ID_SUN, PCI_DEVICE_ID_SUN_GEM,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 
diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 0dbf46f..72c8525 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -3172,7 +3172,7 @@ static void happy_meal_pci_remove(struct pci_dev *pdev)
 	free_netdev(net_dev);
 }
 
-static DEFINE_PCI_DEVICE_TABLE(happymeal_pci_ids) = {
+static const struct pci_device_id happymeal_pci_ids[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SUN, PCI_DEVICE_ID_SUN_HAPPYMEAL) },
 	{ }			/* Terminating entry */
 };
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index fef5573..45ac38d 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -65,7 +65,7 @@ static const struct {
 	{ "TOSHIBA TC35815/TX4939" },
 };
 
-static DEFINE_PCI_DEVICE_TABLE(tc35815_pci_tbl) = {
+static const struct pci_device_id tc35815_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815CF), .driver_data = TC35815CF },
 	{PCI_DEVICE(PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815_NWU), .driver_data = TC35815_NWU },
 	{PCI_DEVICE(PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815_TX4939), .driver_data = TC35815_TX4939 },
diff --git a/drivers/net/fddi/skfp/skfddi.c b/drivers/net/fddi/skfp/skfddi.c
index d5f5812..51acc6d 100644
--- a/drivers/net/fddi/skfp/skfddi.c
+++ b/drivers/net/fddi/skfp/skfddi.c
@@ -149,7 +149,7 @@ extern void mac_drv_rx_mode(struct s_smc *smc, int mode);
 extern void mac_drv_clear_rx_queue(struct s_smc *smc);
 extern void enable_tx_irq(struct s_smc *smc, u_short queue);
 
-static DEFINE_PCI_DEVICE_TABLE(skfddi_pci_tbl) = {
+static const struct pci_device_id skfddi_pci_tbl[] = {
 	{ PCI_VENDOR_ID_SK, PCI_DEVICE_ID_SK_FP, PCI_ANY_ID, PCI_ANY_ID, },
 	{ }			/* Terminating entry */
 };
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index b2fe9bb..bea0f31 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -76,7 +76,7 @@
 
 static int LMC_PKT_BUF_SZ = 1542;
 
-static DEFINE_PCI_DEVICE_TABLE(lmc_pci_tbl) = {
+static const struct pci_device_id lmc_pci_tbl[] = {
 	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_FAST,
 	  PCI_VENDOR_ID_LMC, PCI_ANY_ID },
 	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_FAST,
