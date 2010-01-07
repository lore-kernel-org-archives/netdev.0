From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] drivers/net/: use DEFINE_PCI_DEVICE_TABLE()
Date: Thu, 7 Jan 2010 23:58:11 +0200
Message-ID: <20100107215811.GA9357@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:49214 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750787Ab0AGV61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 16:58:27 -0500
Received: by fxm25 with SMTP id 25so12152855fxm.21
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2010 13:58:24 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use DEFINE_PCI_DEVICE_TABLE() so we get place PCI ids table into correct section
in every case.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/3c59x.c                           |    2 +-
 drivers/net/8139cp.c                          |    2 +-
 drivers/net/8139too.c                         |    2 +-
 drivers/net/acenic.c                          |    2 +-
 drivers/net/amd8111e.c                        |    2 +-
 drivers/net/arcnet/com20020-pci.c             |    2 +-
 drivers/net/atl1c/atl1c_main.c                |    2 +-
 drivers/net/atl1e/atl1e_main.c                |    2 +-
 drivers/net/atlx/atl1.c                       |    2 +-
 drivers/net/atlx/atl2.c                       |    2 +-
 drivers/net/b44.c                             |    2 +-
 drivers/net/bnx2x_main.c                      |    2 +-
 drivers/net/can/sja1000/ems_pci.c             |    2 +-
 drivers/net/can/sja1000/kvaser_pci.c          |    2 +-
 drivers/net/cassini.c                         |    2 +-
 drivers/net/chelsio/common.h                  |    2 +-
 drivers/net/chelsio/subr.c                    |    2 +-
 drivers/net/cxgb3/cxgb3_main.c                |    2 +-
 drivers/net/defxx.c                           |    2 +-
 drivers/net/dl2k.h                            |    2 +-
 drivers/net/e100.c                            |    2 +-
 drivers/net/e1000/e1000_main.c                |    2 +-
 drivers/net/e1000e/netdev.c                   |    2 +-
 drivers/net/enic/enic_main.c                  |    2 +-
 drivers/net/epic100.c                         |    2 +-
 drivers/net/fealnx.c                          |    2 +-
 drivers/net/forcedeth.c                       |    2 +-
 drivers/net/hamachi.c                         |    2 +-
 drivers/net/hp100.c                           |    2 +-
 drivers/net/igb/igb_main.c                    |    2 +-
 drivers/net/igbvf/netdev.c                    |    2 +-
 drivers/net/ioc3-eth.c                        |    2 +-
 drivers/net/ipg.c                             |    2 +-
 drivers/net/irda/donauboe.c                   |    2 +-
 drivers/net/irda/via-ircc.c                   |    2 +-
 drivers/net/irda/vlsi_ir.c                    |    2 +-
 drivers/net/ixgb/ixgb_main.c                  |    2 +-
 drivers/net/ixgbe/ixgbe_main.c                |    2 +-
 drivers/net/jme.c                             |    2 +-
 drivers/net/mlx4/main.c                       |    2 +-
 drivers/net/myri10ge/myri10ge.c               |    2 +-
 drivers/net/natsemi.c                         |    2 +-
 drivers/net/ne2k-pci.c                        |    2 +-
 drivers/net/netxen/netxen_nic_main.c          |    2 +-
 drivers/net/niu.c                             |    2 +-
 drivers/net/ns83820.c                         |    2 +-
 drivers/net/pasemi_mac.c                      |    2 +-
 drivers/net/pci-skeleton.c                    |    2 +-
 drivers/net/pcnet32.c                         |    2 +-
 drivers/net/qla3xxx.c                         |    2 +-
 drivers/net/qlge/qlge_main.c                  |    2 +-
 drivers/net/r6040.c                           |    2 +-
 drivers/net/r8169.c                           |    2 +-
 drivers/net/rrunner.c                         |    2 +-
 drivers/net/s2io.c                            |    2 +-
 drivers/net/sc92031.c                         |    2 +-
 drivers/net/sfc/efx.c                         |    2 +-
 drivers/net/sis190.c                          |    2 +-
 drivers/net/sis900.c                          |    2 +-
 drivers/net/skfp/skfddi.c                     |    2 +-
 drivers/net/skge.c                            |    2 +-
 drivers/net/smsc9420.c                        |    2 +-
 drivers/net/spider_net.c                      |    2 +-
 drivers/net/starfire.c                        |    2 +-
 drivers/net/sundance.c                        |    2 +-
 drivers/net/sungem.c                          |    2 +-
 drivers/net/sunhme.c                          |    2 +-
 drivers/net/tc35815.c                         |    2 +-
 drivers/net/tehuti.c                          |    2 +-
 drivers/net/tg3.c                             |    2 +-
 drivers/net/tlan.c                            |    2 +-
 drivers/net/tokenring/3c359.c                 |    2 +-
 drivers/net/tokenring/abyss.c                 |    2 +-
 drivers/net/tokenring/lanstreamer.c           |    2 +-
 drivers/net/tokenring/olympic.c               |    2 +-
 drivers/net/tokenring/tmspci.c                |    2 +-
 drivers/net/tulip/de2104x.c                   |    2 +-
 drivers/net/tulip/dmfe.c                      |    2 +-
 drivers/net/tulip/tulip_core.c                |    2 +-
 drivers/net/tulip/uli526x.c                   |    2 +-
 drivers/net/tulip/winbond-840.c               |    2 +-
 drivers/net/tulip/xircom_cb.c                 |    2 +-
 drivers/net/typhoon.c                         |    2 +-
 drivers/net/via-rhine.c                       |    2 +-
 drivers/net/via-velocity.c                    |    2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c             |    2 +-
 drivers/net/vxge/vxge-main.c                  |    2 +-
 drivers/net/wan/dscc4.c                       |    2 +-
 drivers/net/wan/farsync.c                     |    2 +-
 drivers/net/wan/lmc/lmc_main.c                |    2 +-
 drivers/net/wan/pc300_drv.c                   |    2 +-
 drivers/net/wan/pc300too.c                    |    2 +-
 drivers/net/wan/pci200syn.c                   |    2 +-
 drivers/net/wan/wanxl.c                       |    2 +-
 drivers/net/wireless/adm8211.c                |    2 +-
 drivers/net/wireless/airo.c                   |    2 +-
 drivers/net/wireless/ath/ath5k/base.c         |    2 +-
 drivers/net/wireless/ath/ath9k/pci.c          |    2 +-
 drivers/net/wireless/atmel_pci.c              |    2 +-
 drivers/net/wireless/hostap/hostap_pci.c      |    2 +-
 drivers/net/wireless/hostap/hostap_plx.c      |    2 +-
 drivers/net/wireless/ipw2x00/ipw2100.c        |    2 +-
 drivers/net/wireless/ipw2x00/ipw2200.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c        |    2 +-
 drivers/net/wireless/orinoco/orinoco_nortel.c |    2 +-
 drivers/net/wireless/orinoco/orinoco_pci.c    |    2 +-
 drivers/net/wireless/orinoco/orinoco_plx.c    |    2 +-
 drivers/net/wireless/orinoco/orinoco_tmd.c    |    2 +-
 drivers/net/wireless/p54/p54pci.c             |    2 +-
 drivers/net/wireless/prism54/islpci_hotplug.c |    2 +-
 drivers/net/wireless/rt2x00/rt2400pci.c       |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c       |    2 +-
 drivers/net/wireless/rt2x00/rt2800pci.c       |    2 +-
 drivers/net/wireless/rt2x00/rt61pci.c         |    2 +-
 drivers/net/wireless/rtl818x/rtl8180_dev.c    |    2 +-
 drivers/net/yellowfin.c                       |    2 +-
 118 files changed, 118 insertions(+), 118 deletions(-)

--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -375,7 +375,7 @@ static struct vortex_chip_info {
 };
 
 
-static struct pci_device_id vortex_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(vortex_pci_tbl) = {
 	{ 0x10B7, 0x5900, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C590 },
 	{ 0x10B7, 0x5920, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C592 },
 	{ 0x10B7, 0x5970, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C597 },
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -394,7 +394,7 @@ static int cp_get_eeprom(struct net_device *dev,
 static int cp_set_eeprom(struct net_device *dev,
 			 struct ethtool_eeprom *eeprom, u8 *data);
 
-static struct pci_device_id cp_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(cp_pci_tbl) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	PCI_DEVICE_ID_REALTEK_8139), },
 	{ PCI_DEVICE(PCI_VENDOR_ID_TTTECH,	PCI_DEVICE_ID_TTTECH_MC322), },
 	{ },
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -231,7 +231,7 @@ static const struct {
 };
 
 
-static const struct pci_device_id rtl8139_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(rtl8139_pci_tbl) = {
 	{0x10ec, 0x8139, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x10ec, 0x8138, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x1113, 0x1211, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -134,7 +134,7 @@
 #define PCI_DEVICE_ID_SGI_ACENIC	0x0009
 #endif
 
-static struct pci_device_id acenic_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(acenic_pci_tbl) = {
 	{ PCI_VENDOR_ID_ALTEON, PCI_DEVICE_ID_ALTEON_ACENIC_FIBRE,
 	  PCI_ANY_ID, PCI_ANY_ID, PCI_CLASS_NETWORK_ETHERNET << 8, 0xffff00, },
 	{ PCI_VENDOR_ID_ALTEON, PCI_DEVICE_ID_ALTEON_ACENIC_COPPER,
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -113,7 +113,7 @@ MODULE_PARM_DESC(coalesce, "Enable or Disable interrupt coalescing, 1: Enable, 0
 module_param_array(dynamic_ipg, bool, NULL, 0);
 MODULE_PARM_DESC(dynamic_ipg, "Enable or Disable dynamic IPG, 1: Enable, 0: Disable");
 
-static struct pci_device_id amd8111e_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(amd8111e_pci_tbl) = {
 
 	{ PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD8111E_7462,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -144,7 +144,7 @@ static void __devexit com20020pci_remove(struct pci_dev *pdev)
 	free_netdev(dev);
 }
 
-static struct pci_device_id com20020pci_id_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(com20020pci_id_table) = {
 	{ 0x1571, 0xa001, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ 0x1571, 0xa002, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ 0x1571, 0xa003, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -35,7 +35,7 @@ char atl1c_driver_version[] = ATL1C_DRV_VERSION;
  * { Vendor ID, Device ID, SubVendor ID, SubDevice ID,
  *   Class, Class Mask, private data (not used) }
  */
-static struct pci_device_id atl1c_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(atl1c_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, PCI_DEVICE_ID_ATTANSIC_L1C)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, PCI_DEVICE_ID_ATTANSIC_L2C)},
 	/* required last entry */
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -35,7 +35,7 @@ char atl1e_driver_version[] = DRV_VERSION;
  * { Vendor ID, Device ID, SubVendor ID, SubDevice ID,
  *   Class, Class Mask, private data (not used) }
  */
-static struct pci_device_id atl1e_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(atl1e_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, PCI_DEVICE_ID_ATTANSIC_L1E)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, 0x1066)},
 	/* required last entry */
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -232,7 +232,7 @@ static void __devinit atl1_check_options(struct atl1_adapter *adapter)
 /*
  * atl1_pci_tbl - PCI Device ID Table
  */
-static const struct pci_device_id atl1_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(atl1_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, PCI_DEVICE_ID_ATTANSIC_L1)},
 	/* required last entry */
 	{0,}
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -63,7 +63,7 @@ MODULE_VERSION(ATL2_DRV_VERSION);
 /*
  * atl2_pci_tbl - PCI Device ID Table
  */
-static struct pci_device_id atl2_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(atl2_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, PCI_DEVICE_ID_ATTANSIC_L2)},
 	/* required last entry */
 	{0,}
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -102,7 +102,7 @@ MODULE_PARM_DESC(b44_debug, "B44 bitmapped debugging message enable value");
 
 
 #ifdef CONFIG_B44_PCI
-static const struct pci_device_id b44_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(b44_pci_tbl) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_BCM4401) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_BCM4401B0) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_BCM4401B1) },
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -140,7 +140,7 @@ static struct {
 };
 
 
-static const struct pci_device_id bnx2x_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(bnx2x_pci_tbl) = {
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57710), BCM57710 },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57711), BCM57711 },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57711E), BCM57711E },
--- a/drivers/net/can/sja1000/ems_pci.c
+++ b/drivers/net/can/sja1000/ems_pci.c
@@ -102,7 +102,7 @@ struct ems_pci_card {
 
 #define EMS_PCI_BASE_SIZE  4096 /* size of controller area */
 
-static struct pci_device_id ems_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(ems_pci_tbl) = {
 	/* CPC-PCI v1 */
 	{PCI_VENDOR_ID_SIEMENS, 0x2104, PCI_ANY_ID, PCI_ANY_ID,},
 	/* CPC-PCI v2 */
--- a/drivers/net/can/sja1000/kvaser_pci.c
+++ b/drivers/net/can/sja1000/kvaser_pci.c
@@ -109,7 +109,7 @@ struct kvaser_pci {
 #define KVASER_PCI_VENDOR_ID2     0x1a07    /* the PCI device and vendor IDs */
 #define KVASER_PCI_DEVICE_ID2     0x0008
 
-static struct pci_device_id kvaser_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(kvaser_pci_tbl) = {
 	{KVASER_PCI_VENDOR_ID1, KVASER_PCI_DEVICE_ID1, PCI_ANY_ID, PCI_ANY_ID,},
 	{KVASER_PCI_VENDOR_ID2, KVASER_PCI_DEVICE_ID2, PCI_ANY_ID, PCI_ANY_ID,},
 	{ 0,}
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -236,7 +236,7 @@ static u16 link_modes[] __devinitdata = {
 	CAS_BMCR_SPEED1000|BMCR_FULLDPLX /* 5 : 1000bt full duplex */
 };
 
-static struct pci_device_id cas_pci_tbl[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(cas_pci_tbl) = {
 	{ PCI_VENDOR_ID_SUN, PCI_DEVICE_ID_SUN_CASSINI,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_NS, PCI_DEVICE_ID_NS_SATURN,
--- a/drivers/net/chelsio/common.h
+++ b/drivers/net/chelsio/common.h
@@ -334,7 +334,7 @@ static inline int t1_is_asic(const adapter_t *adapter)
 	return adapter->params.is_asic;
 }
 
-extern struct pci_device_id t1_pci_tbl[];
+extern const struct pci_device_id t1_pci_tbl[];
 
 static inline int adapter_matches_type(const adapter_t *adapter,
 				       int version, int revision)
--- a/drivers/net/chelsio/subr.c
+++ b/drivers/net/chelsio/subr.c
@@ -528,7 +528,7 @@ static const struct board_info t1_board[] = {
 
 };
 
-struct pci_device_id t1_pci_tbl[] = {
+DEFINE_PCI_DEVICE_TABLE(t1_pci_tbl) = {
 	CH_DEVICE(8, 0, CH_BRD_T110_1CU),
 	CH_DEVICE(8, 1, CH_BRD_T110_1CU),
 	CH_DEVICE(7, 0, CH_BRD_N110_1F),
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -80,7 +80,7 @@ enum {
 #define CH_DEVICE(devid, idx) \
 	{ PCI_VENDOR_ID_CHELSIO, devid, PCI_ANY_ID, PCI_ANY_ID, 0, 0, idx }
 
-static const struct pci_device_id cxgb3_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(cxgb3_pci_tbl) = {
 	CH_DEVICE(0x20, 0),	/* PE9000 */
 	CH_DEVICE(0x21, 1),	/* T302E */
 	CH_DEVICE(0x22, 2),	/* T310E */
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -3631,7 +3631,7 @@ static int __devinit dfx_pci_register(struct pci_dev *,
 				      const struct pci_device_id *);
 static void __devexit dfx_pci_unregister(struct pci_dev *);
 
-static struct pci_device_id dfx_pci_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(dfx_pci_table) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_FDDI) },
 	{ }
 };
--- a/drivers/net/dl2k.h
+++ b/drivers/net/dl2k.h
@@ -537,7 +537,7 @@ struct netdev_private {
         driver_data             Data private to the driver.
 */
 
-static const struct pci_device_id rio_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(rio_pci_tbl) = {
 	{0x1186, 0x4000, PCI_ANY_ID, PCI_ANY_ID, },
 	{0x13f0, 0x1021, PCI_ANY_ID, PCI_ANY_ID, },
 	{ }
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -208,7 +208,7 @@ MODULE_PARM_DESC(use_io, "Force use of i/o access mode");
 #define INTEL_8255X_ETHERNET_DEVICE(device_id, ich) {\
 	PCI_VENDOR_ID_INTEL, device_id, PCI_ANY_ID, PCI_ANY_ID, \
 	PCI_CLASS_NETWORK_ETHERNET << 8, 0xFFFF00, ich }
-static struct pci_device_id e100_id_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(e100_id_table) = {
 	INTEL_8255X_ETHERNET_DEVICE(0x1029, 0),
 	INTEL_8255X_ETHERNET_DEVICE(0x1030, 0),
 	INTEL_8255X_ETHERNET_DEVICE(0x1031, 3),
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -42,7 +42,7 @@ static const char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation
  * Macro expands to...
  *   {PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
  */
-static struct pci_device_id e1000_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(e1000_pci_tbl) = {
 	INTEL_E1000_ETHERNET_DEVICE(0x1000),
 	INTEL_E1000_ETHERNET_DEVICE(0x1001),
 	INTEL_E1000_ETHERNET_DEVICE(0x1004),
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5325,7 +5325,7 @@ static struct pci_error_handlers e1000_err_handler = {
 	.resume = e1000_io_resume,
 };
 
-static struct pci_device_id e1000_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(e1000_pci_tbl) = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_COPPER), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_FIBER), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_QUAD_COPPER), board_82571 },
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -51,7 +51,7 @@
 #define PCI_DEVICE_ID_CISCO_VIC_ENET         0x0043  /* ethernet vnic */
 
 /* Supported devices */
-static struct pci_device_id enic_id_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(enic_id_table) = {
 	{ PCI_VDEVICE(CISCO, PCI_DEVICE_ID_CISCO_VIC_ENET) },
 	{ 0, }	/* end of table */
 };
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -167,7 +167,7 @@ static const struct epic_chip_info pci_id_tbl[] = {
 };
 
 
-static struct pci_device_id epic_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(epic_pci_tbl) = {
 	{ 0x10B8, 0x0005, 0x1092, 0x0AB4, 0, 0, SMSC_83C170_0 },
 	{ 0x10B8, 0x0005, PCI_ANY_ID, PCI_ANY_ID, 0, 0, SMSC_83C170 },
 	{ 0x10B8, 0x0006, PCI_ANY_ID, PCI_ANY_ID,
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -1941,7 +1941,7 @@ static int netdev_close(struct net_device *dev)
 	return 0;
 }
 
-static struct pci_device_id fealnx_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(fealnx_pci_tbl) = {
 	{0x1516, 0x0800, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x1516, 0x0803, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1},
 	{0x1516, 0x0891, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 2},
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -6198,7 +6198,7 @@ static void nv_shutdown(struct pci_dev *pdev)
 #define nv_resume NULL
 #endif /* CONFIG_PM */
 
-static struct pci_device_id pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(pci_tbl) = {
 	{	/* nForce Ethernet Controller */
 		PCI_DEVICE(0x10DE, 0x01C3),
 		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -1990,7 +1990,7 @@ static void __devexit hamachi_remove_one (struct pci_dev *pdev)
 	}
 }
 
-static struct pci_device_id hamachi_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(hamachi_pci_tbl) = {
 	{ 0x1318, 0x0911, PCI_ANY_ID, PCI_ANY_ID, },
 	{ 0, }
 };
--- a/drivers/net/hp100.c
+++ b/drivers/net/hp100.c
@@ -210,7 +210,7 @@ MODULE_DEVICE_TABLE(eisa, hp100_eisa_tbl);
 #endif
 
 #ifdef CONFIG_PCI
-static struct pci_device_id hp100_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(hp100_pci_tbl) = {
 	{PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_J2585A, PCI_ANY_ID, PCI_ANY_ID,},
 	{PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_J2585B, PCI_ANY_ID, PCI_ANY_ID,},
 	{PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_J2970A, PCI_ANY_ID, PCI_ANY_ID,},
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -60,7 +60,7 @@ static const struct e1000_info *igb_info_tbl[] = {
 	[board_82575] = &e1000_82575_info,
 };
 
-static struct pci_device_id igb_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(igb_pci_tbl) = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_COPPER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_FIBER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_SERDES), board_82575 },
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2876,7 +2876,7 @@ static struct pci_error_handlers igbvf_err_handler = {
 	.resume = igbvf_io_resume,
 };
 
-static struct pci_device_id igbvf_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(igbvf_pci_tbl) = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_VF), board_vf },
 	{ } /* terminate list */
 };
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1383,7 +1383,7 @@ static void __devexit ioc3_remove_one (struct pci_dev *pdev)
 	 */
 }
 
-static struct pci_device_id ioc3_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(ioc3_pci_tbl) = {
 	{ PCI_VENDOR_ID_SGI, PCI_DEVICE_ID_SGI_IOC3, PCI_ANY_ID, PCI_ANY_ID },
 	{ 0 }
 };
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -92,7 +92,7 @@ static const char *ipg_brand_name[] = {
 	"D-Link NIC IP1000A"
 };
 
-static struct pci_device_id ipg_pci_tbl[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(ipg_pci_tbl) = {
 	{ PCI_VDEVICE(SUNDANCE,	0x1023), 0 },
 	{ PCI_VDEVICE(SUNDANCE,	0x2021), 1 },
 	{ PCI_VDEVICE(SUNDANCE,	0x1021), 2 },
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -184,7 +184,7 @@
 #define CONFIG0H_DMA_ON_NORX CONFIG0H_DMA_OFF| OBOE_CONFIG0H_ENDMAC
 #define CONFIG0H_DMA_ON CONFIG0H_DMA_ON_NORX | OBOE_CONFIG0H_ENRX
 
-static struct pci_device_id toshoboe_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(toshoboe_pci_tbl) = {
 	{ PCI_VENDOR_ID_TOSHIBA, PCI_DEVICE_ID_FIR701, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_TOSHIBA, PCI_DEVICE_ID_FIRD01, PCI_ANY_ID, PCI_ANY_ID, },
 	{ }			/* Terminating entry */
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -121,7 +121,7 @@ static void iodelay(int udelay)
 	}
 }
 
-static struct pci_device_id via_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(via_pci_tbl) = {
 	{ PCI_VENDOR_ID_VIA, 0x8231, PCI_ANY_ID, PCI_ANY_ID,0,0,0 },
 	{ PCI_VENDOR_ID_VIA, 0x3109, PCI_ANY_ID, PCI_ANY_ID,0,0,1 },
 	{ PCI_VENDOR_ID_VIA, 0x3074, PCI_ANY_ID, PCI_ANY_ID,0,0,2 },
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -59,7 +59,7 @@ MODULE_LICENSE("GPL");
 
 static /* const */ char drivername[] = DRIVER_NAME;
 
-static struct pci_device_id vlsi_irda_table [] = {
+static DEFINE_PCI_DEVICE_TABLE(vlsi_irda_table) = {
 	{
 		.class =        PCI_CLASS_WIRELESS_IRDA << 8,
 		.class_mask =	PCI_CLASS_SUBCLASS_MASK << 8, 
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -50,7 +50,7 @@ MODULE_PARM_DESC(copybreak,
  * { Vendor ID, Device ID, SubVendor ID, SubDevice ID,
  *   Class, Class Mask, private data (not used) }
  */
-static struct pci_device_id ixgb_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(ixgb_pci_tbl) = {
 	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_CX4,
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -67,7 +67,7 @@ static const struct ixgbe_info *ixgbe_info_tbl[] = {
  * { Vendor ID, Device ID, SubVendor ID, SubDevice ID,
  *   Class, Class Mask, private data (not used) }
  */
-static struct pci_device_id ixgbe_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(ixgbe_pci_tbl) = {
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598),
 	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AF_DUAL_PORT),
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2994,7 +2994,7 @@ jme_resume(struct pci_dev *pdev)
 }
 #endif
 
-static struct pci_device_id jme_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(jme_pci_tbl) = {
 	{ PCI_VDEVICE(JMICRON, PCI_DEVICE_ID_JMICRON_JMC250) },
 	{ PCI_VDEVICE(JMICRON, PCI_DEVICE_ID_JMICRON_JMC260) },
 	{ }
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -1271,7 +1271,7 @@ int mlx4_restart_one(struct pci_dev *pdev)
 	return __mlx4_init_one(pdev, NULL);
 }
 
-static struct pci_device_id mlx4_pci_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(mlx4_pci_table) = {
 	{ PCI_VDEVICE(MELLANOX, 0x6340) }, /* MT25408 "Hermon" SDR */
 	{ PCI_VDEVICE(MELLANOX, 0x634a) }, /* MT25408 "Hermon" DDR */
 	{ PCI_VDEVICE(MELLANOX, 0x6354) }, /* MT25408 "Hermon" QDR */
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -4085,7 +4085,7 @@ static void myri10ge_remove(struct pci_dev *pdev)
 #define PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E 	0x0008
 #define PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E_9	0x0009
 
-static struct pci_device_id myri10ge_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(myri10ge_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_MYRICOM, PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E)},
 	{PCI_DEVICE
 	 (PCI_VENDOR_ID_MYRICOM, PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E_9)},
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -247,7 +247,7 @@ static struct {
 	{ "NatSemi DP8381[56]", 0, 24 },
 };
 
-static struct pci_device_id natsemi_pci_tbl[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(natsemi_pci_tbl) = {
 	{ PCI_VENDOR_ID_NS, 0x0020, 0x12d9,     0x000c,     0, 0, 0 },
 	{ PCI_VENDOR_ID_NS, 0x0020, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
 	{ }	/* terminate list */
--- a/drivers/net/ne2k-pci.c
+++ b/drivers/net/ne2k-pci.c
@@ -136,7 +136,7 @@ static struct {
 };
 
 
-static struct pci_device_id ne2k_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(ne2k_pci_tbl) = {
 	{ 0x10ec, 0x8029, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_RealTek_RTL_8029 },
 	{ 0x1050, 0x0940, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_Winbond_89C940 },
 	{ 0x11f6, 0x1401, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_Compex_RL2000 },
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -100,7 +100,7 @@ static void netxen_config_indev_addr(struct net_device *dev, unsigned long);
 	{PCI_DEVICE(PCI_VENDOR_ID_NETXEN, (device)), \
 	.class = PCI_CLASS_NETWORK_ETHERNET << 8, .class_mask = ~0}
 
-static struct pci_device_id netxen_pci_tbl[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(netxen_pci_tbl) = {
 	ENTRY(PCI_DEVICE_ID_NX2031_10GXSR),
 	ENTRY(PCI_DEVICE_ID_NX2031_10GCX4),
 	ENTRY(PCI_DEVICE_ID_NX2031_4GCU),
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -58,7 +58,7 @@ static void writeq(u64 val, void __iomem *reg)
 }
 #endif
 
-static struct pci_device_id niu_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(niu_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_SUN, 0xabcd)},
 	{}
 };
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -2292,7 +2292,7 @@ static void __devexit ns83820_remove_one(struct pci_dev *pci_dev)
 	pci_set_drvdata(pci_dev, NULL);
 }
 
-static struct pci_device_id ns83820_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(ns83820_pci_tbl) = {
 	{ 0x100b, 0x0022, PCI_ANY_ID, PCI_ANY_ID, 0, .driver_data = 0, },
 	{ 0, },
 };
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -1875,7 +1875,7 @@ static void __devexit pasemi_mac_remove(struct pci_dev *pdev)
 	free_netdev(netdev);
 }
 
-static struct pci_device_id pasemi_mac_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(pasemi_mac_pci_tbl) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_PASEMI, 0xa005) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_PASEMI, 0xa006) },
 	{ },
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -211,7 +211,7 @@ static struct {
 };
 
 
-static const struct pci_device_id netdrv_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(netdrv_pci_tbl) = {
 	{0x10ec, 0x8139, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x10ec, 0x8138, PCI_ANY_ID, PCI_ANY_ID, 0, 0, NETDRV_CB },
 	{0x1113, 0x1211, PCI_ANY_ID, PCI_ANY_ID, 0, 0, SMC1211TX },
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -58,7 +58,7 @@ static const char *const version =
 /*
  * PCI device identifiers for "new style" Linux PCI Device Drivers
  */
-static struct pci_device_id pcnet32_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(pcnet32_pci_tbl) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_LANCE_HOME), },
 	{ PCI_DEVICE(PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_LANCE), },
 
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -61,7 +61,7 @@ static int msi;
 module_param(msi, int, 0);
 MODULE_PARM_DESC(msi, "Turn on Message Signaled Interrupts.");
 
-static struct pci_device_id ql3xxx_pci_tbl[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(ql3xxx_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QL3022_DEVICE_ID)},
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QL3032_DEVICE_ID)},
 	/* required last entry */
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -73,7 +73,7 @@ static int qlge_irq_type = MSIX_IRQ;
 module_param(qlge_irq_type, int, MSIX_IRQ);
 MODULE_PARM_DESC(qlge_irq_type, "0 = MSI-X, 1 = MSI, 2 = Legacy.");
 
-static struct pci_device_id qlge_pci_tbl[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(qlge_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QLGE_DEVICE_ID_8012)},
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QLGE_DEVICE_ID_8000)},
 	/* required last entry */
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -1222,7 +1222,7 @@ static void __devexit r6040_remove_one(struct pci_dev *pdev)
 }
 
 
-static struct pci_device_id r6040_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(r6040_pci_tbl) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_RDC, 0x6040) },
 	{ 0 }
 };
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -168,7 +168,7 @@ static void rtl_hw_start_8169(struct net_device *);
 static void rtl_hw_start_8168(struct net_device *);
 static void rtl_hw_start_8101(struct net_device *);
 
-static struct pci_device_id rtl8169_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(rtl8169_pci_tbl) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8129), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8136), 0, 0, RTL_CFG_2 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8167), 0, 0, RTL_CFG_0 },
--- a/drivers/net/rrunner.c
+++ b/drivers/net/rrunner.c
@@ -1688,7 +1688,7 @@ static int rr_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	}
 }
 
-static struct pci_device_id rr_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(rr_pci_tbl) = {
 	{ PCI_VENDOR_ID_ESSENTIAL, PCI_DEVICE_ID_ESSENTIAL_ROADRUNNER,
 		PCI_ANY_ID, PCI_ANY_ID, },
 	{ 0,}
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -523,7 +523,7 @@ module_param_array(rts_frm_len, uint, NULL, 0);
  * S2IO device table.
  * This table lists all the devices that this driver supports.
  */
-static struct pci_device_id s2io_tbl[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(s2io_tbl) = {
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_S2IO_WIN,
 	 PCI_ANY_ID, PCI_ANY_ID},
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_S2IO_UNI,
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -1589,7 +1589,7 @@ out:
 	return 0;
 }
 
-static struct pci_device_id sc92031_pci_device_id_table[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(sc92031_pci_device_id_table) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SILAN, 0x2031) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SILAN, 0x8139) },
 	{ PCI_DEVICE(0x1088, 0x2031) },
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1940,7 +1940,7 @@ void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
  **************************************************************************/
 
 /* PCI device ID table */
-static struct pci_device_id efx_pci_table[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(efx_pci_table) = {
 	{PCI_DEVICE(EFX_VENDID_SFC, FALCON_A_P_DEVID),
 	 .driver_data = (unsigned long) &falcon_a1_nic_type},
 	{PCI_DEVICE(EFX_VENDID_SFC, FALCON_B_P_DEVID),
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -334,7 +334,7 @@ static const struct {
 	{ "SiS 191 PCI Gigabit Ethernet adapter" },
 };
 
-static struct pci_device_id sis190_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(sis190_pci_tbl) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0190), 0, 0, 0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0191), 0, 0, 1 },
 	{ 0, },
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -106,7 +106,7 @@ static const char * card_names[] = {
 	"SiS 900 PCI Fast Ethernet",
 	"SiS 7016 PCI Fast Ethernet"
 };
-static struct pci_device_id sis900_pci_tbl [] = {
+static DEFINE_PCI_DEVICE_TABLE(sis900_pci_tbl) = {
 	{PCI_VENDOR_ID_SI, PCI_DEVICE_ID_SI_900,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, SIS_900},
 	{PCI_VENDOR_ID_SI, PCI_DEVICE_ID_SI_7016,
--- a/drivers/net/skfp/skfddi.c
+++ b/drivers/net/skfp/skfddi.c
@@ -149,7 +149,7 @@ extern void mac_drv_rx_mode(struct s_smc *smc, int mode);
 extern void mac_drv_clear_rx_queue(struct s_smc *smc);
 extern void enable_tx_irq(struct s_smc *smc, u_short queue);
 
-static struct pci_device_id skfddi_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(skfddi_pci_tbl) = {
 	{ PCI_VENDOR_ID_SK, PCI_DEVICE_ID_SK_FP, PCI_ANY_ID, PCI_ANY_ID, },
 	{ }			/* Terminating entry */
 };
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -78,7 +78,7 @@ static int debug = -1;	/* defaults above */
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
-static const struct pci_device_id skge_id_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(skge_id_table) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3C940) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3C940B) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_GE) },
--- a/drivers/net/smsc9420.c
+++ b/drivers/net/smsc9420.c
@@ -80,7 +80,7 @@ struct smsc9420_pdata {
 	int last_carrier;
 };
 
-static const struct pci_device_id smsc9420_id_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(smsc9420_id_table) = {
 	{ PCI_VENDOR_ID_9420, PCI_DEVICE_ID_9420, PCI_ANY_ID, PCI_ANY_ID, },
 	{ 0, }
 };
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -72,7 +72,7 @@ MODULE_PARM_DESC(tx_descriptors, "number of descriptors used " \
 
 char spider_net_driver_name[] = "spidernet";
 
-static struct pci_device_id spider_net_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(spider_net_pci_tbl) = {
 	{ PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_SPIDER_NET,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ 0, }
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -301,7 +301,7 @@ enum chipset {
 	CH_6915 = 0,
 };
 
-static struct pci_device_id starfire_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(starfire_pci_tbl) = {
 	{ 0x9004, 0x6915, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_6915 },
 	{ 0, }
 };
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -206,7 +206,7 @@ IVc. Errata
 #define USE_IO_OPS 1
 #endif
 
-static const struct pci_device_id sundance_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(sundance_pci_tbl) = {
 	{ 0x1186, 0x1002, 0x1186, 0x1002, 0, 0, 0 },
 	{ 0x1186, 0x1002, 0x1186, 0x1003, 0, 0, 1 },
 	{ 0x1186, 0x1002, 0x1186, 0x1012, 0, 0, 2 },
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -107,7 +107,7 @@ MODULE_LICENSE("GPL");
 #define GEM_MODULE_NAME	"gem"
 #define PFX GEM_MODULE_NAME ": "
 
-static struct pci_device_id gem_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(gem_pci_tbl) = {
 	{ PCI_VENDOR_ID_SUN, PCI_DEVICE_ID_SUN_GEM,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -3211,7 +3211,7 @@ static void __devexit happy_meal_pci_remove(struct pci_dev *pdev)
 	dev_set_drvdata(&pdev->dev, NULL);
 }
 
-static struct pci_device_id happymeal_pci_ids[] = {
+static DEFINE_PCI_DEVICE_TABLE(happymeal_pci_ids) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SUN, PCI_DEVICE_ID_SUN_HAPPYMEAL) },
 	{ }			/* Terminating entry */
 };
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -65,7 +65,7 @@ static const struct {
 	{ "TOSHIBA TC35815/TX4939" },
 };
 
-static const struct pci_device_id tc35815_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(tc35815_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815CF), .driver_data = TC35815CF },
 	{PCI_DEVICE(PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815_NWU), .driver_data = TC35815_NWU },
 	{PCI_DEVICE(PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815_TX4939), .driver_data = TC35815_TX4939 },
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -64,7 +64,7 @@
 
 #include "tehuti.h"
 
-static struct pci_device_id __devinitdata bdx_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(bdx_pci_tbl) = {
 	{0x1FC9, 0x3009, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x1FC9, 0x3010, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x1FC9, 0x3014, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -174,7 +174,7 @@ static int tg3_debug = -1;	/* -1 == use TG3_DEF_MSG_ENABLE as value */
 module_param(tg3_debug, int, 0);
 MODULE_PARM_DESC(tg3_debug, "Tigon3 bitmapped debugging message enable value");
 
-static struct pci_device_id tg3_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5700)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5701)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5702)},
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -254,7 +254,7 @@ static struct board {
 	{ "Compaq NetFlex-3/E", TLAN_ADAPTER_ACTIVITY_LED, 0x83 }, /* EISA card */
 };
 
-static struct pci_device_id tlan_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(tlan_pci_tbl) = {
 	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL10,
 		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL100,
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -117,7 +117,7 @@ MODULE_PARM_DESC(message_level, "3c359: Level of reported messages") ;
  *	will be stuck with 1555 lines of hex #'s in the code.
  */
 
-static struct pci_device_id xl_pci_tbl[] =
+static DEFINE_PCI_DEVICE_TABLE(xl_pci_tbl) =
 {
 	{PCI_VENDOR_ID_3COM,PCI_DEVICE_ID_3COM_3C359, PCI_ANY_ID, PCI_ANY_ID, },
 	{ }			/* terminate list */
--- a/drivers/net/tokenring/abyss.c
+++ b/drivers/net/tokenring/abyss.c
@@ -45,7 +45,7 @@ static char version[] __devinitdata =
 
 #define ABYSS_IO_EXTENT 64
 
-static struct pci_device_id abyss_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(abyss_pci_tbl) = {
 	{ PCI_VENDOR_ID_MADGE, PCI_DEVICE_ID_MADGE_MK2,
 	  PCI_ANY_ID, PCI_ANY_ID, PCI_CLASS_NETWORK_TOKEN_RING << 8, 0x00ffffff, },
 	{ }			/* Terminating entry */
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -146,7 +146,7 @@
 static char version[] = "LanStreamer.c v0.4.0 03/08/01 - Mike Sullivan\n"
                         "              v0.5.3 11/13/02 - Kent Yoder";
 
-static struct pci_device_id streamer_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(streamer_pci_tbl) = {
 	{ PCI_VENDOR_ID_IBM, PCI_DEVICE_ID_IBM_TR, PCI_ANY_ID, PCI_ANY_ID,},
 	{}	/* terminating entry */
 };
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -172,7 +172,7 @@ module_param_array(message_level, int, NULL, 0) ;
 static int network_monitor[OLYMPIC_MAX_ADAPTERS] = {0,};
 module_param_array(network_monitor, int, NULL, 0);
 
-static struct pci_device_id olympic_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(olympic_pci_tbl) = {
 	{PCI_VENDOR_ID_IBM,PCI_DEVICE_ID_IBM_TR_WAKE,PCI_ANY_ID,PCI_ANY_ID,},
 	{ } 	/* Terminating Entry */
 };
--- a/drivers/net/tokenring/tmspci.c
+++ b/drivers/net/tokenring/tmspci.c
@@ -57,7 +57,7 @@ static struct card_info card_info_table[] = {
 	{ {0x03, 0x01}, "3Com Token Link Velocity"},
 };
 
-static struct pci_device_id tmspci_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(tmspci_pci_tbl) = {
 	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_TOKENRING, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_TR, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
 	{ PCI_VENDOR_ID_TCONRAD, PCI_DEVICE_ID_TCONRAD_TOKENRING, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 2 },
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -337,7 +337,7 @@ static void de21041_media_timer (unsigned long data);
 static unsigned int de_ok_to_advertise (struct de_private *de, u32 new_media);
 
 
-static struct pci_device_id de_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(de_pci_tbl) = {
 	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_PLUS,
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -2068,7 +2068,7 @@ static void dmfe_HPNA_remote_cmd_chk(struct dmfe_board_info * db)
 
 
 
-static struct pci_device_id dmfe_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(dmfe_pci_tbl) = {
 	{ 0x1282, 0x9132, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_DM9132_ID },
 	{ 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_DM9102_ID },
 	{ 0x1282, 0x9100, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_DM9100_ID },
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -207,7 +207,7 @@ struct tulip_chip_table tulip_tbl[] = {
 };
 
 
-static struct pci_device_id tulip_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(tulip_pci_tbl) = {
 	{ 0x1011, 0x0009, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DC21140 },
 	{ 0x1011, 0x0019, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DC21143 },
 	{ 0x11AD, 0x0002, PCI_ANY_ID, PCI_ANY_ID, 0, 0, LC82C168 },
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -1783,7 +1783,7 @@ static u16 phy_read_1bit(unsigned long ioaddr, u32 chip_id)
 }
 
 
-static struct pci_device_id uli526x_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(uli526x_pci_tbl) = {
 	{ 0x10B9, 0x5261, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_ULI5261_ID },
 	{ 0x10B9, 0x5263, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_ULI5263_ID },
 	{ 0, }
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -218,7 +218,7 @@ enum chip_capability_flags {
 	CanHaveMII=1, HasBrokenTx=2, AlwaysFDX=4, FDXOnNoMII=8,
 };
 
-static const struct pci_device_id w840_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(w840_pci_tbl) = {
 	{ 0x1050, 0x0840, PCI_ANY_ID, 0x8153,     0, 0, 0 },
 	{ 0x1050, 0x0840, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
 	{ 0x11f6, 0x2011, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 2 },
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -144,7 +144,7 @@ static int link_status(struct xircom_private *card);
 
 
 
-static struct pci_device_id xircom_pci_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(xircom_pci_table) = {
 	{0x115D, 0x0003, PCI_ANY_ID, PCI_ANY_ID,},
 	{0,},
 };
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -215,7 +215,7 @@ static struct typhoon_card_info typhoon_card_info[] __devinitdata = {
  * bit 8 indicates if this is a (0) copper or (1) fiber card
  * bits 12-16 indicate card type: (0) client and (1) server
  */
-static struct pci_device_id typhoon_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(typhoon_pci_tbl) = {
 	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3CR990,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0,TYPHOON_TX },
 	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3CR990_TX_95,
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -266,7 +266,7 @@ enum rhine_quirks {
 /* Beware of PCI posted writes */
 #define IOSYNC	do { ioread8(ioaddr + StationAddr); } while (0)
 
-static const struct pci_device_id rhine_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(rhine_pci_tbl) = {
 	{ 0x1106, 0x3043, PCI_ANY_ID, PCI_ANY_ID, },	/* VT86C100A */
 	{ 0x1106, 0x3065, PCI_ANY_ID, PCI_ANY_ID, },	/* VT6102 */
 	{ 0x1106, 0x3106, PCI_ANY_ID, PCI_ANY_ID, },	/* 6105{,L,LOM} */
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -361,7 +361,7 @@ static struct velocity_info_tbl chip_info_table[] = {
  *	Describe the PCI device identifiers that we support in this
  *	device driver. Used for hotplug autoloading.
  */
-static const struct pci_device_id velocity_id_table[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(velocity_id_table) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_VIA, PCI_DEVICE_ID_VIA_612X) },
 	{ }
 };
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -35,7 +35,7 @@ char vmxnet3_driver_name[] = "vmxnet3";
  * PCI Device ID Table
  * Last entry must be all 0s
  */
-static const struct pci_device_id vmxnet3_pciid_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(vmxnet3_pciid_table) = {
 	{PCI_VDEVICE(VMWARE, PCI_DEVICE_ID_VMWARE_VMXNET3)},
 	{0}
 };
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -54,7 +54,7 @@ MODULE_LICENSE("Dual BSD/GPL");
 MODULE_DESCRIPTION("Neterion's X3100 Series 10GbE PCIe I/O"
 	"Virtualized Server Adapter");
 
-static struct pci_device_id vxge_id_table[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(vxge_id_table) = {
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_TITAN_WIN, PCI_ANY_ID,
 	PCI_ANY_ID},
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_TITAN_UNI, PCI_ANY_ID,
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -2050,7 +2050,7 @@ static int __init dscc4_setup(char *str)
 __setup("dscc4.setup=", dscc4_setup);
 #endif
 
-static struct pci_device_id dscc4_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(dscc4_pci_tbl) = {
 	{ PCI_VENDOR_ID_SIEMENS, PCI_DEVICE_ID_SIEMENS_DSCC4,
 	        PCI_ANY_ID, PCI_ANY_ID, },
 	{ 0,}
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -528,7 +528,7 @@ static int fst_debug_mask = { FST_DEBUG };
 /*
  *      PCI ID lookup table
  */
-static struct pci_device_id fst_pci_dev_id[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(fst_pci_dev_id) = {
 	{PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T2P, PCI_ANY_ID, 
 	 PCI_ANY_ID, 0, 0, FST_TYPE_T2P},
 
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -77,7 +77,7 @@
 
 static int LMC_PKT_BUF_SZ = 1542;
 
-static struct pci_device_id lmc_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(lmc_pci_tbl) = {
 	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_FAST,
 	  PCI_VENDOR_ID_LMC, PCI_ANY_ID },
 	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_FAST,
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -251,7 +251,7 @@ static char rcsid[] =
 #undef	PC300_DEBUG_RX
 #undef	PC300_DEBUG_OTHER
 
-static struct pci_device_id cpc_pci_dev_id[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(cpc_pci_dev_id) = {
 	/* PC300/RSV or PC300/X21, 2 chan */
 	{0x120e, 0x300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0x300},
 	/* PC300/RSV or PC300/X21, 1 chan */
--- a/drivers/net/wan/pc300too.c
+++ b/drivers/net/wan/pc300too.c
@@ -481,7 +481,7 @@ static int __devinit pc300_pci_init_one(struct pci_dev *pdev,
 
 
 
-static struct pci_device_id pc300_pci_tbl[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(pc300_pci_tbl) = {
 	{ PCI_VENDOR_ID_CYCLADES, PCI_DEVICE_ID_PC300_RX_1, PCI_ANY_ID,
 	  PCI_ANY_ID, 0, 0, 0 },
 	{ PCI_VENDOR_ID_CYCLADES, PCI_DEVICE_ID_PC300_RX_2, PCI_ANY_ID,
--- a/drivers/net/wan/pci200syn.c
+++ b/drivers/net/wan/pci200syn.c
@@ -417,7 +417,7 @@ static int __devinit pci200_pci_init_one(struct pci_dev *pdev,
 
 
 
-static struct pci_device_id pci200_pci_tbl[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(pci200_pci_tbl) = {
 	{ PCI_VENDOR_ID_PLX, PCI_DEVICE_ID_PLX_9050, PCI_VENDOR_ID_PLX,
 	  PCI_DEVICE_ID_PLX_PCI200SYN, 0, 0, 0 },
 	{ 0, }
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -814,7 +814,7 @@ static int __devinit wanxl_pci_init_one(struct pci_dev *pdev,
 	return 0;
 }
 
-static struct pci_device_id wanxl_pci_tbl[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(wanxl_pci_tbl) = {
 	{ PCI_VENDOR_ID_SBE, PCI_DEVICE_ID_SBE_WANXL100, PCI_ANY_ID,
 	  PCI_ANY_ID, 0, 0, 0 },
 	{ PCI_VENDOR_ID_SBE, PCI_DEVICE_ID_SBE_WANXL200, PCI_ANY_ID,
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -39,7 +39,7 @@ static unsigned int rx_ring_size __read_mostly = 16;
 module_param(tx_ring_size, uint, 0);
 module_param(rx_ring_size, uint, 0);
 
-static struct pci_device_id adm8211_pci_id_table[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(adm8211_pci_id_table) = {
 	/* ADMtek ADM8211 */
 	{ PCI_DEVICE(0x10B7, 0x6000) }, /* 3Com 3CRSHPW796 */
 	{ PCI_DEVICE(0x1200, 0x8201) }, /* ? */
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -57,7 +57,7 @@
 #define DRV_NAME "airo"
 
 #ifdef CONFIG_PCI
-static struct pci_device_id card_ids[] = {
+static DEFINE_PCI_DEVICE_TABLE(card_ids) = {
 	{ 0x14b9, 1, PCI_ANY_ID, PCI_ANY_ID, },
 	{ 0x14b9, 0x4500, PCI_ANY_ID, PCI_ANY_ID },
 	{ 0x14b9, 0x4800, PCI_ANY_ID, PCI_ANY_ID, },
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -83,7 +83,7 @@ MODULE_VERSION("0.6.0 (EXPERIMENTAL)");
 
 
 /* Known PCI ids */
-static const struct pci_device_id ath5k_pci_id_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(ath5k_pci_id_table) = {
 	{ PCI_VDEVICE(ATHEROS, 0x0207) }, /* 5210 early */
 	{ PCI_VDEVICE(ATHEROS, 0x0007) }, /* 5210 */
 	{ PCI_VDEVICE(ATHEROS, 0x0011) }, /* 5311 - this is on AHB bus !*/
--- a/drivers/net/wireless/ath/ath9k/pci.c
+++ b/drivers/net/wireless/ath/ath9k/pci.c
@@ -18,7 +18,7 @@
 #include <linux/pci.h>
 #include "ath9k.h"
 
-static struct pci_device_id ath_pci_id_table[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(ath_pci_id_table) = {
 	{ PCI_VDEVICE(ATHEROS, 0x0023) }, /* PCI   */
 	{ PCI_VDEVICE(ATHEROS, 0x0024) }, /* PCI-E */
 	{ PCI_VDEVICE(ATHEROS, 0x0027) }, /* PCI   */
--- a/drivers/net/wireless/atmel_pci.c
+++ b/drivers/net/wireless/atmel_pci.c
@@ -31,7 +31,7 @@ MODULE_DESCRIPTION("Support for Atmel at76c50x 802.11 wireless ethernet cards.")
 MODULE_LICENSE("GPL");
 MODULE_SUPPORTED_DEVICE("Atmel at76c506 PCI wireless cards");
 
-static struct pci_device_id card_ids[] = {
+static DEFINE_PCI_DEVICE_TABLE(card_ids) = {
 	{ 0x1114, 0x0506, PCI_ANY_ID, PCI_ANY_ID },
 	{ 0, }
 };
--- a/drivers/net/wireless/hostap/hostap_pci.c
+++ b/drivers/net/wireless/hostap/hostap_pci.c
@@ -39,7 +39,7 @@ struct hostap_pci_priv {
 /* FIX: do we need mb/wmb/rmb with memory operations? */
 
 
-static struct pci_device_id prism2_pci_id_table[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(prism2_pci_id_table) = {
 	/* Intersil Prism3 ISL3872 11Mb/s WLAN Controller */
 	{ 0x1260, 0x3872, PCI_ANY_ID, PCI_ANY_ID },
 	/* Intersil Prism2.5 ISL3874 11Mb/s WLAN Controller */
--- a/drivers/net/wireless/hostap/hostap_plx.c
+++ b/drivers/net/wireless/hostap/hostap_plx.c
@@ -60,7 +60,7 @@ struct hostap_plx_priv {
 
 #define PLXDEV(vendor,dev,str) { vendor, dev, PCI_ANY_ID, PCI_ANY_ID }
 
-static struct pci_device_id prism2_plx_id_table[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(prism2_plx_id_table) = {
 	PLXDEV(0x10b7, 0x7770, "3Com AirConnect PCI 777A"),
 	PLXDEV(0x111a, 0x1023, "Siemens SpeedStream SS1023"),
 	PLXDEV(0x126c, 0x8030, "Nortel emobility"),
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -6585,7 +6585,7 @@ static void ipw2100_shutdown(struct pci_dev *pci_dev)
 
 #define IPW2100_DEV_ID(x) { PCI_VENDOR_ID_INTEL, 0x1043, 0x8086, x }
 
-static struct pci_device_id ipw2100_pci_id_table[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(ipw2100_pci_id_table) = {
 	IPW2100_DEV_ID(0x2520),	/* IN 2100A mPCI 3A */
 	IPW2100_DEV_ID(0x2521),	/* IN 2100A mPCI 3B */
 	IPW2100_DEV_ID(0x2524),	/* IN 2100A mPCI 3B */
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -11524,7 +11524,7 @@ out:
 }
 
 /* PCI driver stuff */
-static struct pci_device_id card_ids[] = {
+static DEFINE_PCI_DEVICE_TABLE(card_ids) = {
 	{PCI_VENDOR_ID_INTEL, 0x1043, 0x8086, 0x2701, 0, 0, 0},
 	{PCI_VENDOR_ID_INTEL, 0x1043, 0x8086, 0x2702, 0, 0, 0},
 	{PCI_VENDOR_ID_INTEL, 0x1043, 0x8086, 0x2711, 0, 0, 0},
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -2849,7 +2849,7 @@ static struct iwl_cfg iwl3945_abg_cfg = {
 	.broken_powersave = true,
 };
 
-struct pci_device_id iwl3945_hw_card_ids[] = {
+DEFINE_PCI_DEVICE_TABLE(iwl3945_hw_card_ids) = {
 	{IWL_PCI_DEVICE(0x4222, 0x1005, iwl3945_bg_cfg)},
 	{IWL_PCI_DEVICE(0x4222, 0x1034, iwl3945_bg_cfg)},
 	{IWL_PCI_DEVICE(0x4222, 0x1044, iwl3945_bg_cfg)},
--- a/drivers/net/wireless/iwlwifi/iwl-3945.h
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.h
@@ -37,7 +37,7 @@
 #include <net/ieee80211_radiotap.h>
 
 /* Hardware specific file defines the PCI IDs table for that hardware module */
-extern struct pci_device_id iwl3945_hw_card_ids[];
+extern const struct pci_device_id iwl3945_hw_card_ids[];
 
 #include "iwl-csr.h"
 #include "iwl-prph.h"
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -3766,7 +3766,7 @@ static void __devexit iwl_pci_remove(struct pci_dev *pdev)
  *****************************************************************************/
 
 /* Hardware specific file defines the PCI IDs table for that hardware module */
-static struct pci_device_id iwl_hw_card_ids[] = {
+static DEFINE_PCI_DEVICE_TABLE(iwl_hw_card_ids) = {
 #ifdef CONFIG_IWL4965
 	{IWL_PCI_DEVICE(0x4229, PCI_ANY_ID, iwl4965_agn_cfg)},
 	{IWL_PCI_DEVICE(0x4230, PCI_ANY_ID, iwl4965_agn_cfg)},
--- a/drivers/net/wireless/orinoco/orinoco_nortel.c
+++ b/drivers/net/wireless/orinoco/orinoco_nortel.c
@@ -274,7 +274,7 @@ static void __devexit orinoco_nortel_remove_one(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
-static struct pci_device_id orinoco_nortel_id_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(orinoco_nortel_id_table) = {
 	/* Nortel emobility PCI */
 	{0x126c, 0x8030, PCI_ANY_ID, PCI_ANY_ID,},
 	/* Symbol LA-4123 PCI */
--- a/drivers/net/wireless/orinoco/orinoco_pci.c
+++ b/drivers/net/wireless/orinoco/orinoco_pci.c
@@ -212,7 +212,7 @@ static void __devexit orinoco_pci_remove_one(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
-static struct pci_device_id orinoco_pci_id_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(orinoco_pci_id_table) = {
 	/* Intersil Prism 3 */
 	{0x1260, 0x3872, PCI_ANY_ID, PCI_ANY_ID,},
 	/* Intersil Prism 2.5 */
--- a/drivers/net/wireless/orinoco/orinoco_plx.c
+++ b/drivers/net/wireless/orinoco/orinoco_plx.c
@@ -310,7 +310,7 @@ static void __devexit orinoco_plx_remove_one(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
-static struct pci_device_id orinoco_plx_id_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(orinoco_plx_id_table) = {
 	{0x111a, 0x1023, PCI_ANY_ID, PCI_ANY_ID,},	/* Siemens SpeedStream SS1023 */
 	{0x1385, 0x4100, PCI_ANY_ID, PCI_ANY_ID,},	/* Netgear MA301 */
 	{0x15e8, 0x0130, PCI_ANY_ID, PCI_ANY_ID,},	/* Correga  - does this work? */
--- a/drivers/net/wireless/orinoco/orinoco_tmd.c
+++ b/drivers/net/wireless/orinoco/orinoco_tmd.c
@@ -203,7 +203,7 @@ static void __devexit orinoco_tmd_remove_one(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
-static struct pci_device_id orinoco_tmd_id_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(orinoco_tmd_id_table) = {
 	{0x15e8, 0x0131, PCI_ANY_ID, PCI_ANY_ID,},      /* NDC and OEMs, e.g. pheecom */
 	{0,},
 };
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -31,7 +31,7 @@ MODULE_LICENSE("GPL");
 MODULE_ALIAS("prism54pci");
 MODULE_FIRMWARE("isl3886pci");
 
-static struct pci_device_id p54p_table[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(p54p_table) = {
 	/* Intersil PRISM Duette/Prism GT Wireless LAN adapter */
 	{ PCI_DEVICE(0x1260, 0x3890) },
 	/* 3COM 3CRWE154G72 Wireless LAN adapter */
--- a/drivers/net/wireless/prism54/islpci_hotplug.c
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c
@@ -39,7 +39,7 @@ module_param(init_pcitm, int, 0);
  * driver_data
  * If you have an update for this please contact prism54-devel@prism54.org
  * The latest list can be found at http://prism54.org/supported_cards.php */
-static const struct pci_device_id prism54_id_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(prism54_id_tbl) = {
 	/* Intersil PRISM Duette/Prism GT Wireless LAN adapter */
 	{
 	 0x1260, 0x3890,
--- a/drivers/net/wireless/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/rt2x00/rt2400pci.c
@@ -1642,7 +1642,7 @@ static const struct rt2x00_ops rt2400pci_ops = {
 /*
  * RT2400pci module information.
  */
-static struct pci_device_id rt2400pci_device_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(rt2400pci_device_table) = {
 	{ PCI_DEVICE(0x1814, 0x0101), PCI_DEVICE_DATA(&rt2400pci_ops) },
 	{ 0, }
 };
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -1940,7 +1940,7 @@ static const struct rt2x00_ops rt2500pci_ops = {
 /*
  * RT2500pci module information.
  */
-static struct pci_device_id rt2500pci_device_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(rt2500pci_device_table) = {
 	{ PCI_DEVICE(0x1814, 0x0201), PCI_DEVICE_DATA(&rt2500pci_ops) },
 	{ 0, }
 };
--- a/drivers/net/wireless/rt2x00/rt2800pci.c
+++ b/drivers/net/wireless/rt2x00/rt2800pci.c
@@ -1208,7 +1208,7 @@ static const struct rt2x00_ops rt2800pci_ops = {
 /*
  * RT2800pci module information.
  */
-static struct pci_device_id rt2800pci_device_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(rt2800pci_device_table) = {
 	{ PCI_DEVICE(0x1462, 0x891a), PCI_DEVICE_DATA(&rt2800pci_ops) },
 	{ PCI_DEVICE(0x1432, 0x7708), PCI_DEVICE_DATA(&rt2800pci_ops) },
 	{ PCI_DEVICE(0x1432, 0x7727), PCI_DEVICE_DATA(&rt2800pci_ops) },
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -2807,7 +2807,7 @@ static const struct rt2x00_ops rt61pci_ops = {
 /*
  * RT61pci module information.
  */
-static struct pci_device_id rt61pci_device_table[] = {
+static DEFINE_PCI_DEVICE_TABLE(rt61pci_device_table) = {
 	/* RT2561s */
 	{ PCI_DEVICE(0x1814, 0x0301), PCI_DEVICE_DATA(&rt61pci_ops) },
 	/* RT2561 v2 */
--- a/drivers/net/wireless/rtl818x/rtl8180_dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180_dev.c
@@ -33,7 +33,7 @@ MODULE_AUTHOR("Andrea Merello <andreamrl@tiscali.it>");
 MODULE_DESCRIPTION("RTL8180 / RTL8185 PCI wireless driver");
 MODULE_LICENSE("GPL");
 
-static struct pci_device_id rtl8180_table[] __devinitdata = {
+static DEFINE_PCI_DEVICE_TABLE(rtl8180_table) = {
 	/* rtl8185 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8185) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BELKIN, 0x700f) },
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -237,7 +237,7 @@ static const struct pci_id_info pci_id_tbl[] = {
 	{ }
 };
 
-static const struct pci_device_id yellowfin_pci_tbl[] = {
+static DEFINE_PCI_DEVICE_TABLE(yellowfin_pci_tbl) = {
 	{ 0x1000, 0x0702, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ 0x1000, 0x0701, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
 	{ }
