From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 20/39] net: remove DEFINE_PCI_DEVICE_TABLE macro
Date: Tue, 03 Dec 2013 08:19:25 +0900
Message-ID: <002901ceefb4$f1191e30$d34b5a90$%han@samsung.com>
References: <001501ceefb1$69c96820$3d5c3860$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'David Miller' <davem@davemloft.net>, netdev@vger.kernel.org
To: 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <001501ceefb1$69c96820$3d5c3860$%han@samsung.com>
Content-language: ko
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't use DEFINE_PCI_DEVICE_TABLE macro, because this macro
is not preferred.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/arcnet/com20020-pci.c                    |    2 +-
 drivers/net/can/c_can/c_can_pci.c                    |    2 +-
 drivers/net/can/pch_can.c                            |    2 +-
 drivers/net/can/sja1000/ems_pci.c                    |    2 +-
 drivers/net/can/sja1000/kvaser_pci.c                 |    2 +-
 drivers/net/can/sja1000/peak_pci.c                   |    2 +-
 drivers/net/can/sja1000/plx_pci.c                    |    2 +-
 drivers/net/ethernet/3com/3c59x.c                    |    2 +-
 drivers/net/ethernet/3com/typhoon.c                  |    2 +-
 drivers/net/ethernet/8390/ne2k-pci.c                 |    2 +-
 drivers/net/ethernet/adaptec/starfire.c              |    2 +-
 drivers/net/ethernet/alteon/acenic.c                 |    2 +-
 drivers/net/ethernet/amd/amd8111e.c                  |    2 +-
 drivers/net/ethernet/amd/pcnet32.c                   |    2 +-
 drivers/net/ethernet/atheros/alx/main.c              |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c      |    2 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c      |    2 +-
 drivers/net/ethernet/atheros/atlx/atl1.c             |    2 +-
 drivers/net/ethernet/atheros/atlx/atl2.c             |    2 +-
 drivers/net/ethernet/broadcom/b44.c                  |    2 +-
 drivers/net/ethernet/broadcom/bnx2.c                 |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c     |    2 +-
 drivers/net/ethernet/broadcom/tg3.c                  |    6 +++---
 drivers/net/ethernet/brocade/bna/bnad.c              |    2 +-
 drivers/net/ethernet/chelsio/cxgb/subr.c             |    2 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c      |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c      |    2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c  |    2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c          |    2 +-
 drivers/net/ethernet/dec/tulip/de2104x.c             |    2 +-
 drivers/net/ethernet/dec/tulip/de4x5.c               |    2 +-
 drivers/net/ethernet/dec/tulip/dmfe.c                |    2 +-
 drivers/net/ethernet/dec/tulip/tulip_core.c          |    4 ++--
 drivers/net/ethernet/dec/tulip/uli526x.c             |    2 +-
 drivers/net/ethernet/dec/tulip/winbond-840.c         |    2 +-
 drivers/net/ethernet/dec/tulip/xircom_cb.c           |    2 +-
 drivers/net/ethernet/dlink/dl2k.h                    |    2 +-
 drivers/net/ethernet/dlink/sundance.c                |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c          |    2 +-
 drivers/net/ethernet/fealnx.c                        |    2 +-
 drivers/net/ethernet/hp/hp100.c                      |    2 +-
 drivers/net/ethernet/icplus/ipg.c                    |    2 +-
 drivers/net/ethernet/intel/e100.c                    |    2 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c        |    2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c           |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c          |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c            |    2 +-
 drivers/net/ethernet/intel/igbvf/netdev.c            |    2 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c          |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c        |    2 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c    |    2 +-
 drivers/net/ethernet/jme.c                           |    2 +-
 drivers/net/ethernet/marvell/skge.c                  |    2 +-
 drivers/net/ethernet/marvell/sky2.c                  |    2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c            |    2 +-
 drivers/net/ethernet/micrel/ksz884x.c                |    2 +-
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c     |    2 +-
 drivers/net/ethernet/natsemi/natsemi.c               |    2 +-
 drivers/net/ethernet/natsemi/ns83820.c               |    2 +-
 drivers/net/ethernet/neterion/s2io.c                 |    2 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c       |    2 +-
 drivers/net/ethernet/nvidia/forcedeth.c              |    2 +-
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c |    2 +-
 drivers/net/ethernet/packetengines/hamachi.c         |    2 +-
 drivers/net/ethernet/packetengines/yellowfin.c       |    2 +-
 drivers/net/ethernet/pasemi/pasemi_mac.c             |    2 +-
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c |    2 +-
 drivers/net/ethernet/qlogic/qla3xxx.c                |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c     |    2 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c         |    2 +-
 drivers/net/ethernet/rdc/r6040.c                     |    2 +-
 drivers/net/ethernet/realtek/8139cp.c                |    2 +-
 drivers/net/ethernet/realtek/8139too.c               |    2 +-
 drivers/net/ethernet/realtek/r8169.c                 |    2 +-
 drivers/net/ethernet/sfc/efx.c                       |    2 +-
 drivers/net/ethernet/sgi/ioc3-eth.c                  |    2 +-
 drivers/net/ethernet/silan/sc92031.c                 |    2 +-
 drivers/net/ethernet/sis/sis190.c                    |    2 +-
 drivers/net/ethernet/sis/sis900.c                    |    2 +-
 drivers/net/ethernet/smsc/epic100.c                  |    2 +-
 drivers/net/ethernet/smsc/smsc9420.c                 |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c     |    2 +-
 drivers/net/ethernet/sun/cassini.c                   |    2 +-
 drivers/net/ethernet/sun/niu.c                       |    2 +-
 drivers/net/ethernet/sun/sungem.c                    |    2 +-
 drivers/net/ethernet/sun/sunhme.c                    |    2 +-
 drivers/net/ethernet/tehuti/tehuti.c                 |    2 +-
 drivers/net/ethernet/ti/tlan.c                       |    2 +-
 drivers/net/ethernet/toshiba/spider_net.c            |    2 +-
 drivers/net/ethernet/toshiba/tc35815.c               |    2 +-
 drivers/net/ethernet/via/via-rhine.c                 |    2 +-
 drivers/net/ethernet/via/via-velocity.c              |    2 +-
 drivers/net/fddi/defxx.c                             |    2 +-
 drivers/net/fddi/skfp/skfddi.c                       |    2 +-
 drivers/net/hippi/rrunner.c                          |    2 +-
 drivers/net/irda/donauboe.c                          |    2 +-
 drivers/net/irda/via-ircc.c                          |    2 +-
 drivers/net/irda/vlsi_ir.c                           |    2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c                    |    2 +-
 drivers/net/wan/dscc4.c                              |    2 +-
 drivers/net/wan/farsync.c                            |    2 +-
 drivers/net/wan/lmc/lmc_main.c                       |    2 +-
 drivers/net/wan/pc300too.c                           |    2 +-
 drivers/net/wan/pci200syn.c                          |    2 +-
 drivers/net/wan/wanxl.c                              |    2 +-
 drivers/net/wireless/adm8211.c                       |    2 +-
 drivers/net/wireless/airo.c                          |    2 +-
 drivers/net/wireless/ath/ath10k/pci.c                |    2 +-
 drivers/net/wireless/ath/ath5k/led.c                 |    2 +-
 drivers/net/wireless/ath/ath5k/pci.c                 |    2 +-
 drivers/net/wireless/ath/ath9k/pci.c                 |    2 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c          |    2 +-
 drivers/net/wireless/atmel_pci.c                     |    2 +-
 drivers/net/wireless/hostap/hostap_pci.c             |    2 +-
 drivers/net/wireless/hostap/hostap_plx.c             |    2 +-
 drivers/net/wireless/ipw2x00/ipw2100.c               |    2 +-
 drivers/net/wireless/ipw2x00/ipw2200.c               |    2 +-
 drivers/net/wireless/iwlegacy/3945.c                 |    2 +-
 drivers/net/wireless/iwlegacy/4965-mac.c             |    2 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c              |    2 +-
 drivers/net/wireless/mwifiex/pcie.c                  |    2 +-
 drivers/net/wireless/mwl8k.c                         |    2 +-
 drivers/net/wireless/orinoco/orinoco_nortel.c        |    2 +-
 drivers/net/wireless/orinoco/orinoco_pci.c           |    2 +-
 drivers/net/wireless/orinoco/orinoco_plx.c           |    2 +-
 drivers/net/wireless/orinoco/orinoco_tmd.c           |    2 +-
 drivers/net/wireless/p54/p54pci.c                    |    2 +-
 drivers/net/wireless/prism54/islpci_hotplug.c        |    2 +-
 drivers/net/wireless/rt2x00/rt2400pci.c              |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c              |    2 +-
 drivers/net/wireless/rt2x00/rt2800pci.c              |    2 +-
 drivers/net/wireless/rt2x00/rt61pci.c                |    2 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c           |    2 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c          |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c          |    2 +-
 135 files changed, 138 insertions(+), 138 deletions(-)

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
diff --git a/drivers/net/can/c_can/c_can_pci.c b/drivers/net/can/c_can/c_can_pci.c
index bce0be5..9e08fc63 100644
--- a/drivers/net/can/c_can/c_can_pci.c
+++ b/drivers/net/can/c_can/c_can_pci.c
@@ -199,7 +199,7 @@ static struct c_can_pci_data c_can_sta2x11= {
 	PCI_DEVICE(_vend, _dev),			\
 	.driver_data = (unsigned long)&_driverdata,	\
 }
-static DEFINE_PCI_DEVICE_TABLE(c_can_pci_tbl) = {
+static const struct pci_device_id c_can_pci_tbl[] = {
 	C_CAN_ID(PCI_VENDOR_ID_STMICRO, PCI_DEVICE_ID_STMICRO_CAN,
 		 c_can_sta2x11),
 	{},
diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 5f0e9b3..d1b2699 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -196,7 +196,7 @@ static const struct can_bittiming_const pch_can_bittiming_const = {
 	.brp_inc = 1,
 };
 
-static DEFINE_PCI_DEVICE_TABLE(pch_pci_tbl) = {
+static const struct pci_device_id pch_pci_tbl[] = {
 	{PCI_VENDOR_ID_INTEL, 0x8818, PCI_ANY_ID, PCI_ANY_ID,},
 	{0,}
 };
diff --git a/drivers/net/can/sja1000/ems_pci.c b/drivers/net/can/sja1000/ems_pci.c
index 8359213..8f5b22a 100644
--- a/drivers/net/can/sja1000/ems_pci.c
+++ b/drivers/net/can/sja1000/ems_pci.c
@@ -102,7 +102,7 @@ struct ems_pci_card {
 
 #define EMS_PCI_BASE_SIZE  4096 /* size of controller area */
 
-static DEFINE_PCI_DEVICE_TABLE(ems_pci_tbl) = {
+static const struct pci_device_id ems_pci_tbl[] = {
 	/* CPC-PCI v1 */
 	{PCI_VENDOR_ID_SIEMENS, 0x2104, PCI_ANY_ID, PCI_ANY_ID,},
 	/* CPC-PCI v2 */
diff --git a/drivers/net/can/sja1000/kvaser_pci.c b/drivers/net/can/sja1000/kvaser_pci.c
index 087b13b..b654112 100644
--- a/drivers/net/can/sja1000/kvaser_pci.c
+++ b/drivers/net/can/sja1000/kvaser_pci.c
@@ -108,7 +108,7 @@ struct kvaser_pci {
 #define KVASER_PCI_VENDOR_ID2     0x1a07    /* the PCI device and vendor IDs */
 #define KVASER_PCI_DEVICE_ID2     0x0008
 
-static DEFINE_PCI_DEVICE_TABLE(kvaser_pci_tbl) = {
+static const struct pci_device_id kvaser_pci_tbl[] = {
 	{KVASER_PCI_VENDOR_ID1, KVASER_PCI_DEVICE_ID1, PCI_ANY_ID, PCI_ANY_ID,},
 	{KVASER_PCI_VENDOR_ID2, KVASER_PCI_DEVICE_ID2, PCI_ANY_ID, PCI_ANY_ID,},
 	{ 0,}
diff --git a/drivers/net/can/sja1000/peak_pci.c b/drivers/net/can/sja1000/peak_pci.c
index 065ca49..63d6ff0 100644
--- a/drivers/net/can/sja1000/peak_pci.c
+++ b/drivers/net/can/sja1000/peak_pci.c
@@ -77,7 +77,7 @@ static const u16 peak_pci_icr_masks[PEAK_PCI_CHAN_MAX] = {
 	0x02, 0x01, 0x40, 0x80
 };
 
-static DEFINE_PCI_DEVICE_TABLE(peak_pci_tbl) = {
+static const struct pci_device_id peak_pci_tbl[] = {
 	{PEAK_PCI_VENDOR_ID, PEAK_PCI_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
 	{PEAK_PCI_VENDOR_ID, PEAK_PCIE_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
 	{PEAK_PCI_VENDOR_ID, PEAK_MPCI_DEVICE_ID, PCI_ANY_ID, PCI_ANY_ID,},
diff --git a/drivers/net/can/sja1000/plx_pci.c b/drivers/net/can/sja1000/plx_pci.c
index f9b4f81..07899ce 100644
--- a/drivers/net/can/sja1000/plx_pci.c
+++ b/drivers/net/can/sja1000/plx_pci.c
@@ -234,7 +234,7 @@ static struct plx_pci_card_info plx_pci_card_info_cti = {
 	/* based on PLX9030 */
 };
 
-static DEFINE_PCI_DEVICE_TABLE(plx_pci_tbl) = {
+static const struct pci_device_id plx_pci_tbl[] = {
 	{
 		/* Adlink PCI-7841/cPCI-7841 */
 		ADLINK_PCI_VENDOR_ID, ADLINK_PCI_DEVICE_ID,
diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index ad5272b..2c07f16 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -375,7 +375,7 @@ static struct vortex_chip_info {
 };
 
 
-static DEFINE_PCI_DEVICE_TABLE(vortex_pci_tbl) = {
+static const struct pci_device_id vortex_pci_tbl[] = {
 	{ 0x10B7, 0x5900, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C590 },
 	{ 0x10B7, 0x5920, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C592 },
 	{ 0x10B7, 0x5970, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C597 },
diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 465cc71..82df582 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -203,7 +203,7 @@ static struct typhoon_card_info typhoon_card_info[] = {
  * bit 8 indicates if this is a (0) copper or (1) fiber card
  * bits 12-16 indicate card type: (0) client and (1) server
  */
-static DEFINE_PCI_DEVICE_TABLE(typhoon_pci_tbl) = {
+static const struct pci_device_id typhoon_pci_tbl[] = {
 	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3CR990,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0,TYPHOON_TX },
 	{ PCI_VENDOR_ID_3COM, PCI_DEVICE_ID_3COM_3CR990_TX_95,
diff --git a/drivers/net/ethernet/8390/ne2k-pci.c b/drivers/net/ethernet/8390/ne2k-pci.c
index fc14a85..a52e577 100644
--- a/drivers/net/ethernet/8390/ne2k-pci.c
+++ b/drivers/net/ethernet/8390/ne2k-pci.c
@@ -135,7 +135,7 @@ static struct {
 };
 
 
-static DEFINE_PCI_DEVICE_TABLE(ne2k_pci_tbl) = {
+static const struct pci_device_id ne2k_pci_tbl[] = {
 	{ 0x10ec, 0x8029, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_RealTek_RTL_8029 },
 	{ 0x1050, 0x0940, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_Winbond_89C940 },
 	{ 0x11f6, 0x1401, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_Compex_RL2000 },
diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index 171d73c..0a45df3 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -285,7 +285,7 @@ enum chipset {
 	CH_6915 = 0,
 };
 
-static DEFINE_PCI_DEVICE_TABLE(starfire_pci_tbl) = {
+static const struct pci_device_id starfire_pci_tbl[] = {
 	{ PCI_VDEVICE(ADAPTEC, 0x6915), CH_6915 },
 	{ 0, }
 };
diff --git a/drivers/net/ethernet/alteon/acenic.c b/drivers/net/ethernet/alteon/acenic.c
index 219be1b..b9a7482 100644
--- a/drivers/net/ethernet/alteon/acenic.c
+++ b/drivers/net/ethernet/alteon/acenic.c
@@ -132,7 +132,7 @@
 #define PCI_DEVICE_ID_SGI_ACENIC	0x0009
 #endif
 
-static DEFINE_PCI_DEVICE_TABLE(acenic_pci_tbl) = {
+static const struct pci_device_id acenic_pci_tbl[] = {
 	{ PCI_VENDOR_ID_ALTEON, PCI_DEVICE_ID_ALTEON_ACENIC_FIBRE,
 	  PCI_ANY_ID, PCI_ANY_ID, PCI_CLASS_NETWORK_ETHERNET << 8, 0xffff00, },
 	{ PCI_VENDOR_ID_ALTEON, PCI_DEVICE_ID_ALTEON_ACENIC_COPPER,
diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index d042511..7118a6d 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -112,7 +112,7 @@ MODULE_PARM_DESC(coalesce, "Enable or Disable interrupt coalescing, 1: Enable, 0
 module_param_array(dynamic_ipg, bool, NULL, 0);
 MODULE_PARM_DESC(dynamic_ipg, "Enable or Disable dynamic IPG, 1: Enable, 0: Disable");
 
-static DEFINE_PCI_DEVICE_TABLE(amd8111e_pci_tbl) = {
+static const struct pci_device_id amd8111e_pci_tbl[] = {
 
 	{ PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD8111E_7462,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 38492e0..e1979a8 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -61,7 +61,7 @@ static const char *const version =
 /*
  * PCI device identifiers for "new style" Linux PCI Device Drivers
  */
-static DEFINE_PCI_DEVICE_TABLE(pcnet32_pci_tbl) = {
+static const struct pci_device_id pcnet32_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_LANCE_HOME), },
 	{ PCI_DEVICE(PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_LANCE), },
 
diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index c3c4c26..f6e3710 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -1482,7 +1482,7 @@ static const struct pci_error_handlers alx_err_handlers = {
 	.resume         = alx_pci_error_resume,
 };
 
-static DEFINE_PCI_DEVICE_TABLE(alx_pci_tbl) = {
+static const struct pci_device_id alx_pci_tbl[] = {
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8161),
 	  .driver_data = ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_E2200),
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index a36a760..0d65d4d 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -34,7 +34,7 @@ char atl1c_driver_version[] = ATL1C_DRV_VERSION;
  * { Vendor ID, Device ID, SubVendor ID, SubDevice ID,
  *   Class, Class Mask, private data (not used) }
  */
-static DEFINE_PCI_DEVICE_TABLE(atl1c_pci_tbl) = {
+static const struct pci_device_id atl1c_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, PCI_DEVICE_ID_ATTANSIC_L1C)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, PCI_DEVICE_ID_ATTANSIC_L2C)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, PCI_DEVICE_ID_ATHEROS_L2C_B)},
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 7a73f3a..b76ed5f 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -35,7 +35,7 @@ char atl1e_driver_version[] = DRV_VERSION;
  * { Vendor ID, Device ID, SubVendor ID, SubDevice ID,
  *   Class, Class Mask, private data (not used) }
  */
-static DEFINE_PCI_DEVICE_TABLE(atl1e_pci_tbl) = {
+static const struct pci_device_id atl1e_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, PCI_DEVICE_ID_ATTANSIC_L1E)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, 0x1066)},
 	/* required last entry */
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 538211d..d88117b 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -235,7 +235,7 @@ static void atl1_check_options(struct atl1_adapter *adapter)
 /*
  * atl1_pci_tbl - PCI Device ID Table
  */
-static DEFINE_PCI_DEVICE_TABLE(atl1_pci_tbl) = {
+static const struct pci_device_id atl1_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, PCI_DEVICE_ID_ATTANSIC_L1)},
 	/* required last entry */
 	{0,}
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 265ce1b..d48d7d3 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -64,7 +64,7 @@ MODULE_VERSION(ATL2_DRV_VERSION);
 /*
  * atl2_pci_tbl - PCI Device ID Table
  */
-static DEFINE_PCI_DEVICE_TABLE(atl2_pci_tbl) = {
+static const struct pci_device_id atl2_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, PCI_DEVICE_ID_ATTANSIC_L2)},
 	/* required last entry */
 	{0,}
diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 90e54d5..51db1da 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -103,7 +103,7 @@ MODULE_PARM_DESC(b44_debug, "B44 bitmapped debugging message enable value");
 
 
 #ifdef CONFIG_B44_PCI
-static DEFINE_PCI_DEVICE_TABLE(b44_pci_tbl) = {
+static const struct pci_device_id b44_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_BCM4401) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_BCM4401B0) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_BCM4401B1) },
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index d9980ad..4b027b3 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -120,7 +120,7 @@ static struct {
 	{ "Broadcom NetXtreme II BCM5716 1000Base-SX" },
 	};
 
-static DEFINE_PCI_DEVICE_TABLE(bnx2_pci_tbl) = {
+static const struct pci_device_id bnx2_pci_tbl[] = {
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5706,
 	  PCI_VENDOR_ID_HP, 0x3101, 0, 0, NC370T },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5706,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 814d0ec..b89f527 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -247,7 +247,7 @@ static struct {
 #define PCI_DEVICE_ID_NX2_57811_VF	CHIP_NUM_57811_VF
 #endif
 
-static DEFINE_PCI_DEVICE_TABLE(bnx2x_pci_tbl) = {
+static const struct pci_device_id bnx2x_pci_tbl[] = {
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57710), BCM57710 },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57711), BCM57711 },
 	{ PCI_VDEVICE(BROADCOM, PCI_DEVICE_ID_NX2_57711E), BCM57711E },
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index a9e0684..9778d86 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -234,7 +234,7 @@ MODULE_PARM_DESC(tg3_debug, "Tigon3 bitmapped debugging message enable value");
 #define TG3_DRV_DATA_FLAG_10_100_ONLY	0x0001
 #define TG3_DRV_DATA_FLAG_5705_10_100	0x0002
 
-static DEFINE_PCI_DEVICE_TABLE(tg3_pci_tbl) = {
+static const struct pci_device_id tg3_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5700)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5701)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5702)},
@@ -15732,7 +15732,7 @@ static inline u32 tg3_rx_ret_ring_size(struct tg3 *tp)
 		return TG3_RX_RET_MAX_SIZE_5705;
 }
 
-static DEFINE_PCI_DEVICE_TABLE(tg3_write_reorder_chipsets) = {
+static const struct pci_device_id tg3_write_reorder_chipsets[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_FE_GATE_700C) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_8131_BRIDGE) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_VIA, PCI_DEVICE_ID_VIA_8385_0) },
@@ -16984,7 +16984,7 @@ static int tg3_do_test_dma(struct tg3 *tp, u32 *buf, dma_addr_t buf_dma,
 
 #define TEST_BUFFER_SIZE	0x2000
 
-static DEFINE_PCI_DEVICE_TABLE(tg3_dma_wait_state_chipsets) = {
+static const struct pci_device_id tg3_dma_wait_state_chipsets[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_APPLE, PCI_DEVICE_ID_APPLE_UNI_N_PCI15) },
 	{ },
 };
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 248bc37..d9c8010 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3566,7 +3566,7 @@ bnad_pci_remove(struct pci_dev *pdev)
 	free_netdev(netdev);
 }
 
-static DEFINE_PCI_DEVICE_TABLE(bnad_pci_id_table) = {
+static const struct pci_device_id bnad_pci_id_table[] = {
 	{
 		PCI_DEVICE(PCI_VENDOR_ID_BROCADE,
 			PCI_DEVICE_ID_BROCADE_CT),
diff --git a/drivers/net/ethernet/chelsio/cxgb/subr.c b/drivers/net/ethernet/chelsio/cxgb/subr.c
index e0a03a3..5a70cee 100644
--- a/drivers/net/ethernet/chelsio/cxgb/subr.c
+++ b/drivers/net/ethernet/chelsio/cxgb/subr.c
@@ -523,7 +523,7 @@ static const struct board_info t1_board[] = {
 
 };
 
-DEFINE_PCI_DEVICE_TABLE(t1_pci_tbl) = {
+const struct pci_device_id t1_pci_tbl[] = {
 	CH_DEVICE(8, 0, CH_BRD_T110_1CU),
 	CH_DEVICE(8, 1, CH_BRD_T110_1CU),
 	CH_DEVICE(7, 0, CH_BRD_N110_1F),
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 45d7733..ea8c76f 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -85,7 +85,7 @@ enum {
 #define CH_DEVICE(devid, idx) \
 	{ PCI_VENDOR_ID_CHELSIO, devid, PCI_ANY_ID, PCI_ANY_ID, 0, 0, idx }
 
-static DEFINE_PCI_DEVICE_TABLE(cxgb3_pci_tbl) = {
+static const struct pci_device_id cxgb3_pci_tbl[] = {
 	CH_DEVICE(0x20, 0),	/* PE9000 */
 	CH_DEVICE(0x21, 1),	/* T302E */
 	CH_DEVICE(0x22, 2),	/* T310E */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 8b929ee..2e4adfa 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -211,7 +211,7 @@ struct filter_entry {
 
 #define CH_DEVICE(devid, data) { PCI_VDEVICE(CHELSIO, devid), (data) }
 
-static DEFINE_PCI_DEVICE_TABLE(cxgb4_pci_tbl) = {
+static const struct pci_device_id cxgb4_pci_tbl[] = {
 	CH_DEVICE(0xa000, 0),  /* PE10K */
 	CH_DEVICE(0x4001, -1),
 	CH_DEVICE(0x4002, -1),
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 5f90ec5..4493c0f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2905,7 +2905,7 @@ static void cxgb4vf_pci_shutdown(struct pci_dev *pdev)
 #define CH_DEVICE(devid, idx) \
 	{ PCI_VENDOR_ID_CHELSIO, devid, PCI_ANY_ID, PCI_ANY_ID, 0, 0, idx }
 
-static DEFINE_PCI_DEVICE_TABLE(cxgb4vf_pci_tbl) = {
+static const struct pci_device_id cxgb4vf_pci_tbl[] = {
 	CH_DEVICE(0xb000, 0),	/* PE10K FPGA */
 	CH_DEVICE(0x4800, 0),	/* T440-dbg */
 	CH_DEVICE(0x4801, 0),	/* T420-cr */
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index ff78dfa..79f5446 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -59,7 +59,7 @@
 #define PCI_DEVICE_ID_CISCO_VIC_ENET_VF      0x0071  /* enet SRIOV VF */
 
 /* Supported devices */
-static DEFINE_PCI_DEVICE_TABLE(enic_id_table) = {
+static const struct pci_device_id enic_id_table[] = {
 	{ PCI_VDEVICE(CISCO, PCI_DEVICE_ID_CISCO_VIC_ENET) },
 	{ PCI_VDEVICE(CISCO, PCI_DEVICE_ID_CISCO_VIC_ENET_DYN) },
 	{ PCI_VDEVICE(CISCO, PCI_DEVICE_ID_CISCO_VIC_ENET_VF) },
diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
index 38148b0..a02ecc4 100644
--- a/drivers/net/ethernet/dec/tulip/de2104x.c
+++ b/drivers/net/ethernet/dec/tulip/de2104x.c
@@ -340,7 +340,7 @@ static void de21041_media_timer (unsigned long data);
 static unsigned int de_ok_to_advertise (struct de_private *de, u32 new_media);
 
 
-static DEFINE_PCI_DEVICE_TABLE(de_pci_tbl) = {
+static const struct pci_device_id de_pci_tbl[] = {
 	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_PLUS,
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index c05b66d..1f8f0af 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -2328,7 +2328,7 @@ static void de4x5_pci_remove(struct pci_dev *pdev)
 	pci_disable_device (pdev);
 }
 
-static DEFINE_PCI_DEVICE_TABLE(de4x5_pci_tbl) = {
+static const struct pci_device_id de4x5_pci_tbl[] = {
         { PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP,
           PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
         { PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_PLUS,
diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index 5ad9e3e..4120905 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -2096,7 +2096,7 @@ static void dmfe_HPNA_remote_cmd_chk(struct dmfe_board_info * db)
 
 
 
-static DEFINE_PCI_DEVICE_TABLE(dmfe_pci_tbl) = {
+static const struct pci_device_id dmfe_pci_tbl[] = {
 	{ 0x1282, 0x9132, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_DM9132_ID },
 	{ 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_DM9102_ID },
 	{ 0x1282, 0x9100, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_DM9100_ID },
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index add05f1..0561981 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -207,7 +207,7 @@ struct tulip_chip_table tulip_tbl[] = {
 };
 
 
-static DEFINE_PCI_DEVICE_TABLE(tulip_pci_tbl) = {
+static const struct pci_device_id tulip_pci_tbl[] = {
 	{ 0x1011, 0x0009, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DC21140 },
 	{ 0x1011, 0x0019, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DC21143 },
 	{ 0x11AD, 0x0002, PCI_ANY_ID, PCI_ANY_ID, 0, 0, LC82C168 },
@@ -1294,7 +1294,7 @@ static const struct net_device_ops tulip_netdev_ops = {
 #endif
 };
 
-DEFINE_PCI_DEVICE_TABLE(early_486_chipsets) = {
+const struct pci_device_id early_486_chipsets[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82424) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, PCI_DEVICE_ID_SI_496) },
 	{ },
diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index a5397b1..ab9a24a 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -1774,7 +1774,7 @@ static u16 phy_read_1bit(struct uli526x_board_info *db)
 }
 
 
-static DEFINE_PCI_DEVICE_TABLE(uli526x_pci_tbl) = {
+static const struct pci_device_id uli526x_pci_tbl[] = {
 	{ 0x10B9, 0x5261, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_ULI5261_ID },
 	{ 0x10B9, 0x5263, PCI_ANY_ID, PCI_ANY_ID, 0, 0, PCI_ULI5263_ID },
 	{ 0, }
diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index 62fe512..6aa887e 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -219,7 +219,7 @@ enum chip_capability_flags {
 	CanHaveMII=1, HasBrokenTx=2, AlwaysFDX=4, FDXOnNoMII=8,
 };
 
-static DEFINE_PCI_DEVICE_TABLE(w840_pci_tbl) = {
+static const struct pci_device_id w840_pci_tbl[] = {
 	{ 0x1050, 0x0840, PCI_ANY_ID, 0x8153,     0, 0, 0 },
 	{ 0x1050, 0x0840, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
 	{ 0x11f6, 0x2011, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 2 },
diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net/ethernet/dec/tulip/xircom_cb.c
index ab7ebac..56f4f64 100644
--- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
+++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
@@ -138,7 +138,7 @@ static int link_status(struct xircom_private *card);
 
 
 
-static DEFINE_PCI_DEVICE_TABLE(xircom_pci_table) = {
+static const struct pci_device_id xircom_pci_table[] = {
 	{ PCI_VDEVICE(XIRCOM, 0x0003), },
 	{0,},
 };
diff --git a/drivers/net/ethernet/dlink/dl2k.h b/drivers/net/ethernet/dlink/dl2k.h
index 3699565..ed1b596 100644
--- a/drivers/net/ethernet/dlink/dl2k.h
+++ b/drivers/net/ethernet/dlink/dl2k.h
@@ -409,7 +409,7 @@ struct netdev_private {
         driver_data             Data private to the driver.
 */
 
-static DEFINE_PCI_DEVICE_TABLE(rio_pci_tbl) = {
+static const struct pci_device_id rio_pci_tbl[] = {
 	{0x1186, 0x4000, PCI_ANY_ID, PCI_ANY_ID, },
 	{0x13f0, 0x1021, PCI_ANY_ID, PCI_ANY_ID, },
 	{ }
diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index 113cd79..2b5f138 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -199,7 +199,7 @@ IVc. Errata
 #define USE_IO_OPS 1
 #endif
 
-static DEFINE_PCI_DEVICE_TABLE(sundance_pci_tbl) = {
+static const struct pci_device_id sundance_pci_tbl[] = {
 	{ 0x1186, 0x1002, 0x1186, 0x1002, 0, 0, 0 },
 	{ 0x1186, 0x1002, 0x1186, 0x1003, 0, 0, 1 },
 	{ 0x1186, 0x1002, 0x1186, 0x1012, 0, 0, 2 },
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index abde974..2a0a31c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -38,7 +38,7 @@ static ushort rx_frag_size = 2048;
 module_param(rx_frag_size, ushort, S_IRUGO);
 MODULE_PARM_DESC(rx_frag_size, "Size of a fragment that holds rcvd data.");
 
-static DEFINE_PCI_DEVICE_TABLE(be_dev_ids) = {
+static const struct pci_device_id be_dev_ids[] = {
 	{ PCI_DEVICE(BE_VENDOR_ID, BE_DEVICE_ID1) },
 	{ PCI_DEVICE(BE_VENDOR_ID, BE_DEVICE_ID2) },
 	{ PCI_DEVICE(BE_VENDOR_ID, OC_DEVICE_ID1) },
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
diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index 3786009..ed7916f 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -208,7 +208,7 @@ MODULE_DEVICE_TABLE(eisa, hp100_eisa_tbl);
 #endif
 
 #ifdef CONFIG_PCI
-static DEFINE_PCI_DEVICE_TABLE(hp100_pci_tbl) = {
+static const struct pci_device_id hp100_pci_tbl[] = {
 	{PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_J2585A, PCI_ANY_ID, PCI_ANY_ID,},
 	{PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_J2585B, PCI_ANY_ID, PCI_ANY_ID,},
 	{PCI_VENDOR_ID_HP, PCI_DEVICE_ID_HP_J2970A, PCI_ANY_ID, PCI_ANY_ID,},
diff --git a/drivers/net/ethernet/icplus/ipg.c b/drivers/net/ethernet/icplus/ipg.c
index 25045ae..497b0aa 100644
--- a/drivers/net/ethernet/icplus/ipg.c
+++ b/drivers/net/ethernet/icplus/ipg.c
@@ -95,7 +95,7 @@ static const char * const ipg_brand_name[] = {
 	"D-Link NIC IP1000A"
 };
 
-static DEFINE_PCI_DEVICE_TABLE(ipg_pci_tbl) = {
+static const struct pci_device_id ipg_pci_tbl[] = {
 	{ PCI_VDEVICE(SUNDANCE,	0x1023), 0 },
 	{ PCI_VDEVICE(SUNDANCE,	0x2021), 1 },
 	{ PCI_VDEVICE(DLINK,	0x9021), 2 },
diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index cbaba44..f8a4f5b0 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -208,7 +208,7 @@ MODULE_PARM_DESC(use_io, "Force use of i/o access mode");
 #define INTEL_8255X_ETHERNET_DEVICE(device_id, ich) {\
 	PCI_VENDOR_ID_INTEL, device_id, PCI_ANY_ID, PCI_ANY_ID, \
 	PCI_CLASS_NETWORK_ETHERNET << 8, 0xFFFF00, ich }
-static DEFINE_PCI_DEVICE_TABLE(e100_id_table) = {
+static const struct pci_device_id e100_id_table[] = {
 	INTEL_8255X_ETHERNET_DEVICE(0x1029, 0),
 	INTEL_8255X_ETHERNET_DEVICE(0x1030, 0),
 	INTEL_8255X_ETHERNET_DEVICE(0x1031, 3),
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index e386228..d961008 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -46,7 +46,7 @@ static const char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation
  * Macro expands to...
  *   {PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
  */
-static DEFINE_PCI_DEVICE_TABLE(e1000_pci_tbl) = {
+static const struct pci_device_id e1000_pci_tbl[] = {
 	INTEL_E1000_ETHERNET_DEVICE(0x1000),
 	INTEL_E1000_ETHERNET_DEVICE(0x1001),
 	INTEL_E1000_ETHERNET_DEVICE(0x1004),
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 8d3945a..2f357a2 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6933,7 +6933,7 @@ static const struct pci_error_handlers e1000_err_handler = {
 	.resume = e1000_io_resume,
 };
 
-static DEFINE_PCI_DEVICE_TABLE(e1000_pci_tbl) = {
+static const struct pci_device_id e1000_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_COPPER), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_FIBER), board_82571 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82571EB_QUAD_COPPER), board_82571 },
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index be15938..77482ea 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -60,7 +60,7 @@ static int i40e_setup_pf_filter_control(struct i40e_pf *pf);
  * { Vendor ID, Device ID, SubVendor ID, SubDevice ID,
  *   Class, Class Mask, private data (not used) }
  */
-static DEFINE_PCI_DEVICE_TABLE(i40e_pci_tbl) = {
+static const struct pci_device_id i40e_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, I40E_SFP_XL710_DEVICE_ID), 0},
 	{PCI_VDEVICE(INTEL, I40E_SFP_X710_DEVICE_ID), 0},
 	{PCI_VDEVICE(INTEL, I40E_QEMU_DEVICE_ID), 0},
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 025e5f4..ce06a9a 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -76,7 +76,7 @@ static const struct e1000_info *igb_info_tbl[] = {
 	[board_82575] = &e1000_82575_info,
 };
 
-static DEFINE_PCI_DEVICE_TABLE(igb_pci_tbl) = {
+static const struct pci_device_id igb_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I354_BACKPLANE_1GBPS) },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I354_SGMII) },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I354_BACKPLANE_2_5GBPS) },
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 04bf22e..9e59b9e 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2855,7 +2855,7 @@ static const struct pci_error_handlers igbvf_err_handler = {
 	.resume = igbvf_io_resume,
 };
 
-static DEFINE_PCI_DEVICE_TABLE(igbvf_pci_tbl) = {
+static const struct pci_device_id igbvf_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82576_VF), board_vf },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I350_VF), board_i350_vf },
 	{ } /* terminate list */
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 57e390c..c7ec199 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -53,7 +53,7 @@ MODULE_PARM_DESC(copybreak,
  * { Vendor ID, Device ID, SubVendor ID, SubDevice ID,
  *   Class, Class Mask, private data (not used) }
  */
-static DEFINE_PCI_DEVICE_TABLE(ixgb_pci_tbl) = {
+static const struct pci_device_id ixgb_pci_tbl[] = {
 	{PCI_VENDOR_ID_INTEL, IXGB_DEVICE_ID_82597EX,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{PCI_VENDOR_ID_INTEL, IXGB_DEVICE_ID_82597EX_CX4,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0c55079..0892d74 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -83,7 +83,7 @@ static const struct ixgbe_info *ixgbe_info_tbl[] = {
  * { Vendor ID, Device ID, SubVendor ID, SubDevice ID,
  *   Class, Class Mask, private data (not used) }
  */
-static DEFINE_PCI_DEVICE_TABLE(ixgbe_pci_tbl) = {
+static const struct pci_device_id ixgbe_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598), board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AF_DUAL_PORT), board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598AF_SINGLE_PORT), board_82598 },
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 92ef4cb..0af5d93 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -76,7 +76,7 @@ static const struct ixgbevf_info *ixgbevf_info_tbl[] = {
  * { Vendor ID, Device ID, SubVendor ID, SubDevice ID,
  *   Class, Class Mask, private data (not used) }
  */
-static DEFINE_PCI_DEVICE_TABLE(ixgbevf_pci_tbl) = {
+static const struct pci_device_id ixgbevf_pci_tbl[] = {
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82599_VF), board_82599_vf },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_X540_VF), board_X540_vf },
 	/* required last entry */
diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index f5685c0..cdc416e 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -3305,7 +3305,7 @@ static SIMPLE_DEV_PM_OPS(jme_pm_ops, jme_suspend, jme_resume);
 #define JME_PM_OPS NULL
 #endif
 
-static DEFINE_PCI_DEVICE_TABLE(jme_pci_tbl) = {
+static const struct pci_device_id jme_pci_tbl[] = {
 	{ PCI_VDEVICE(JMICRON, PCI_DEVICE_ID_JMICRON_JMC250) },
 	{ PCI_VDEVICE(JMICRON, PCI_DEVICE_ID_JMICRON_JMC260) },
 	{ }
diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 5978461..104235a 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -82,7 +82,7 @@ static int debug = -1;	/* defaults above */
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
-static DEFINE_PCI_DEVICE_TABLE(skge_id_table) = {
+static const struct pci_device_id skge_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_3COM, 0x1700) },	  /* 3Com 3C940 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_3COM, 0x80EB) },	  /* 3Com 3C940B */
 #ifdef CONFIG_SKGE_GENESIS
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 43aa7acd..0fdc140 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -99,7 +99,7 @@ static int legacy_pme = 0;
 module_param(legacy_pme, int, 0);
 MODULE_PARM_DESC(legacy_pme, "Legacy power management");
 
-static DEFINE_PCI_DEVICE_TABLE(sky2_id_table) = {
+static const struct pci_device_id sky2_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9000) }, /* SK-9Sxx */
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E00) }, /* SK-9Exx */
 	{ PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, 0x9E01) }, /* SK-9E21M */
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 5789ea2..7b869cf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2508,7 +2508,7 @@ int mlx4_restart_one(struct pci_dev *pdev)
 	return __mlx4_init_one(pdev, pci_dev_data);
 }
 
-static DEFINE_PCI_DEVICE_TABLE(mlx4_pci_table) = {
+static const struct pci_device_id mlx4_pci_table[] = {
 	/* MT25408 "Hermon" SDR */
 	{ PCI_VDEVICE(MELLANOX, 0x6340), MLX4_PCI_DEV_FORCE_SENSE_PORT },
 	/* MT25408 "Hermon" DDR */
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index ddd252a..75a40c7 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -7225,7 +7225,7 @@ static int pcidev_suspend(struct pci_dev *pdev, pm_message_t state)
 
 static char pcidev_name[] = "ksz884xp";
 
-static DEFINE_PCI_DEVICE_TABLE(pcidev_table) = {
+static const struct pci_device_id pcidev_table[] = {
 	{ PCI_VENDOR_ID_MICREL_KS, 0x8841,
 		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ PCI_VENDOR_ID_MICREL_KS, 0x8842,
diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 68026f7..d663637 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -4213,7 +4213,7 @@ static void myri10ge_remove(struct pci_dev *pdev)
 #define PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E 	0x0008
 #define PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E_9	0x0009
 
-static DEFINE_PCI_DEVICE_TABLE(myri10ge_pci_tbl) = {
+static const struct pci_device_id myri10ge_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_MYRICOM, PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E)},
 	{PCI_DEVICE
 	 (PCI_VENDOR_ID_MYRICOM, PCI_DEVICE_ID_MYRICOM_MYRI10GE_Z8E_9)},
diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index 64ec2a4..8b490c4 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -247,7 +247,7 @@ static struct {
 	{ "NatSemi DP8381[56]", 0, 24 },
 };
 
-static DEFINE_PCI_DEVICE_TABLE(natsemi_pci_tbl) = {
+static const struct pci_device_id natsemi_pci_tbl[] = {
 	{ PCI_VENDOR_ID_NS, 0x0020, 0x12d9,     0x000c,     0, 0, 0 },
 	{ PCI_VENDOR_ID_NS, 0x0020, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
 	{ }	/* terminate list */
diff --git a/drivers/net/ethernet/natsemi/ns83820.c b/drivers/net/ethernet/natsemi/ns83820.c
index d3b4700..86ad1e7 100644
--- a/drivers/net/ethernet/natsemi/ns83820.c
+++ b/drivers/net/ethernet/natsemi/ns83820.c
@@ -2263,7 +2263,7 @@ static void ns83820_remove_one(struct pci_dev *pci_dev)
 	pci_set_drvdata(pci_dev, NULL);
 }
 
-static DEFINE_PCI_DEVICE_TABLE(ns83820_pci_tbl) = {
+static const struct pci_device_id ns83820_pci_tbl[] = {
 	{ 0x100b, 0x0022, PCI_ANY_ID, PCI_ANY_ID, 0, .driver_data = 0, },
 	{ 0, },
 };
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 9eeddbd..4732a3e 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -471,7 +471,7 @@ module_param_array(rts_frm_len, uint, NULL, 0);
  * S2IO device table.
  * This table lists all the devices that this driver supports.
  */
-static DEFINE_PCI_DEVICE_TABLE(s2io_tbl) = {
+static const struct pci_device_id s2io_tbl[] = {
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_S2IO_WIN,
 	 PCI_ANY_ID, PCI_ANY_ID},
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_S2IO_UNI,
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index f9876ea..054332d 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -63,7 +63,7 @@ MODULE_LICENSE("Dual BSD/GPL");
 MODULE_DESCRIPTION("Neterion's X3100 Series 10GbE PCIe I/O"
 	"Virtualized Server Adapter");
 
-static DEFINE_PCI_DEVICE_TABLE(vxge_id_table) = {
+static const struct pci_device_id vxge_id_table[] = {
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_TITAN_WIN, PCI_ANY_ID,
 	PCI_ANY_ID},
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_TITAN_UNI, PCI_ANY_ID,
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 2d045be..10aa19c 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -6178,7 +6178,7 @@ static void nv_shutdown(struct pci_dev *pdev)
 #define nv_shutdown NULL
 #endif /* CONFIG_PM */
 
-static DEFINE_PCI_DEVICE_TABLE(pci_tbl) = {
+static const struct pci_device_id pci_tbl[] = {
 	{	/* nForce Ethernet Controller */
 		PCI_DEVICE(0x10DE, 0x01C3),
 		.driver_data = DEV_NEED_TIMERIRQ|DEV_NEED_LINKTIMER,
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 27ffe0e..a1298e5e 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2753,7 +2753,7 @@ static struct pch_gbe_privdata pch_gbe_minnow_privdata = {
 	.platform_init = pch_gbe_minnow_platform_init,
 };
 
-static DEFINE_PCI_DEVICE_TABLE(pch_gbe_pcidev_id) = {
+static const struct pci_device_id pch_gbe_pcidev_id[] = {
 	{.vendor = PCI_VENDOR_ID_INTEL,
 	 .device = PCI_DEVICE_ID_INTEL_IOH1_GBE,
 	 .subvendor = PCI_VENDOR_ID_CIRCUITCO,
diff --git a/drivers/net/ethernet/packetengines/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
index b6bdeb3..474c899 100644
--- a/drivers/net/ethernet/packetengines/hamachi.c
+++ b/drivers/net/ethernet/packetengines/hamachi.c
@@ -1913,7 +1913,7 @@ static void hamachi_remove_one(struct pci_dev *pdev)
 	}
 }
 
-static DEFINE_PCI_DEVICE_TABLE(hamachi_pci_tbl) = {
+static const struct pci_device_id hamachi_pci_tbl[] = {
 	{ 0x1318, 0x0911, PCI_ANY_ID, PCI_ANY_ID, },
 	{ 0, }
 };
diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index 07a890e..6110ab6 100644
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
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index dbaa49e..4f86473 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -1873,7 +1873,7 @@ static void pasemi_mac_remove(struct pci_dev *pdev)
 	free_netdev(netdev);
 }
 
-static DEFINE_PCI_DEVICE_TABLE(pasemi_mac_pci_tbl) = {
+static const struct pci_device_id pasemi_mac_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_PASEMI, 0xa005) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_PASEMI, 0xa006) },
 	{ },
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 3bec8cf..e7df40e 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -101,7 +101,7 @@ static int netxen_nic_set_mac(struct net_device *netdev, void *p);
 	{PCI_DEVICE(PCI_VENDOR_ID_NETXEN, (device)), \
 	.class = PCI_CLASS_NETWORK_ETHERNET << 8, .class_mask = ~0}
 
-static DEFINE_PCI_DEVICE_TABLE(netxen_pci_tbl) = {
+static const struct pci_device_id netxen_pci_tbl[] = {
 	ENTRY(PCI_DEVICE_ID_NX2031_10GXSR),
 	ENTRY(PCI_DEVICE_ID_NX2031_10GCX4),
 	ENTRY(PCI_DEVICE_ID_NX2031_4GCU),
diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index 0758b94..8a53a6b 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -66,7 +66,7 @@ static int msi;
 module_param(msi, int, 0);
 MODULE_PARM_DESC(msi, "Turn on Message Signaled Interrupts.");
 
-static DEFINE_PCI_DEVICE_TABLE(ql3xxx_pci_tbl) = {
+static const struct pci_device_id ql3xxx_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QL3022_DEVICE_ID)},
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QL3032_DEVICE_ID)},
 	/* required last entry */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 05c1eef..2dfdb32 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -96,7 +96,7 @@ static u32 qlcnic_vlan_tx_check(struct qlcnic_adapter *adapter)
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, (device)), \
 	.class = PCI_CLASS_NETWORK_ETHERNET << 8, .class_mask = ~0}
 
-static DEFINE_PCI_DEVICE_TABLE(qlcnic_pci_tbl) = {
+static const struct pci_device_id qlcnic_pci_tbl[] = {
 	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE824X),
 	ENTRY(PCI_DEVICE_ID_QLOGIC_QLE834X),
 	ENTRY(PCI_DEVICE_ID_QLOGIC_VF_QLE834X),
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index a245dc1..94f75ad 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -87,7 +87,7 @@ MODULE_PARM_DESC(qlge_force_coredump,
 		"Option to allow force of firmware core dump. "
 		"Default is OFF - Do not allow.");
 
-static DEFINE_PCI_DEVICE_TABLE(qlge_pci_tbl) = {
+static const struct pci_device_id qlge_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QLGE_DEVICE_ID_8012)},
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QLGE_DEVICE_ID_8000)},
 	/* required last entry */
diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 1e49ec5..fe4d029 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1259,7 +1259,7 @@ static void r6040_remove_one(struct pci_dev *pdev)
 }
 
 
-static DEFINE_PCI_DEVICE_TABLE(r6040_pci_tbl) = {
+static const struct pci_device_id r6040_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_RDC, 0x6040) },
 	{ 0 }
 };
diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
index f2a2128..54b4dcc 100644
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
index da5972e..e5cfd24 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -234,7 +234,7 @@ static const struct {
 };
 
 
-static DEFINE_PCI_DEVICE_TABLE(rtl8139_pci_tbl) = {
+static const struct pci_device_id rtl8139_pci_tbl[] = {
 	{0x10ec, 0x8139, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x10ec, 0x8138, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x1113, 0x1211, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7993875..eb528de 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -290,7 +290,7 @@ enum cfg_version {
 	RTL_CFG_2
 };
 
-static DEFINE_PCI_DEVICE_TABLE(rtl8169_pci_tbl) = {
+static const struct pci_device_id rtl8169_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8129), 0, 0, RTL_CFG_0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8136), 0, 0, RTL_CFG_2 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8167), 0, 0, RTL_CFG_0 },
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 2e27837..abf4878 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2468,7 +2468,7 @@ void efx_schedule_reset(struct efx_nic *efx, enum reset_type type)
  **************************************************************************/
 
 /* PCI device ID table */
-static DEFINE_PCI_DEVICE_TABLE(efx_pci_table) = {
+static const struct pci_device_id efx_pci_table[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE,
 		    PCI_DEVICE_ID_SOLARFLARE_SFC4000A_0),
 	 .driver_data = (unsigned long) &falcon_a1_nic_type},
diff --git a/drivers/net/ethernet/sgi/ioc3-eth.c b/drivers/net/ethernet/sgi/ioc3-eth.c
index ffa7843..e987f12 100644
--- a/drivers/net/ethernet/sgi/ioc3-eth.c
+++ b/drivers/net/ethernet/sgi/ioc3-eth.c
@@ -1385,7 +1385,7 @@ static void ioc3_remove_one(struct pci_dev *pdev)
 	 */
 }
 
-static DEFINE_PCI_DEVICE_TABLE(ioc3_pci_tbl) = {
+static const struct pci_device_id ioc3_pci_tbl[] = {
 	{ PCI_VENDOR_ID_SGI, PCI_DEVICE_ID_SGI_IOC3, PCI_ANY_ID, PCI_ANY_ID },
 	{ 0 }
 };
diff --git a/drivers/net/ethernet/silan/sc92031.c b/drivers/net/ethernet/silan/sc92031.c
index 5eb933c..d8e5ef4 100644
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
diff --git a/drivers/net/ethernet/sis/sis190.c b/drivers/net/ethernet/sis/sis190.c
index acbbe48..17c9670 100644
--- a/drivers/net/ethernet/sis/sis190.c
+++ b/drivers/net/ethernet/sis/sis190.c
@@ -330,7 +330,7 @@ static const struct {
 	{ "SiS 191 PCI Gigabit Ethernet adapter" },
 };
 
-static DEFINE_PCI_DEVICE_TABLE(sis190_pci_tbl) = {
+static const struct pci_device_id sis190_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0190), 0, 0, 0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0191), 0, 0, 1 },
 	{ 0, },
diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index 975dc2d..7c61df3 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -106,7 +106,7 @@ static const char * card_names[] = {
 	"SiS 900 PCI Fast Ethernet",
 	"SiS 7016 PCI Fast Ethernet"
 };
-static DEFINE_PCI_DEVICE_TABLE(sis900_pci_tbl) = {
+static const struct pci_device_id sis900_pci_tbl[] = {
 	{PCI_VENDOR_ID_SI, PCI_DEVICE_ID_SI_900,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, SIS_900},
 	{PCI_VENDOR_ID_SI, PCI_DEVICE_ID_SI_7016,
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
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index f433d97..2df8dd1 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -84,7 +84,7 @@ struct smsc9420_pdata {
 	int last_carrier;
 };
 
-static DEFINE_PCI_DEVICE_TABLE(smsc9420_id_table) = {
+static const struct pci_device_id smsc9420_id_table[] = {
 	{ PCI_VENDOR_ID_9420, PCI_DEVICE_ID_9420, PCI_ANY_ID, PCI_ANY_ID, },
 	{ 0, }
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 644d80e..fe6b797 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -170,7 +170,7 @@ static int stmmac_pci_resume(struct pci_dev *pdev)
 #define STMMAC_VENDOR_ID 0x700
 #define STMMAC_DEVICE_ID 0x1108
 
-static DEFINE_PCI_DEVICE_TABLE(stmmac_id_table) = {
+static const struct pci_device_id stmmac_id_table[] = {
 	{PCI_DEVICE(STMMAC_VENDOR_ID, STMMAC_DEVICE_ID)},
 	{PCI_DEVICE(PCI_VENDOR_ID_STMICRO, PCI_DEVICE_ID_STMICRO_MAC)},
 	{}
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index b4d50d7..b27ebac 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -231,7 +231,7 @@ static u16 link_modes[] = {
 	CAS_BMCR_SPEED1000|BMCR_FULLDPLX /* 5 : 1000bt full duplex */
 };
 
-static DEFINE_PCI_DEVICE_TABLE(cas_pci_tbl) = {
+static const struct pci_device_id cas_pci_tbl[] = {
 	{ PCI_VENDOR_ID_SUN, PCI_DEVICE_ID_SUN_CASSINI,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_NS, PCI_DEVICE_ID_NS_SATURN,
diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 388540f..b062b7d 100644
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
index b5655b7..3425970 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -86,7 +86,7 @@ MODULE_LICENSE("GPL");
 
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
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index dd0dd627..04799b5 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -66,7 +66,7 @@
 
 #include "tehuti.h"
 
-static DEFINE_PCI_DEVICE_TABLE(bdx_pci_tbl) = {
+static const struct pci_device_id bdx_pci_tbl[] = {
 	{ PCI_VDEVICE(TEHUTI, 0x3009), },
 	{ PCI_VDEVICE(TEHUTI, 0x3010), },
 	{ PCI_VDEVICE(TEHUTI, 0x3014), },
diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index 62b19be..fa3d3eb 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -118,7 +118,7 @@ static struct board {
 	  TLAN_ADAPTER_ACTIVITY_LED, 0x83 }, /* EISA card */
 };
 
-static DEFINE_PCI_DEVICE_TABLE(tlan_pci_tbl) = {
+static const struct pci_device_id tlan_pci_tbl[] = {
 	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL10,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL100,
diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index 3f4a32e..7e04e41 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -73,7 +73,7 @@ MODULE_PARM_DESC(tx_descriptors, "number of descriptors used " \
 
 char spider_net_driver_name[] = "spidernet";
 
-static DEFINE_PCI_DEVICE_TABLE(spider_net_pci_tbl) = {
+static const struct pci_device_id spider_net_pci_tbl[] = {
 	{ PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_SPIDER_NET,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ 0, }
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 1322546..64bc1db 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -66,7 +66,7 @@ static const struct {
 	{ "TOSHIBA TC35815/TX4939" },
 };
 
-static DEFINE_PCI_DEVICE_TABLE(tc35815_pci_tbl) = {
+static const struct pci_device_id tc35815_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815CF), .driver_data = TC35815CF },
 	{PCI_DEVICE(PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815_NWU), .driver_data = TC35815_NWU },
 	{PCI_DEVICE(PCI_VENDOR_ID_TOSHIBA_2, PCI_DEVICE_ID_TOSHIBA_TC35815_TX4939), .driver_data = TC35815_TX4939 },
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index cce6c4b..923de5c 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -270,7 +270,7 @@ enum rhine_quirks {
 /* Beware of PCI posted writes */
 #define IOSYNC	do { ioread8(ioaddr + StationAddr); } while (0)
 
-static DEFINE_PCI_DEVICE_TABLE(rhine_pci_tbl) = {
+static const struct pci_device_id rhine_pci_tbl[] = {
 	{ 0x1106, 0x3043, PCI_ANY_ID, PCI_ANY_ID, },	/* VT86C100A */
 	{ 0x1106, 0x3065, PCI_ANY_ID, PCI_ANY_ID, },	/* VT6102 */
 	{ 0x1106, 0x3106, PCI_ANY_ID, PCI_ANY_ID, },	/* 6105{,L,LOM} */
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index d022bf9..8a09717 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -381,7 +381,7 @@ static struct velocity_info_tbl chip_info_table[] = {
  *	device driver. Used for hotplug autoloading.
  */
 
-static DEFINE_PCI_DEVICE_TABLE(velocity_pci_id_table) = {
+static const struct pci_device_id velocity_pci_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_VIA, PCI_DEVICE_ID_VIA_612X) },
 	{ }
 };
diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
index 0b40e1c..72de3e3 100644
--- a/drivers/net/fddi/defxx.c
+++ b/drivers/net/fddi/defxx.c
@@ -3622,7 +3622,7 @@ static int __maybe_unused dfx_dev_unregister(struct device *);
 static int dfx_pci_register(struct pci_dev *, const struct pci_device_id *);
 static void dfx_pci_unregister(struct pci_dev *);
 
-static DEFINE_PCI_DEVICE_TABLE(dfx_pci_table) = {
+static const struct pci_device_id dfx_pci_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_FDDI) },
 	{ }
 };
diff --git a/drivers/net/fddi/skfp/skfddi.c b/drivers/net/fddi/skfp/skfddi.c
index 713d303..1c45137 100644
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
diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index 00ed751..dc8232c 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -1672,7 +1672,7 @@ static int rr_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	}
 }
 
-static DEFINE_PCI_DEVICE_TABLE(rr_pci_tbl) = {
+static const struct pci_device_id rr_pci_tbl[] = {
 	{ PCI_VENDOR_ID_ESSENTIAL, PCI_DEVICE_ID_ESSENTIAL_ROADRUNNER,
 		PCI_ANY_ID, PCI_ANY_ID, },
 	{ 0,}
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 768dfe9..9fd0c20 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -184,7 +184,7 @@
 #define CONFIG0H_DMA_ON_NORX CONFIG0H_DMA_OFF| OBOE_CONFIG0H_ENDMAC
 #define CONFIG0H_DMA_ON CONFIG0H_DMA_ON_NORX | OBOE_CONFIG0H_ENRX
 
-static DEFINE_PCI_DEVICE_TABLE(toshoboe_pci_tbl) = {
+static const struct pci_device_id toshoboe_pci_tbl[] = {
 	{ PCI_VENDOR_ID_TOSHIBA, PCI_DEVICE_ID_FIR701, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_TOSHIBA, PCI_DEVICE_ID_FIRD01, PCI_ANY_ID, PCI_ANY_ID, },
 	{ }			/* Terminating entry */
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 9abaec2..7113dca 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -116,7 +116,7 @@ static void iodelay(int udelay)
 	}
 }
 
-static DEFINE_PCI_DEVICE_TABLE(via_pci_tbl) = {
+static const struct pci_device_id via_pci_tbl[] = {
 	{ PCI_VENDOR_ID_VIA, 0x8231, PCI_ANY_ID, PCI_ANY_ID,0,0,0 },
 	{ PCI_VENDOR_ID_VIA, 0x3109, PCI_ANY_ID, PCI_ANY_ID,0,0,1 },
 	{ PCI_VENDOR_ID_VIA, 0x3074, PCI_ANY_ID, PCI_ANY_ID,0,0,2 },
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index c5bd58b..09fd960 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -60,7 +60,7 @@ MODULE_LICENSE("GPL");
 
 static /* const */ char drivername[] = DRIVER_NAME;
 
-static DEFINE_PCI_DEVICE_TABLE(vlsi_irda_table) = {
+static const struct pci_device_id vlsi_irda_table[] = {
 	{
 		.class =        PCI_CLASS_WIRELESS_IRDA << 8,
 		.class_mask =	PCI_CLASS_SUBCLASS_MASK << 8, 
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 7e2788c..b677073 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -36,7 +36,7 @@ char vmxnet3_driver_name[] = "vmxnet3";
  * PCI Device ID Table
  * Last entry must be all 0s
  */
-static DEFINE_PCI_DEVICE_TABLE(vmxnet3_pciid_table) = {
+static const struct pci_device_id vmxnet3_pciid_table[] = {
 	{PCI_VDEVICE(VMWARE, PCI_DEVICE_ID_VMWARE_VMXNET3)},
 	{0}
 };
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 851dc7b..8a0b65c 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -2041,7 +2041,7 @@ static int __init dscc4_setup(char *str)
 __setup("dscc4.setup=", dscc4_setup);
 #endif
 
-static DEFINE_PCI_DEVICE_TABLE(dscc4_pci_tbl) = {
+static const struct pci_device_id dscc4_pci_tbl[] = {
 	{ PCI_VENDOR_ID_SIEMENS, PCI_DEVICE_ID_SIEMENS_DSCC4,
 	        PCI_ANY_ID, PCI_ANY_ID, },
 	{ 0,}
diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index bcfff0d..b6d2633 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -530,7 +530,7 @@ do {								\
 /*
  *      PCI ID lookup table
  */
-static DEFINE_PCI_DEVICE_TABLE(fst_pci_dev_id) = {
+static const struct pci_device_id fst_pci_dev_id[] = {
 	{PCI_VENDOR_ID_FARSITE, PCI_DEVICE_ID_FARSITE_T2P, PCI_ANY_ID, 
 	 PCI_ANY_ID, 0, 0, FST_TYPE_T2P},
 
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 7ef435b..ffca76d 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -77,7 +77,7 @@
 
 static int LMC_PKT_BUF_SZ = 1542;
 
-static DEFINE_PCI_DEVICE_TABLE(lmc_pci_tbl) = {
+static const struct pci_device_id lmc_pci_tbl = {
 	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_FAST,
 	  PCI_VENDOR_ID_LMC, PCI_ANY_ID },
 	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_FAST,
diff --git a/drivers/net/wan/pc300too.c b/drivers/net/wan/pc300too.c
index 53efc57..1b2c7d3 100644
--- a/drivers/net/wan/pc300too.c
+++ b/drivers/net/wan/pc300too.c
@@ -478,7 +478,7 @@ static int pc300_pci_init_one(struct pci_dev *pdev,
 
 
 
-static DEFINE_PCI_DEVICE_TABLE(pc300_pci_tbl) = {
+static const struct pci_device_id pc300_pci_tbl[] = {
 	{ PCI_VENDOR_ID_CYCLADES, PCI_DEVICE_ID_PC300_RX_1, PCI_ANY_ID,
 	  PCI_ANY_ID, 0, 0, 0 },
 	{ PCI_VENDOR_ID_CYCLADES, PCI_DEVICE_ID_PC300_RX_2, PCI_ANY_ID,
diff --git a/drivers/net/wan/pci200syn.c b/drivers/net/wan/pci200syn.c
index ddbce54..94803f9 100644
--- a/drivers/net/wan/pci200syn.c
+++ b/drivers/net/wan/pci200syn.c
@@ -415,7 +415,7 @@ static int pci200_pci_init_one(struct pci_dev *pdev,
 
 
 
-static DEFINE_PCI_DEVICE_TABLE(pci200_pci_tbl) = {
+static const struct pci_device_id pci200_pci_tbl[] = {
 	{ PCI_VENDOR_ID_PLX, PCI_DEVICE_ID_PLX_9050, PCI_VENDOR_ID_PLX,
 	  PCI_DEVICE_ID_PLX_PCI200SYN, 0, 0, 0 },
 	{ 0, }
diff --git a/drivers/net/wan/wanxl.c b/drivers/net/wan/wanxl.c
index 4c0a697..19ca9d3 100644
--- a/drivers/net/wan/wanxl.c
+++ b/drivers/net/wan/wanxl.c
@@ -808,7 +808,7 @@ static int wanxl_pci_init_one(struct pci_dev *pdev,
 	return 0;
 }
 
-static DEFINE_PCI_DEVICE_TABLE(wanxl_pci_tbl) = {
+static const struct pci_device_id wanxl_pci_tbl[] = {
 	{ PCI_VENDOR_ID_SBE, PCI_DEVICE_ID_SBE_WANXL100, PCI_ANY_ID,
 	  PCI_ANY_ID, 0, 0, 0 },
 	{ PCI_VENDOR_ID_SBE, PCI_DEVICE_ID_SBE_WANXL200, PCI_ANY_ID,
diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index cfce83e..1aa924a 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -42,7 +42,7 @@ static unsigned int rx_ring_size __read_mostly = 16;
 module_param(tx_ring_size, uint, 0);
 module_param(rx_ring_size, uint, 0);
 
-static DEFINE_PCI_DEVICE_TABLE(adm8211_pci_id_table) = {
+static const struct pci_device_id adm8211_pci_id_table[] = {
 	/* ADMtek ADM8211 */
 	{ PCI_DEVICE(0x10B7, 0x6000) }, /* 3Com 3CRSHPW796 */
 	{ PCI_DEVICE(0x1200, 0x8201) }, /* ? */
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index edf4b57..2006c8b 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -57,7 +57,7 @@
 #define DRV_NAME "airo"
 
 #ifdef CONFIG_PCI
-static DEFINE_PCI_DEVICE_TABLE(card_ids) = {
+static const struct pci_device_id card_ids[] = {
 	{ 0x14b9, 1, PCI_ANY_ID, PCI_ANY_ID, },
 	{ 0x14b9, 0x4500, PCI_ANY_ID, PCI_ANY_ID },
 	{ 0x14b9, 0x4800, PCI_ANY_ID, PCI_ANY_ID, },
diff --git a/drivers/net/wireless/ath/ath10k/pci.c b/drivers/net/wireless/ath/ath10k/pci.c
index 9e86a81..7de760a 100644
--- a/drivers/net/wireless/ath/ath10k/pci.c
+++ b/drivers/net/wireless/ath/ath10k/pci.c
@@ -38,7 +38,7 @@ MODULE_PARM_DESC(ath10k_target_ps, "Enable ath10k Target (SoC) PS option");
 
 #define QCA988X_2_0_DEVICE_ID	(0x003c)
 
-static DEFINE_PCI_DEVICE_TABLE(ath10k_pci_id_table) = {
+static const struct pci_device_id ath10k_pci_id_table[] = {
 	{ PCI_VDEVICE(ATHEROS, QCA988X_2_0_DEVICE_ID) }, /* PCI-E QCA988X V2 */
 	{0}
 };
diff --git a/drivers/net/wireless/ath/ath5k/led.c b/drivers/net/wireless/ath/ath5k/led.c
index f77ef36..48a6a69b 100644
--- a/drivers/net/wireless/ath/ath5k/led.c
+++ b/drivers/net/wireless/ath/ath5k/led.c
@@ -53,7 +53,7 @@
 #define ATH_POLARITY(data) ((data) & 0xff)
 
 /* Devices we match on for LED config info (typically laptops) */
-static DEFINE_PCI_DEVICE_TABLE(ath5k_led_devices) = {
+static const struct pci_device_id ath5k_led_devices[] = {
 	/* AR5211 */
 	{ PCI_VDEVICE(ATHEROS, PCI_DEVICE_ID_ATHEROS_AR5211), ATH_LED(0, 0) },
 	/* HP Compaq nc6xx, nc4000, nx6000 */
diff --git a/drivers/net/wireless/ath/ath5k/pci.c b/drivers/net/wireless/ath/ath5k/pci.c
index 859db7c..c6156cc 100644
--- a/drivers/net/wireless/ath/ath5k/pci.c
+++ b/drivers/net/wireless/ath/ath5k/pci.c
@@ -28,7 +28,7 @@
 #include "reg.h"
 
 /* Known PCI ids */
-static DEFINE_PCI_DEVICE_TABLE(ath5k_pci_id_table) = {
+static const struct pci_device_id ath5k_pci_id_table[] = {
 	{ PCI_VDEVICE(ATHEROS, 0x0207) }, /* 5210 early */
 	{ PCI_VDEVICE(ATHEROS, 0x0007) }, /* 5210 */
 	{ PCI_VDEVICE(ATHEROS, 0x0011) }, /* 5311 - this is on AHB bus !*/
diff --git a/drivers/net/wireless/ath/ath9k/pci.c b/drivers/net/wireless/ath/ath9k/pci.c
index b5656fc..d250ba9 100644
--- a/drivers/net/wireless/ath/ath9k/pci.c
+++ b/drivers/net/wireless/ath/ath9k/pci.c
@@ -23,7 +23,7 @@
 #include <linux/module.h>
 #include "ath9k.h"
 
-static DEFINE_PCI_DEVICE_TABLE(ath_pci_id_table) = {
+static const struct pci_device_id ath_pci_id_table[] = {
 	{ PCI_VDEVICE(ATHEROS, 0x0023) }, /* PCI   */
 	{ PCI_VDEVICE(ATHEROS, 0x0024) }, /* PCI-E */
 	{ PCI_VDEVICE(ATHEROS, 0x0027) }, /* PCI   */
diff --git a/drivers/net/wireless/ath/wil6210/pcie_bus.c b/drivers/net/wireless/ath/wil6210/pcie_bus.c
index eeceab3..4a9e411 100644
--- a/drivers/net/wireless/ath/wil6210/pcie_bus.c
+++ b/drivers/net/wireless/ath/wil6210/pcie_bus.c
@@ -199,7 +199,7 @@ static void wil_pcie_remove(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
-static DEFINE_PCI_DEVICE_TABLE(wil6210_pcie_ids) = {
+static const struct pci_device_id wil6210_pcie_ids[] = {
 	{ PCI_DEVICE(0x1ae9, 0x0301) },
 	{ /* end: all zeroes */	},
 };
diff --git a/drivers/net/wireless/atmel_pci.c b/drivers/net/wireless/atmel_pci.c
index c1b159e..1d437e8 100644
--- a/drivers/net/wireless/atmel_pci.c
+++ b/drivers/net/wireless/atmel_pci.c
@@ -31,7 +31,7 @@ MODULE_DESCRIPTION("Support for Atmel at76c50x 802.11 wireless ethernet cards.")
 MODULE_LICENSE("GPL");
 MODULE_SUPPORTED_DEVICE("Atmel at76c506 PCI wireless cards");
 
-static DEFINE_PCI_DEVICE_TABLE(card_ids) = {
+static const struct pci_device_id card_ids[] = {
 	{ 0x1114, 0x0506, PCI_ANY_ID, PCI_ANY_ID },
 	{ 0, }
 };
diff --git a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
index 05ca340..0949e40 100644
--- a/drivers/net/wireless/hostap/hostap_pci.c
+++ b/drivers/net/wireless/hostap/hostap_pci.c
@@ -40,7 +40,7 @@ struct hostap_pci_priv {
 /* FIX: do we need mb/wmb/rmb with memory operations? */
 
 
-static DEFINE_PCI_DEVICE_TABLE(prism2_pci_id_table) = {
+static const struct pci_device_id prism2_pci_id_table[] = {
 	/* Intersil Prism3 ISL3872 11Mb/s WLAN Controller */
 	{ 0x1260, 0x3872, PCI_ANY_ID, PCI_ANY_ID },
 	/* Intersil Prism2.5 ISL3874 11Mb/s WLAN Controller */
diff --git a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
index c3d067e..99f6843 100644
--- a/drivers/net/wireless/hostap/hostap_plx.c
+++ b/drivers/net/wireless/hostap/hostap_plx.c
@@ -61,7 +61,7 @@ struct hostap_plx_priv {
 
 #define PLXDEV(vendor,dev,str) { vendor, dev, PCI_ANY_ID, PCI_ANY_ID }
 
-static DEFINE_PCI_DEVICE_TABLE(prism2_plx_id_table) = {
+static const struct pci_device_id prism2_plx_id_table[] = {
 	PLXDEV(0x10b7, 0x7770, "3Com AirConnect PCI 777A"),
 	PLXDEV(0x111a, 0x1023, "Siemens SpeedStream SS1023"),
 	PLXDEV(0x126c, 0x8030, "Nortel emobility"),
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index f8ab193..ce57818 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -6512,7 +6512,7 @@ static void ipw2100_shutdown(struct pci_dev *pci_dev)
 
 #define IPW2100_DEV_ID(x) { PCI_VENDOR_ID_INTEL, 0x1043, 0x8086, x }
 
-static DEFINE_PCI_DEVICE_TABLE(ipw2100_pci_id_table) = {
+static const struct pci_device_id ipw2100_pci_id_table[] = {
 	IPW2100_DEV_ID(0x2520),	/* IN 2100A mPCI 3A */
 	IPW2100_DEV_ID(0x2521),	/* IN 2100A mPCI 3B */
 	IPW2100_DEV_ID(0x2524),	/* IN 2100A mPCI 3B */
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 81903e3..a74fd49 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -11542,7 +11542,7 @@ out:
 }
 
 /* PCI driver stuff */
-static DEFINE_PCI_DEVICE_TABLE(card_ids) = {
+static const struct pci_device_id card_ids[] = {
 	{PCI_VENDOR_ID_INTEL, 0x1043, 0x8086, 0x2701, 0, 0, 0},
 	{PCI_VENDOR_ID_INTEL, 0x1043, 0x8086, 0x2702, 0, 0, 0},
 	{PCI_VENDOR_ID_INTEL, 0x1043, 0x8086, 0x2711, 0, 0, 0},
diff --git a/drivers/net/wireless/iwlegacy/3945.c b/drivers/net/wireless/iwlegacy/3945.c
index f09e257..2c40598 100644
--- a/drivers/net/wireless/iwlegacy/3945.c
+++ b/drivers/net/wireless/iwlegacy/3945.c
@@ -2729,7 +2729,7 @@ static struct il_cfg il3945_abg_cfg = {
 	},
 };
 
-DEFINE_PCI_DEVICE_TABLE(il3945_hw_card_ids) = {
+const struct pci_device_id il3945_hw_card_ids[] = {
 	{IL_PCI_DEVICE(0x4222, 0x1005, il3945_bg_cfg)},
 	{IL_PCI_DEVICE(0x4222, 0x1034, il3945_bg_cfg)},
 	{IL_PCI_DEVICE(0x4222, 0x1044, il3945_bg_cfg)},
diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireless/iwlegacy/4965-mac.c
index 3982ab7..4212a8b 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -6811,7 +6811,7 @@ il4965_txq_set_sched(struct il_priv *il, u32 mask)
  *****************************************************************************/
 
 /* Hardware specific file defines the PCI IDs table for that hardware module */
-static DEFINE_PCI_DEVICE_TABLE(il4965_hw_card_ids) = {
+static const struct pci_device_id il4965_hw_card_ids[] = {
 	{IL_PCI_DEVICE(0x4229, PCI_ANY_ID, il4965_cfg)},
 	{IL_PCI_DEVICE(0x4230, PCI_ANY_ID, il4965_cfg)},
 	{0}
diff --git a/drivers/net/wireless/iwlwifi/pcie/drv.c b/drivers/net/wireless/iwlwifi/pcie/drv.c
index 941c0c8..a8e8c60 100644
--- a/drivers/net/wireless/iwlwifi/pcie/drv.c
+++ b/drivers/net/wireless/iwlwifi/pcie/drv.c
@@ -77,7 +77,7 @@
 	.driver_data = (kernel_ulong_t)&(cfg)
 
 /* Hardware specific file defines the PCI IDs table for that hardware module */
-static DEFINE_PCI_DEVICE_TABLE(iwl_hw_card_ids) = {
+static const struct pci_device_id iwl_hw_card_ids[] = {
 #if IS_ENABLED(CONFIG_IWLDVM)
 	{IWL_PCI_DEVICE(0x4232, 0x1201, iwl5100_agn_cfg)}, /* Mini Card */
 	{IWL_PCI_DEVICE(0x4232, 0x1301, iwl5100_agn_cfg)}, /* Half Mini Card */
diff --git a/drivers/net/wireless/mwifiex/pcie.c b/drivers/net/wireless/mwifiex/pcie.c
index 03688aa..cabb0d8 100644
--- a/drivers/net/wireless/mwifiex/pcie.c
+++ b/drivers/net/wireless/mwifiex/pcie.c
@@ -242,7 +242,7 @@ static void mwifiex_pcie_shutdown(struct pci_dev *pdev)
 	return;
 }
 
-static DEFINE_PCI_DEVICE_TABLE(mwifiex_ids) = {
+static const struct pci_device_id mwifiex_ids[] = {
 	{
 		PCIE_VENDOR_ID_MARVELL, PCIE_DEVICE_ID_MARVELL_88W8766P,
 		PCI_ANY_ID, PCI_ANY_ID, 0, 0,
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index b953ad6..26224c5 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -5497,7 +5497,7 @@ MODULE_FIRMWARE("mwl8k/helper_8366.fw");
 MODULE_FIRMWARE("mwl8k/fmimage_8366.fw");
 MODULE_FIRMWARE(MWL8K_8366_AP_FW(MWL8K_8366_AP_FW_API));
 
-static DEFINE_PCI_DEVICE_TABLE(mwl8k_pci_id_table) = {
+static const struct pci_device_id mwl8k_pci_id_table[] = {
 	{ PCI_VDEVICE(MARVELL, 0x2a0a), .driver_data = MWL8363, },
 	{ PCI_VDEVICE(MARVELL, 0x2a0c), .driver_data = MWL8363, },
 	{ PCI_VDEVICE(MARVELL, 0x2a24), .driver_data = MWL8363, },
diff --git a/drivers/net/wireless/orinoco/orinoco_nortel.c b/drivers/net/wireless/orinoco/orinoco_nortel.c
index ffb2469..1b543e3 100644
--- a/drivers/net/wireless/orinoco/orinoco_nortel.c
+++ b/drivers/net/wireless/orinoco/orinoco_nortel.c
@@ -272,7 +272,7 @@ static void orinoco_nortel_remove_one(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
-static DEFINE_PCI_DEVICE_TABLE(orinoco_nortel_id_table) = {
+static const struct pci_device_id orinoco_nortel_id_table[] = {
 	/* Nortel emobility PCI */
 	{0x126c, 0x8030, PCI_ANY_ID, PCI_ANY_ID,},
 	/* Symbol LA-4123 PCI */
diff --git a/drivers/net/wireless/orinoco/orinoco_pci.c b/drivers/net/wireless/orinoco/orinoco_pci.c
index 5ae1191..b6bdad6 100644
--- a/drivers/net/wireless/orinoco/orinoco_pci.c
+++ b/drivers/net/wireless/orinoco/orinoco_pci.c
@@ -210,7 +210,7 @@ static void orinoco_pci_remove_one(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
-static DEFINE_PCI_DEVICE_TABLE(orinoco_pci_id_table) = {
+static const struct pci_device_id orinoco_pci_id_table[] = {
 	/* Intersil Prism 3 */
 	{0x1260, 0x3872, PCI_ANY_ID, PCI_ANY_ID,},
 	/* Intersil Prism 2.5 */
diff --git a/drivers/net/wireless/orinoco/orinoco_plx.c b/drivers/net/wireless/orinoco/orinoco_plx.c
index bbd36d1..b8f6e5c 100644
--- a/drivers/net/wireless/orinoco/orinoco_plx.c
+++ b/drivers/net/wireless/orinoco/orinoco_plx.c
@@ -308,7 +308,7 @@ static void orinoco_plx_remove_one(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
-static DEFINE_PCI_DEVICE_TABLE(orinoco_plx_id_table) = {
+static const struct pci_device_id orinoco_plx_id_table[] = {
 	{0x111a, 0x1023, PCI_ANY_ID, PCI_ANY_ID,},	/* Siemens SpeedStream SS1023 */
 	{0x1385, 0x4100, PCI_ANY_ID, PCI_ANY_ID,},	/* Netgear MA301 */
 	{0x15e8, 0x0130, PCI_ANY_ID, PCI_ANY_ID,},	/* Correga  - does this work? */
diff --git a/drivers/net/wireless/orinoco/orinoco_tmd.c b/drivers/net/wireless/orinoco/orinoco_tmd.c
index 04b08de..79d0e33 100644
--- a/drivers/net/wireless/orinoco/orinoco_tmd.c
+++ b/drivers/net/wireless/orinoco/orinoco_tmd.c
@@ -201,7 +201,7 @@ static void orinoco_tmd_remove_one(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
-static DEFINE_PCI_DEVICE_TABLE(orinoco_tmd_id_table) = {
+static const struct pci_device_id orinoco_tmd_id_table[] = {
 	{0x15e8, 0x0131, PCI_ANY_ID, PCI_ANY_ID,},      /* NDC and OEMs, e.g. pheecom */
 	{0,},
 };
diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index f9a07b0..1292a22 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -33,7 +33,7 @@ MODULE_LICENSE("GPL");
 MODULE_ALIAS("prism54pci");
 MODULE_FIRMWARE("isl3886pci");
 
-static DEFINE_PCI_DEVICE_TABLE(p54p_table) = {
+static const struct pci_device_id p54p_table[] = {
 	/* Intersil PRISM Duette/Prism GT Wireless LAN adapter */
 	{ PCI_DEVICE(0x1260, 0x3890) },
 	/* 3COM 3CRWE154G72 Wireless LAN adapter */
diff --git a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/wireless/prism54/islpci_hotplug.c
index 9e68e0c..f68ddba 100644
--- a/drivers/net/wireless/prism54/islpci_hotplug.c
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c
@@ -40,7 +40,7 @@ module_param(init_pcitm, int, 0);
  * driver_data
  * If you have an update for this please contact prism54-devel@prism54.org
  * The latest list can be found at http://wireless.kernel.org/en/users/Drivers/p54 */
-static DEFINE_PCI_DEVICE_TABLE(prism54_id_tbl) = {
+static const struct pci_device_id prism54_id_tbl[] = {
 	/* Intersil PRISM Duette/Prism GT Wireless LAN adapter */
 	{
 	 0x1260, 0x3890,
diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wireless/rt2x00/rt2400pci.c
index 38ed9a3..cbed6d4 100644
--- a/drivers/net/wireless/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/rt2x00/rt2400pci.c
@@ -1824,7 +1824,7 @@ static const struct rt2x00_ops rt2400pci_ops = {
 /*
  * RT2400pci module information.
  */
-static DEFINE_PCI_DEVICE_TABLE(rt2400pci_device_table) = {
+static const struct pci_device_id rt2400pci_device_table[] = {
 	{ PCI_DEVICE(0x1814, 0x0101) },
 	{ 0, }
 };
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless/rt2x00/rt2500pci.c
index 0ac5c58..a8c5bdd 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -2113,7 +2113,7 @@ static const struct rt2x00_ops rt2500pci_ops = {
 /*
  * RT2500pci module information.
  */
-static DEFINE_PCI_DEVICE_TABLE(rt2500pci_device_table) = {
+static const struct pci_device_id rt2500pci_device_table[] = {
 	{ PCI_DEVICE(0x1814, 0x0201) },
 	{ 0, }
 };
diff --git a/drivers/net/wireless/rt2x00/rt2800pci.c b/drivers/net/wireless/rt2x00/rt2800pci.c
index b504455..339899c 100644
--- a/drivers/net/wireless/rt2x00/rt2800pci.c
+++ b/drivers/net/wireless/rt2x00/rt2800pci.c
@@ -402,7 +402,7 @@ static const struct rt2x00_ops rt2800pci_ops = {
 /*
  * RT2800pci module information.
  */
-static DEFINE_PCI_DEVICE_TABLE(rt2800pci_device_table) = {
+static const struct pci_device_id rt2800pci_device_table[] = {
 	{ PCI_DEVICE(0x1814, 0x0601) },
 	{ PCI_DEVICE(0x1814, 0x0681) },
 	{ PCI_DEVICE(0x1814, 0x0701) },
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index a5b69cb..c8f90c2 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -3078,7 +3078,7 @@ static const struct rt2x00_ops rt61pci_ops = {
 /*
  * RT61pci module information.
  */
-static DEFINE_PCI_DEVICE_TABLE(rt61pci_device_table) = {
+static const struct pci_device_id rt61pci_device_table[] = {
 	/* RT2561s */
 	{ PCI_DEVICE(0x1814, 0x0301) },
 	/* RT2561 v2 */
diff --git a/drivers/net/wireless/rtl818x/rtl8180/dev.c b/drivers/net/wireless/rtl818x/rtl8180/dev.c
index a91506b..ec3d49a 100644
--- a/drivers/net/wireless/rtl818x/rtl8180/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8180/dev.c
@@ -36,7 +36,7 @@ MODULE_AUTHOR("Andrea Merello <andrea.merello@gmail.com>");
 MODULE_DESCRIPTION("RTL8180 / RTL8185 PCI wireless driver");
 MODULE_LICENSE("GPL");
 
-static DEFINE_PCI_DEVICE_TABLE(rtl8180_table) = {
+static const struct pci_device_id rtl8180_table[] = {
 	/* rtl8185 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8185) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BELKIN, 0x700f) },
diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
index 347af1e..ebeb8b3 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
@@ -363,7 +363,7 @@ static struct rtl_hal_cfg rtl88ee_hal_cfg = {
 	.maps[RTL_RC_HT_RATEMCS15] = DESC92C_RATEMCS15,
 };
 
-static DEFINE_PCI_DEVICE_TABLE(rtl88ee_pci_ids) = {
+static const struct pci_device_id rtl88ee_pci_ids[] = {
 	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8179, rtl88ee_hal_cfg)},
 	{},
 };
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
index b790320..3c21812 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
@@ -345,7 +345,7 @@ static struct rtl_hal_cfg rtl92ce_hal_cfg = {
 	.maps[RTL_RC_HT_RATEMCS15] = DESC92_RATEMCS15,
 };
 
-static DEFINE_PCI_DEVICE_TABLE(rtl92ce_pci_ids) = {
+static const struct pci_device_id rtl92ce_pci_ids[] = {
 	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8191, rtl92ce_hal_cfg)},
 	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8178, rtl92ce_hal_cfg)},
 	{RTL_PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8177, rtl92ce_hal_cfg)},
-- 
1.7.10.4
