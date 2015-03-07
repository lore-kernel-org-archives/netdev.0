From: Joe Perches <joe@perches.com>
Subject: [trivial PATCH net-next] ethernet: codespell comment spelling fixes
Date: Fri, 06 Mar 2015 20:49:12 -0800
Message-ID: <1425703752.12017.66.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Masanari Iida <standby24x7@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0220.hostedemail.com ([216.40.44.220]:35594 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752501AbbCGEtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 23:49:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To test a checkpatch spelling patch, I ran codespell against
drivers/net/ethernet/.

$ git ls-files drivers/net/ethernet/ | \
  while read file ; do \
    codespell -w $file; \
  done

I removed a false positive in e1000_hw.h

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/allwinner/sun4i-emac.c          |  2 +-
 drivers/net/ethernet/amd/amd8111e.c                  |  4 ++--
 drivers/net/ethernet/amd/amd8111e.h                  |  2 +-
 drivers/net/ethernet/amd/xgbe/xgbe.h                 |  2 +-
 drivers/net/ethernet/apple/mace.c                    |  2 +-
 drivers/net/ethernet/apple/macmace.c                 |  2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c        |  4 ++--
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c      |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h     |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c     | 12 ++++++------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h      |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c    |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c     |  4 ++--
 drivers/net/ethernet/brocade/bna/bfa_defs_cna.h      |  2 +-
 drivers/net/ethernet/brocade/bna/bfa_ioc.c           |  2 +-
 drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c        |  2 +-
 drivers/net/ethernet/brocade/bna/bfi.h               |  4 ++--
 drivers/net/ethernet/brocade/bna/bna_hw_defs.h       |  2 +-
 drivers/net/ethernet/calxeda/xgmac.c                 | 20 ++++++++++----------
 drivers/net/ethernet/chelsio/cxgb3/t3_hw.c           |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c      |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c           |  6 +++---
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h        |  2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c           |  2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c       |  2 +-
 drivers/net/ethernet/cirrus/cs89x0.c                 |  2 +-
 drivers/net/ethernet/dec/tulip/dmfe.c                |  2 +-
 drivers/net/ethernet/dec/tulip/uli526x.c             |  2 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c          |  2 +-
 drivers/net/ethernet/freescale/fec_ptp.c             |  2 +-
 drivers/net/ethernet/intel/e100.c                    |  2 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c        |  2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c      |  4 ++--
 drivers/net/ethernet/intel/igb/igb_ptp.c             |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c        |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c         |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c       |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h        |  2 +-
 drivers/net/ethernet/intel/ixgbevf/vf.c              |  2 +-
 drivers/net/ethernet/marvell/mvpp2.c                 |  4 ++--
 drivers/net/ethernet/mellanox/mlx4/mlx4.h            |  2 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c    |  2 +-
 drivers/net/ethernet/moxa/moxart_ether.c             |  2 +-
 drivers/net/ethernet/neterion/s2io.c                 |  2 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c  |  2 +-
 drivers/net/ethernet/packetengines/hamachi.c         |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h  |  2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c    |  4 ++--
 drivers/net/ethernet/qualcomm/qca_spi.c              |  2 +-
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c      | 12 ++++++------
 drivers/net/ethernet/sfc/efx.c                       |  2 +-
 drivers/net/ethernet/sfc/farch.c                     |  4 ++--
 drivers/net/ethernet/sfc/mcdi_pcol.h                 |  2 +-
 drivers/net/ethernet/sfc/siena_sriov.c               |  2 +-
 drivers/net/ethernet/sfc/vfdi.h                      |  4 ++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c    |  2 +-
 drivers/net/ethernet/sun/sungem.c                    |  4 ++--
 drivers/net/ethernet/ti/cpsw.c                       |  2 +-
 drivers/net/ethernet/toshiba/ps3_gelic_net.c         |  2 +-
 drivers/net/ethernet/wiznet/w5100.c                  |  2 +-
 drivers/net/ethernet/wiznet/w5300.c                  |  2 +-
 61 files changed, 92 insertions(+), 92 deletions(-)

diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index f3470d9..bab01c84 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -757,7 +757,7 @@ static void emac_shutdown(struct net_device *dev)
 	/* Disable all interrupt */
 	writel(0, db->membase + EMAC_INT_CTL_REG);
 
-	/* clear interupt status */
+	/* clear interrupt status */
 	reg_val = readl(db->membase + EMAC_INT_STA_REG);
 	writel(reg_val, db->membase + EMAC_INT_STA_REG);
 
diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 4c2ae22..9496005 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -723,13 +723,13 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 			 * the last correctly noting the error.
 			 */
 			if(status & ERR_BIT) {
-				/* reseting flags */
+				/* resetting flags */
 				lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
 				goto err_next_pkt;
 			}
 			/* check for STP and ENP */
 			if(!((status & STP_BIT) && (status & ENP_BIT))){
-				/* reseting flags */
+				/* resetting flags */
 				lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
 				goto err_next_pkt;
 			}
diff --git a/drivers/net/ethernet/amd/amd8111e.h b/drivers/net/ethernet/amd/amd8111e.h
index a75092d..7cdb185 100644
--- a/drivers/net/ethernet/amd/amd8111e.h
+++ b/drivers/net/ethernet/amd/amd8111e.h
@@ -614,7 +614,7 @@ typedef enum {
 /* Assume contoller gets data 10 times the maximum processing time */
 #define  REPEAT_CNT			10
 
-/* amd8111e decriptor flag definitions */
+/* amd8111e descriptor flag definitions */
 typedef enum {
 
 	OWN_BIT		=	(1 << 15),
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 13e8f95..1eea3e5 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -620,7 +620,7 @@ struct xgbe_hw_features {
 	unsigned int mgk;		/* PMT magic packet */
 	unsigned int mmc;		/* RMON module */
 	unsigned int aoe;		/* ARP Offload */
-	unsigned int ts;		/* IEEE 1588-2008 Adavanced Timestamp */
+	unsigned int ts;		/* IEEE 1588-2008 Advanced Timestamp */
 	unsigned int eee;		/* Energy Efficient Ethernet */
 	unsigned int tx_coe;		/* Tx Checksum Offload */
 	unsigned int rx_coe;		/* Rx Checksum Offload */
diff --git a/drivers/net/ethernet/apple/mace.c b/drivers/net/ethernet/apple/mace.c
index 842fe76..7fcaf0d 100644
--- a/drivers/net/ethernet/apple/mace.c
+++ b/drivers/net/ethernet/apple/mace.c
@@ -720,7 +720,7 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
 	    mace_reset(dev);
 		/*
 		 * XXX mace likes to hang the machine after a xmtfs error.
-		 * This is hard to reproduce, reseting *may* help
+		 * This is hard to reproduce, resetting *may* help
 		 */
 	}
 	cp = mp->tx_cmds + NCMDS_TX * i;
diff --git a/drivers/net/ethernet/apple/macmace.c b/drivers/net/ethernet/apple/macmace.c
index 6e66127..89914ca 100644
--- a/drivers/net/ethernet/apple/macmace.c
+++ b/drivers/net/ethernet/apple/macmace.c
@@ -575,7 +575,7 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
 			mace_reset(dev);
 			/*
 			 * XXX mace likes to hang the machine after a xmtfs error.
-			 * This is hard to reproduce, reseting *may* help
+			 * This is hard to reproduce, resetting *may* help
 			 */
 		}
 		/* dma should have finished */
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
index 52fdfe2..a8b80c5 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.c
@@ -307,7 +307,7 @@ void atl1c_start_phy_polling(struct atl1c_hw *hw, u16 clk_sel)
 
 /*
  * atl1c_read_phy_core
- * core funtion to read register in PHY via MDIO control regsiter.
+ * core function to read register in PHY via MDIO control regsiter.
  * ext: extension register (see IEEE 802.3)
  * dev: device address (see IEEE 802.3 DEVAD, PRTAD is fixed to 0)
  * reg: reg to read
@@ -356,7 +356,7 @@ int atl1c_read_phy_core(struct atl1c_hw *hw, bool ext, u8 dev,
 
 /*
  * atl1c_write_phy_core
- * core funtion to write to register in PHY via MDIO control regsiter.
+ * core function to write to register in PHY via MDIO control register.
  * ext: extension register (see IEEE 802.3)
  * dev: device address (see IEEE 802.3 DEVAD, PRTAD is fixed to 0)
  * reg: reg to write
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 587f63e..932bd18 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -752,7 +752,7 @@ static void atl1c_patch_assign(struct atl1c_hw *hw)
 
 	if (hw->device_id == PCI_DEVICE_ID_ATHEROS_L2C_B2 &&
 	    hw->revision_id == L2CB_V21) {
-		/* config acess mode */
+		/* config access mode */
 		pci_write_config_dword(pdev, REG_PCIE_IND_ACC_ADDR,
 				       REG_PCIE_DEV_MISC_CTRL);
 		pci_read_config_dword(pdev, REG_PCIE_IND_ACC_DATA, &misc_ctrl);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
index bd90e50..d6e1975 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
@@ -278,7 +278,7 @@ static inline void bnx2x_dcb_config_qm(struct bnx2x *bp, enum cos_mode mode,
 }
 
 
-/* congestion managment port init api description
+/* congestion management port init api description
  * the api works as follows:
  * the driver should pass the cmng_init_input struct, the port_init function
  * will prepare the required internal ram structure which will be passed back
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 778e4cd..b7c77b2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -563,7 +563,7 @@ static void bnx2x_ets_e3b0_set_credit_upper_bound_nig(
 *	Will return the NIG ETS registers to init values.Except
 *	credit_upper_bound.
 *	That isn't used in this configuration (No WFQ is enabled) and will be
-*	configured acording to spec
+*	configured according to spec
 *.
 ******************************************************************************/
 static void bnx2x_ets_e3b0_nig_disabled(const struct link_params *params,
@@ -680,7 +680,7 @@ static void bnx2x_ets_e3b0_set_credit_upper_bound_pbf(
 *	Will return the PBF ETS registers to init values.Except
 *	credit_upper_bound.
 *	That isn't used in this configuration (No WFQ is enabled) and will be
-*	configured acording to spec
+*	configured according to spec
 *.
 ******************************************************************************/
 static void bnx2x_ets_e3b0_pbf_disabled(const struct link_params *params)
@@ -738,7 +738,7 @@ static void bnx2x_ets_e3b0_pbf_disabled(const struct link_params *params)
 }
 /******************************************************************************
 * Description:
-*	E3B0 disable will return basicly the values to init values.
+*	E3B0 disable will return basically the values to init values.
 *.
 ******************************************************************************/
 static int bnx2x_ets_e3b0_disabled(const struct link_params *params,
@@ -761,7 +761,7 @@ static int bnx2x_ets_e3b0_disabled(const struct link_params *params,
 
 /******************************************************************************
 * Description:
-*	Disable will return basicly the values to init values.
+*	Disable will return basically the values to init values.
 *
 ******************************************************************************/
 int bnx2x_ets_disabled(struct link_params *params,
@@ -2938,7 +2938,7 @@ static int bnx2x_eee_initial_config(struct link_params *params,
 {
 	vars->eee_status |= ((u32) mode) << SHMEM_EEE_SUPPORTED_SHIFT;
 
-	/* Propogate params' bits --> vars (for migration exposure) */
+	/* Propagate params' bits --> vars (for migration exposure) */
 	if (params->eee_mode & EEE_MODE_ENABLE_LPI)
 		vars->eee_status |= SHMEM_EEE_LPI_REQUESTED_BIT;
 	else
@@ -13308,7 +13308,7 @@ static void bnx2x_check_over_curr(struct link_params *params,
 		vars->phy_flags &= ~PHY_OVER_CURRENT_FLAG;
 }
 
-/* Returns 0 if no change occured since last check; 1 otherwise. */
+/* Returns 0 if no change occurred since last check; 1 otherwise. */
 static u8 bnx2x_analyze_link_error(struct link_params *params,
 				    struct link_vars *vars, u32 status,
 				    u32 phy_flag, u32 link_flag, u8 notify)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index 6fe547c..0770e4b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -29,7 +29,7 @@
 #define ATC_ATC_INT_STS_REG_ATC_TCPL_TO_NOT_PEND		 (0x1<<1)
 /* [RW 1] Initiate the ATC array - reset all the valid bits */
 #define ATC_REG_ATC_INIT_ARRAY					 0x1100b8
-/* [R 1] ATC initalization done */
+/* [R 1] ATC initialization done */
 #define ATC_REG_ATC_INIT_DONE					 0x1100bc
 /* [RC 6] Interrupt register #0 read clear */
 #define ATC_REG_ATC_INT_STS_CLR					 0x1101c0
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index d160829..612cafb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1620,7 +1620,7 @@ void bnx2x_memset_stats(struct bnx2x *bp)
 	if (bp->port.pmf && bp->port.port_stx)
 		bnx2x_port_stats_base_init(bp);
 
-	/* mark the end of statistics initializiation */
+	/* mark the end of statistics initialization */
 	bp->stats_init = false;
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index be40eab..15b2d16 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -800,7 +800,7 @@ int bnx2x_vfpf_config_rss(struct bnx2x *bp,
 	req->rss_key_size = T_ETH_RSS_KEY;
 	req->rss_result_mask = params->rss_result_mask;
 
-	/* flags handled individually for backward/forward compatability */
+	/* flags handled individually for backward/forward compatibility */
 	if (params->rss_flags & (1 << BNX2X_RSS_MODE_DISABLED))
 		req->rss_flags |= VFPF_RSS_MODE_DISABLED;
 	if (params->rss_flags & (1 << BNX2X_RSS_MODE_REGULAR))
@@ -1869,7 +1869,7 @@ static void bnx2x_vf_mbx_update_rss(struct bnx2x *bp, struct bnx2x_virtf *vf,
 	rss.rss_obj = &vf->rss_conf_obj;
 	rss.rss_result_mask = rss_tlv->rss_result_mask;
 
-	/* flags handled individually for backward/forward compatability */
+	/* flags handled individually for backward/forward compatibility */
 	rss.rss_flags = 0;
 	rss.ramrod_flags = 0;
 
diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h b/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h
index 63e300f..a37326d 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h
@@ -135,7 +135,7 @@ struct bfa_cee_lldp_str {
 	u8 value[BFA_CEE_LLDP_MAX_STRING_LEN];
 };
 
-/* LLDP paramters */
+/* LLDP parameters */
 struct bfa_cee_lldp_cfg {
 	struct bfa_cee_lldp_str chassis_id;
 	struct bfa_cee_lldp_str port_id;
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index f2d1323..594a2ab 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -1340,7 +1340,7 @@ bfa_ioc_fwver_md5_check(struct bfi_ioc_image_hdr *fwhdr_1,
 	return true;
 }
 
-/* Returns TRUE if major minor and maintainence are same.
+/* Returns TRUE if major minor and maintenance are same.
  * If patch version are same, check for MD5 Checksum to be same.
  */
 static bool
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
index 66c8507..2e72445 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
@@ -699,7 +699,7 @@ bfa_ioc_ct2_sclk_init(void __iomem *rb)
 
 	/*
 	 * Ignore mode and program for the max clock (which is FC16)
-	 * Firmware/NFC will do the PLL init appropiately
+	 * Firmware/NFC will do the PLL init appropriately
 	 */
 	r32 = readl((rb + CT2_APP_PLL_SCLK_CTL_REG));
 	r32 &= ~(__APP_PLL_SCLK_REFCLK_SEL | __APP_PLL_SCLK_CLK_DIV2);
diff --git a/drivers/net/ethernet/brocade/bna/bfi.h b/drivers/net/ethernet/brocade/bna/bfi.h
index f1e1129..2bcde40 100644
--- a/drivers/net/ethernet/brocade/bna/bfi.h
+++ b/drivers/net/ethernet/brocade/bna/bfi.h
@@ -159,8 +159,8 @@ enum bfi_asic_gen {
 };
 
 enum bfi_asic_mode {
-	BFI_ASIC_MODE_FC	= 1,	/* FC upto 8G speed		*/
-	BFI_ASIC_MODE_FC16	= 2,	/* FC upto 16G speed		*/
+	BFI_ASIC_MODE_FC	= 1,	/* FC up to 8G speed		*/
+	BFI_ASIC_MODE_FC16	= 2,	/* FC up to 16G speed		*/
 	BFI_ASIC_MODE_ETH	= 3,	/* Ethernet ports		*/
 	BFI_ASIC_MODE_COMBO	= 4,	/* FC 16G and Ethernet 10G port	*/
 };
diff --git a/drivers/net/ethernet/brocade/bna/bna_hw_defs.h b/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
index c5feab1..174af0e 100644
--- a/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
+++ b/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
@@ -363,7 +363,7 @@ struct bna_txq_wi_vector {
 
 /*  TxQ Entry Structure
  *
- *  BEWARE:  Load values into this structure with correct endianess.
+ *  BEWARE:  Load values into this structure with correct endianness.
  */
 struct bna_txq_entry {
 	union {
diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 47bfea2..63efa0d 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -47,9 +47,9 @@
 #define XGMAC_REMOTE_WAKE	0x00000700	/* Remote Wake-Up Frm Filter */
 #define XGMAC_PMT		0x00000704	/* PMT Control and Status */
 #define XGMAC_MMC_CTRL		0x00000800	/* XGMAC MMC Control */
-#define XGMAC_MMC_INTR_RX	0x00000804	/* Recieve Interrupt */
+#define XGMAC_MMC_INTR_RX	0x00000804	/* Receive Interrupt */
 #define XGMAC_MMC_INTR_TX	0x00000808	/* Transmit Interrupt */
-#define XGMAC_MMC_INTR_MASK_RX	0x0000080c	/* Recieve Interrupt Mask */
+#define XGMAC_MMC_INTR_MASK_RX	0x0000080c	/* Receive Interrupt Mask */
 #define XGMAC_MMC_INTR_MASK_TX	0x00000810	/* Transmit Interrupt Mask */
 
 /* Hardware TX Statistics Counters */
@@ -153,7 +153,7 @@
 #define XGMAC_FLOW_CTRL_PT_MASK	0xffff0000	/* Pause Time Mask */
 #define XGMAC_FLOW_CTRL_PT_SHIFT	16
 #define XGMAC_FLOW_CTRL_DZQP	0x00000080	/* Disable Zero-Quanta Phase */
-#define XGMAC_FLOW_CTRL_PLT	0x00000020	/* Pause Low Threshhold */
+#define XGMAC_FLOW_CTRL_PLT	0x00000020	/* Pause Low Threshold */
 #define XGMAC_FLOW_CTRL_PLT_MASK 0x00000030	/* PLT MASK */
 #define XGMAC_FLOW_CTRL_UP	0x00000008	/* Unicast Pause Frame Detect */
 #define XGMAC_FLOW_CTRL_RFE	0x00000004	/* Rx Flow Control Enable */
@@ -254,18 +254,18 @@
 /* XGMAC Operation Mode Register */
 #define XGMAC_OMR_TSF		0x00200000	/* TX FIFO Store and Forward */
 #define XGMAC_OMR_FTF		0x00100000	/* Flush Transmit FIFO */
-#define XGMAC_OMR_TTC		0x00020000	/* Transmit Threshhold Ctrl */
+#define XGMAC_OMR_TTC		0x00020000	/* Transmit Threshold Ctrl */
 #define XGMAC_OMR_TTC_MASK	0x00030000
-#define XGMAC_OMR_RFD		0x00006000	/* FC Deactivation Threshhold */
-#define XGMAC_OMR_RFD_MASK	0x00007000	/* FC Deact Threshhold MASK */
-#define XGMAC_OMR_RFA		0x00000600	/* FC Activation Threshhold */
-#define XGMAC_OMR_RFA_MASK	0x00000E00	/* FC Act Threshhold MASK */
+#define XGMAC_OMR_RFD		0x00006000	/* FC Deactivation Threshold */
+#define XGMAC_OMR_RFD_MASK	0x00007000	/* FC Deact Threshold MASK */
+#define XGMAC_OMR_RFA		0x00000600	/* FC Activation Threshold */
+#define XGMAC_OMR_RFA_MASK	0x00000E00	/* FC Act Threshold MASK */
 #define XGMAC_OMR_EFC		0x00000100	/* Enable Hardware FC */
 #define XGMAC_OMR_FEF		0x00000080	/* Forward Error Frames */
 #define XGMAC_OMR_DT		0x00000040	/* Drop TCP/IP csum Errors */
 #define XGMAC_OMR_RSF		0x00000020	/* RX FIFO Store and Forward */
-#define XGMAC_OMR_RTC_256	0x00000018	/* RX Threshhold Ctrl */
-#define XGMAC_OMR_RTC_MASK	0x00000018	/* RX Threshhold Ctrl MASK */
+#define XGMAC_OMR_RTC_256	0x00000018	/* RX Threshold Ctrl */
+#define XGMAC_OMR_RTC_MASK	0x00000018	/* RX Threshold Ctrl MASK */
 
 /* XGMAC HW Features Register */
 #define DMA_HW_FEAT_TXCOESEL	0x00010000	/* TX Checksum offload */
diff --git a/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c b/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
index 184a8d5..a22768c 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
@@ -840,7 +840,7 @@ static int flash_wait_op(struct adapter *adapter, int attempts, int delay)
  *	Read the specified number of 32-bit words from the serial flash.
  *	If @byte_oriented is set the read data is stored as a byte array
  *	(i.e., big-endian), otherwise as 32-bit words in the platform's
- *	natural endianess.
+ *	natural endianness.
  */
 static int t3_read_flash(struct adapter *adapter, unsigned int addr,
 			 unsigned int nwords, u32 *data, int byte_oriented)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index e344bdc..4af8a9f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5366,7 +5366,7 @@ static int adap_init0(struct adapter *adap)
 		adap->tids.stid_base = val[1];
 		adap->tids.nstids = val[2] - val[1] + 1;
 		/*
-		 * Setup server filter region. Divide the availble filter
+		 * Setup server filter region. Divide the available filter
 		 * region into two parts. Regular filters get 1/3rd and server
 		 * filters get 2/3rd part. This is only enabled if workarond
 		 * path is enabled.
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 853c389..1498d07 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -867,7 +867,7 @@ static int flash_wait_op(struct adapter *adapter, int attempts, int delay)
  *	Read the specified number of 32-bit words from the serial flash.
  *	If @byte_oriented is set the read data is stored as a byte array
  *	(i.e., big-endian), otherwise as 32-bit words in the platform's
- *	natural endianess.
+ *	natural endianness.
  */
 int t4_read_flash(struct adapter *adapter, unsigned int addr,
 		  unsigned int nwords, u32 *data, int byte_oriented)
@@ -3558,7 +3558,7 @@ int t4_fixup_host_params(struct adapter *adap, unsigned int page_size,
 	 * For the single-MTU buffers in unpacked mode we need to include
 	 * space for the SGE Control Packet Shift, 14 byte Ethernet header,
 	 * possible 4 byte VLAN tag, all rounded up to the next Ingress Packet
-	 * Padding boundry.  All of these are accommodated in the Factory
+	 * Padding boundary.  All of these are accommodated in the Factory
 	 * Default Firmware Configuration File but we need to adjust it for
 	 * this host's cache line size.
 	 */
@@ -4529,7 +4529,7 @@ int t4_init_tp_params(struct adapter *adap)
 							       PROTOCOL_F);
 
 	/* If TP_INGRESS_CONFIG.VNID == 0, then TP_VLAN_PRI_MAP.VNIC_ID
-	 * represents the presense of an Outer VLAN instead of a VNIC ID.
+	 * represents the presence of an Outer VLAN instead of a VNIC ID.
 	 */
 	if ((adap->params.tp.ingress_config & VNIC_F) == 0)
 		adap->params.tp.vnic_shift = -1;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 9b353a8..d136ca6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -36,7 +36,7 @@
 #define _T4FW_INTERFACE_H_
 
 enum fw_retval {
-	FW_SUCCESS		= 0,	/* completed sucessfully */
+	FW_SUCCESS		= 0,	/* completed successfully */
 	FW_EPERM		= 1,	/* operation not permitted */
 	FW_ENOENT		= 2,	/* no such file or directory */
 	FW_EIO			= 5,	/* input/output error; hw bad */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 0545f0d..5ba14b3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -875,7 +875,7 @@ static inline unsigned int calc_tx_flits(const struct sk_buff *skb)
 	 * Write Header (incorporated as part of the cpl_tx_pkt_lso and
 	 * cpl_tx_pkt structures), followed by either a TX Packet Write CPL
 	 * message or, if we're doing a Large Send Offload, an LSO CPL message
-	 * with an embeded TX Packet Write CPL message.
+	 * with an embedded TX Packet Write CPL message.
 	 */
 	flits = sgl_len(skb_shinfo(skb)->nr_frags + 1);
 	if (skb_shinfo(skb)->gso_size)
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 1b5506d..c21e2e9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -339,7 +339,7 @@ int t4vf_port_init(struct adapter *adapter, int pidx)
  *      @adapter: the adapter
  *
  *	Issues a reset command to FW.  For a Physical Function this would
- *	result in the Firmware reseting all of its state.  For a Virtual
+ *	result in the Firmware resetting all of its state.  For a Virtual
  *	Function this just resets the state associated with the VF.
  */
 int t4vf_fw_reset(struct adapter *adapter)
diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index d1c025f..6038304 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -1578,7 +1578,7 @@ out1:
 
 #ifndef CONFIG_CS89x0_PLATFORM
 /*
- * This function converts the I/O port addres used by the cs89x0_probe() and
+ * This function converts the I/O port address used by the cs89x0_probe() and
  * init_module() functions to the I/O memory address used by the
  * cs89x0_probe1() function.
  */
diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index 50a0077..afd8e78 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -653,7 +653,7 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
 	if ( !(db->media_mode & DMFE_AUTO) )
 		db->op_mode = db->media_mode; 	/* Force Mode */
 
-	/* Initialize Transmit/Receive decriptor and CR3/4 */
+	/* Initialize Transmit/Receive descriptor and CR3/4 */
 	dmfe_descriptor_init(dev);
 
 	/* Init CR6 to program DM910x operation */
diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index 1c5916b..2c30c0c 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -564,7 +564,7 @@ static void uli526x_init(struct net_device *dev)
 	if ( !(db->media_mode & ULI526X_AUTO) )
 		db->op_mode = db->media_mode;		/* Force Mode */
 
-	/* Initialize Transmit/Receive decriptor and CR3/4 */
+	/* Initialize Transmit/Receive descriptor and CR3/4 */
 	uli526x_descriptor_init(dev, ioaddr);
 
 	/* Init CR6 to program M526X operation */
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 75cb461..dc27839 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -3021,7 +3021,7 @@ int be_cmd_get_mac_from_list(struct be_adapter *adapter, u8 *mac,
 
 		mac_count = resp->true_mac_count + resp->pseudo_mac_count;
 		/* Mac list returned could contain one or more active mac_ids
-		 * or one or more true or pseudo permanant mac addresses.
+		 * or one or more true or pseudo permanent mac addresses.
 		 * If an active mac_id is present, return first active mac_id
 		 * found.
 		 */
diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 1f9cf23..4585895 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -136,7 +136,7 @@ static int fec_ptp_enable_pps(struct fec_enet_private *fep, uint enable)
 		 */
 		writel(FEC_T_TF_MASK, fep->hwp + FEC_TCSR(fep->pps_channel));
 
-		/* It is recommended to doulbe check the TMODE field in the
+		/* It is recommended to double check the TMODE field in the
 		 * TCSR register to be cleared before the first compare counter
 		 * is written into TCCR register. Just add a double check.
 		 */
diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index e9c3a87..05f8839 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -414,7 +414,7 @@ enum cb_status {
 
 /**
  * cb_command - Command Block flags
- * @cb_tx_nc:  0: controler does CRC (normal),  1: CRC from skb memory
+ * @cb_tx_nc:  0: controller does CRC (normal),  1: CRC from skb memory
  */
 enum cb_command {
 	cb_nop    = 0x0000,
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 73c98d3..b548ef0 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -1116,7 +1116,7 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		if (e1000_read_mac_addr(hw))
 			e_err(probe, "EEPROM Read Error\n");
 	}
-	/* don't block initalization here due to bad MAC address */
+	/* don't block initialization here due to bad MAC address */
 	memcpy(netdev->dev_addr, hw->mac_addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->dev_addr))
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 3d53bb4..e7a94a6 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2009,7 +2009,7 @@ static int i40evf_check_reset_complete(struct i40e_hw *hw)
  *
  * This task completes the work that was begun in probe. Due to the nature
  * of VF-PF communications, we may need to wait tens of milliseconds to get
- * reponses back from the PF. Rather than busy-wait in probe and bog down the
+ * responses back from the PF. Rather than busy-wait in probe and bog down the
  * whole system, we'll do it in a task so we can sleep.
  * This task only runs during driver init. Once we've established
  * communications with the PF driver and set up our netdev, the watchdog
@@ -2400,7 +2400,7 @@ static int i40evf_suspend(struct pci_dev *pdev, pm_message_t state)
 }
 
 /**
- * i40evf_resume - Power managment resume routine
+ * i40evf_resume - Power management resume routine
  * @pdev: PCI device information struct
  *
  * Called when the system (VM) is resumed from sleep/suspend.
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index d6be4c6..52d01b8 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -30,7 +30,7 @@
  *
  * Neither the 82576 nor the 82580 offer registers wide enough to hold
  * nanoseconds time values for very long. For the 82580, SYSTIM always
- * counts nanoseconds, but the upper 24 bits are not availible. The
+ * counts nanoseconds, but the upper 24 bits are not available. The
  * frequency is adjusted by changing the 32 bit fractional nanoseconds
  * register, TIMINCA.
  *
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 903664f..21aea7e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2609,7 +2609,7 @@ static irqreturn_t ixgbe_msix_other(int irq, void *data)
 	eicr = IXGBE_READ_REG(hw, IXGBE_EICS);
 
 	/* The lower 16bits of the EICR register are for the queue interrupts
-	 * which should be masked here in order to not accidently clear them if
+	 * which should be masked here in order to not accidentally clear them if
 	 * the bits are high when ixgbe_msix_other is called. There is a race
 	 * condition otherwise which results in possible performance loss
 	 * especially if the ixgbe_msix_other interrupt is triggering
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 79c00f5..bd46f5d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -488,7 +488,7 @@ static void ixgbe_ptp_tx_hwtstamp(struct ixgbe_adapter *adapter)
  * @work: pointer to the work struct
  *
  * This work item polls TSYNCTXCTL valid bit to determine when a Tx hardware
- * timestamp has been taken for the current skb. It is necesary, because the
+ * timestamp has been taken for the current skb. It is necessary, because the
  * descriptor's "done" bit does not correlate with the timestamp event.
  */
 static void ixgbe_ptp_tx_hwtstamp_work(struct work_struct *work)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 7f37fe7..09a291b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -141,7 +141,7 @@ void ixgbe_enable_sriov(struct ixgbe_adapter *adapter)
 		 * The 82599 supports up to 64 VFs per physical function
 		 * but this implementation limits allocation to 63 so that
 		 * basic networking resources are still available to the
-		 * physical function.  If the user requests greater thn
+		 * physical function.  If the user requests greater than
 		 * 63 VFs then it is an error - reset to default of zero.
 		 */
 		adapter->num_vfs = min_t(unsigned int, adapter->num_vfs, IXGBE_MAX_VFS_DRV_LIMIT);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index fc5ecee..8451f9a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1690,7 +1690,7 @@ enum {
 #define IXGBE_MACC_FS        0x00040000
 #define IXGBE_MAC_RX2TX_LPBK 0x00000002
 
-/* Veto Bit definiton */
+/* Veto Bit definition */
 #define IXGBE_MMNGC_MNG_VETO  0x00000001
 
 /* LINKS Bit Masks */
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index cdb53be..f510a58 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -65,7 +65,7 @@ static s32 ixgbevf_init_hw_vf(struct ixgbe_hw *hw)
  *  ixgbevf_reset_hw_vf - Performs hardware reset
  *  @hw: pointer to hardware structure
  *
- *  Resets the hardware by reseting the transmit and receive units, masks and
+ *  Resets the hardware by resetting the transmit and receive units, masks and
  *  clears all interrupts.
  **/
 static s32 ixgbevf_reset_hw_vf(struct ixgbe_hw *hw)
diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index fdf3e38..3e8b1bf 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -1423,7 +1423,7 @@ static void mvpp2_prs_mac_promisc_set(struct mvpp2 *priv, int port, bool add)
 {
 	struct mvpp2_prs_entry pe;
 
-	/* Promiscous mode - Accept unknown packets */
+	/* Promiscuous mode - Accept unknown packets */
 
 	if (priv->prs_shadow[MVPP2_PE_MAC_PROMISCUOUS].valid) {
 		/* Entry exist - update port only */
@@ -3402,7 +3402,7 @@ static void mvpp2_bm_bufs_free(struct mvpp2 *priv, struct mvpp2_bm_pool *bm_pool
 	for (i = 0; i < bm_pool->buf_num; i++) {
 		u32 vaddr;
 
-		/* Get buffer virtual adress (indirect access) */
+		/* Get buffer virtual address (indirect access) */
 		mvpp2_read(priv, MVPP2_BM_PHY_ALLOC_REG(bm_pool->id));
 		vaddr = mvpp2_read(priv, MVPP2_BM_VIRT_ALLOC_REG);
 		if (!vaddr)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
index 1409d0cd6..0b16db0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
@@ -175,7 +175,7 @@ enum mlx4_res_tracker_free_type {
 
 /*
  *Virtual HCR structures.
- * mlx4_vhcr is the sw representation, in machine endianess
+ * mlx4_vhcr is the sw representation, in machine endianness
  *
  * mlx4_vhcr_cmd is the formalized structure, the one that is passed
  * to FW to go through communication channel.
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index d97ca88..d43e259 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -3027,7 +3027,7 @@ int mlx4_WRITE_MTT_wrapper(struct mlx4_dev *dev, int slave,
 
 	/* Call the SW implementation of write_mtt:
 	 * - Prepare a dummy mtt struct
-	 * - Translate inbox contents to simple addresses in host endianess */
+	 * - Translate inbox contents to simple addresses in host endianness */
 	mtt.offset = 0;  /* TBD this is broken but I don't handle it since
 			    we don't really use it */
 	mtt.order = 0;
diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 6c72e74..81d0f1c 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -150,7 +150,7 @@ static void moxart_mac_setup_desc_ring(struct net_device *ndev)
 
 	priv->rx_head = 0;
 
-	/* reset the MAC controler TX/RX desciptor base address */
+	/* reset the MAC controller TX/RX desciptor base address */
 	writel(priv->tx_base, priv->base + REG_TXR_BASE_ADDRESS);
 	writel(priv->rx_base, priv->base + REG_RXR_BASE_ADDRESS);
 }
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index a4cdf2f..092dcae 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -1343,7 +1343,7 @@ static int init_nic(struct s2io_nic *nic)
 		TX_PA_CFG_IGNORE_L2_ERR;
 	writeq(val64, &bar0->tx_pa_cfg);
 
-	/* Rx DMA intialization. */
+	/* Rx DMA initialization. */
 	val64 = 0;
 	for (i = 0; i < config->rx_ring_num; i++) {
 		struct rx_ring_config *rx_cfg = &config->rx_cfg[i];
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
index 4fe8ea9..f6fcf74 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
@@ -394,7 +394,7 @@ static void pch_gbe_get_pauseparam(struct net_device *netdev,
 }
 
 /**
- * pch_gbe_set_pauseparam - Set pause paramters
+ * pch_gbe_set_pauseparam - Set pause parameters
  * @netdev:  Network interface device structure
  * @pause:   Pause parameters structure
  * Returns:
diff --git a/drivers/net/ethernet/packetengines/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
index 319d9d4..13d88a6 100644
--- a/drivers/net/ethernet/packetengines/hamachi.c
+++ b/drivers/net/ethernet/packetengines/hamachi.c
@@ -350,7 +350,7 @@ V.  Recent Changes
     incorrectly defined and corrected (as per Michel Mueller).
 
 02/23/1999 EPK Corrected the Tx full check to check that at least 4 slots
-    were available before reseting the tbusy and tx_full flags
+    were available before resetting the tbusy and tx_full flags
     (as per Michel Mueller).
 
 03/11/1999 EPK Added Pete Wyckoff's hardware checksumming support.
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index f3346a3..69f828e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -205,7 +205,7 @@ struct qlcnic_add_rings_mbx_out {
  * @phys_addr_{low|high}: DMA address of the transmit buffer
  * @cnsmr_index_{low|high}: host consumer index
  * @size: legth of transmit buffer ring
- * @intr_id: interrput id
+ * @intr_id: interrupt id
  * @src: src of interrupt
  */
 struct qlcnic_tx_mbx {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 2bb48d5..33669c2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -269,7 +269,7 @@ static int qlcnic_83xx_idc_clear_registers(struct qlcnic_adapter *adapter,
 	}
 
 	QLCWRX(adapter->ahw, QLC_83XX_IDC_DRV_ACK, 0);
-	/* Clear gracefull reset bit */
+	/* Clear graceful reset bit */
 	val = QLCRDX(adapter->ahw, QLC_83XX_IDC_CTRL);
 	val &= ~QLC_83XX_IDC_GRACEFULL_RESET;
 	QLCWRX(adapter->ahw, QLC_83XX_IDC_CTRL, val);
@@ -889,7 +889,7 @@ static int qlcnic_83xx_idc_ready_state(struct qlcnic_adapter *adapter)
  * @adapter: adapter structure
  *
  * Device will remain in this state until:
- *	Reset request ACK's are recieved from all the functions
+ *	Reset request ACK's are received from all the functions
  *	Wait time exceeds max time limit
  *
  * Returns: Error code or Success(0)
diff --git a/drivers/net/ethernet/qualcomm/qca_spi.c b/drivers/net/ethernet/qualcomm/qca_spi.c
index 2c811f6..4a42e96 100644
--- a/drivers/net/ethernet/qualcomm/qca_spi.c
+++ b/drivers/net/ethernet/qualcomm/qca_spi.c
@@ -571,7 +571,7 @@ qcaspi_spi_thread(void *data)
 			}
 
 			/* can only handle other interrupts
-			 * if sync has occured
+			 * if sync has occurred
 			 */
 			if (qca->sync == QCASPI_SYNC_READY) {
 				if (intr_cause & SPI_INT_PKT_AVLBL)
diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
index c8a01ee..413ea14a 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c
@@ -422,11 +422,11 @@ static int init_tx_ring(struct device *dev, u8 queue_no,
 	/* assign queue number */
 	tx_ring->queue_no = queue_no;
 
-	/* initalise counters */
+	/* initialise counters */
 	tx_ring->dirty_tx = 0;
 	tx_ring->cur_tx = 0;
 
-	/* initalise TX queue lock */
+	/* initialise TX queue lock */
 	spin_lock_init(&tx_ring->tx_lock);
 
 	return 0;
@@ -515,7 +515,7 @@ static int init_rx_ring(struct net_device *dev, u8 queue_no,
 			goto err_free_rx_buffers;
 	}
 
-	/* initalise counters */
+	/* initialise counters */
 	rx_ring->cur_rx = 0;
 	rx_ring->dirty_rx = (unsigned int)(desc_index - rx_rsize);
 	priv->dma_buf_sz = bfsize;
@@ -837,7 +837,7 @@ static void sxgbe_restart_tx_queue(struct sxgbe_priv_data *priv, int queue_num)
 	/* free the skbuffs of the ring */
 	tx_free_ring_skbufs(tx_ring);
 
-	/* initalise counters */
+	/* initialise counters */
 	tx_ring->cur_tx = 0;
 	tx_ring->dirty_tx = 0;
 
@@ -1176,7 +1176,7 @@ static int sxgbe_open(struct net_device *dev)
 	if (priv->phydev)
 		phy_start(priv->phydev);
 
-	/* initalise TX coalesce parameters */
+	/* initialise TX coalesce parameters */
 	sxgbe_tx_init_coalesce(priv);
 
 	if ((priv->use_riwt) && (priv->hw->dma->rx_watchdog)) {
@@ -1721,7 +1721,7 @@ static inline u64 sxgbe_get_stat64(void __iomem *ioaddr, int reg_lo, int reg_hi)
  *  Description:
  *  This function is a driver entry point whenever ifconfig command gets
  *  executed to see device statistics. Statistics are number of
- *  bytes sent or received, errors occured etc.
+ *  bytes sent or received, errors occurred etc.
  *  Return value:
  *  This function returns various statistical information of device.
  */
diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 2384824..33d2f9a 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -3215,7 +3215,7 @@ static pci_ers_result_t efx_io_error_detected(struct pci_dev *pdev,
 	return status;
 }
 
-/* Fake a successfull reset, which will be performed later in efx_io_resume. */
+/* Fake a successful reset, which will be performed later in efx_io_resume. */
 static pci_ers_result_t efx_io_slot_reset(struct pci_dev *pdev)
 {
 	struct efx_nic *efx = pci_get_drvdata(pdev);
diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index 7597532..bb89e96 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -645,7 +645,7 @@ static bool efx_check_tx_flush_complete(struct efx_nic *efx)
 }
 
 /* Flush all the transmit queues, and continue flushing receive queues until
- * they're all flushed. Wait for the DRAIN events to be recieved so that there
+ * they're all flushed. Wait for the DRAIN events to be received so that there
  * are no more RX and TX events left on any channel. */
 static int efx_farch_do_flush(struct efx_nic *efx)
 {
@@ -1108,7 +1108,7 @@ efx_farch_handle_tx_flush_done(struct efx_nic *efx, efx_qword_t *event)
 }
 
 /* If this flush done event corresponds to a &struct efx_rx_queue: If the flush
- * was succesful then send an %EFX_CHANNEL_MAGIC_RX_DRAIN, otherwise add
+ * was successful then send an %EFX_CHANNEL_MAGIC_RX_DRAIN, otherwise add
  * the RX queue back to the mask of RX queues in need of flushing.
  */
 static void
diff --git a/drivers/net/ethernet/sfc/mcdi_pcol.h b/drivers/net/ethernet/sfc/mcdi_pcol.h
index a707fb5..e028de1 100644
--- a/drivers/net/ethernet/sfc/mcdi_pcol.h
+++ b/drivers/net/ethernet/sfc/mcdi_pcol.h
@@ -6497,7 +6497,7 @@
 #define    MC_CMD_DUMP_BUFTBL_ENTRIES_OUT_LENMIN 12
 #define    MC_CMD_DUMP_BUFTBL_ENTRIES_OUT_LENMAX 252
 #define    MC_CMD_DUMP_BUFTBL_ENTRIES_OUT_LEN(num) (0+12*(num))
-/* Raw buffer table entries, layed out as BUFTBL_ENTRY. */
+/* Raw buffer table entries, laid out as BUFTBL_ENTRY. */
 #define       MC_CMD_DUMP_BUFTBL_ENTRIES_OUT_ENTRY_OFST 0
 #define       MC_CMD_DUMP_BUFTBL_ENTRIES_OUT_ENTRY_LEN 12
 #define       MC_CMD_DUMP_BUFTBL_ENTRIES_OUT_ENTRY_MINNUM 1
diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index a8bbbad..fe83430 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -1067,7 +1067,7 @@ void efx_siena_sriov_probe(struct efx_nic *efx)
 }
 
 /* Copy the list of individual addresses into the vfdi_status.peers
- * array and auxillary pages, protected by %local_lock. Drop that lock
+ * array and auxiliary pages, protected by %local_lock. Drop that lock
  * and then broadcast the address list to every VF.
  */
 static void efx_siena_sriov_peer_work(struct work_struct *data)
diff --git a/drivers/net/ethernet/sfc/vfdi.h b/drivers/net/ethernet/sfc/vfdi.h
index ae044f4..f62901d 100644
--- a/drivers/net/ethernet/sfc/vfdi.h
+++ b/drivers/net/ethernet/sfc/vfdi.h
@@ -98,7 +98,7 @@ struct vfdi_endpoint {
  * @VFDI_OP_INIT_TXQ: Initialize SRAM entries and initialize a TXQ.
  * @VFDI_OP_FINI_ALL_QUEUES: Flush all queues, finalize all queues, then
  *	finalize the SRAM entries.
- * @VFDI_OP_INSERT_FILTER: Insert a MAC filter targetting the given RXQ.
+ * @VFDI_OP_INSERT_FILTER: Insert a MAC filter targeting the given RXQ.
  * @VFDI_OP_REMOVE_ALL_FILTERS: Remove all filters.
  * @VFDI_OP_SET_STATUS_PAGE: Set the DMA page(s) used for status updates
  *	from PF and write the initial status.
@@ -148,7 +148,7 @@ enum vfdi_op {
  * @u.init_txq.flags: Checksum offload flags.
  * @u.init_txq.addr: Array of length %u.init_txq.buf_count containing DMA
  *	address of each page backing the transmit queue.
- * @u.mac_filter.rxq: Insert MAC filter at VF local address/VLAN targetting
+ * @u.mac_filter.rxq: Insert MAC filter at VF local address/VLAN targeting
  *	all traffic at this receive queue.
  * @u.mac_filter.flags: MAC filter flags.
  * @u.set_status_page.dma_addr: Base address for the &struct vfdi_status.
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a0ea84f..5336594 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -609,7 +609,7 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 		 * where, freq_div_ratio = clk_ptp_ref_i/50MHz
 		 * hence, addend = ((2^32) * 50MHz)/clk_ptp_ref_i;
 		 * NOTE: clk_ptp_ref_i should be >= 50MHz to
-		 *       achive 20ns accuracy.
+		 *       achieve 20ns accuracy.
 		 *
 		 * 2^x * y == (y << x), hence
 		 * 2^32 * 50000000 ==> (50000000 << 32)
diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index fef5dec..74e9b14 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -2175,7 +2175,7 @@ static int gem_do_start(struct net_device *dev)
 	}
 
 	/* Mark us as attached again if we come from resume(), this has
-	 * no effect if we weren't detatched and needs to be done now.
+	 * no effect if we weren't detached and needs to be done now.
 	 */
 	netif_device_attach(dev);
 
@@ -2794,7 +2794,7 @@ static void gem_remove_one(struct pci_dev *pdev)
 
 		unregister_netdev(dev);
 
-		/* Ensure reset task is truely gone */
+		/* Ensure reset task is truly gone */
 		cancel_work_sync(&gp->reset_task);
 
 		/* Free resources */
diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index a1bbaf6..b536b4c 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -726,7 +726,7 @@ static void cpsw_rx_handler(void *token, int len, int status)
 		if (ndev_status && (status >= 0)) {
 			/* The packet received is for the interface which
 			 * is already down and the other interface is up
-			 * and running, intead of freeing which results
+			 * and running, instead of freeing which results
 			 * in reducing of the number of rx descriptor in
 			 * DMA engine, requeue skb back to cpdma.
 			 */
diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index bb79928..ac62a5e 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -1065,7 +1065,7 @@ refill:
 
 	/*
 	 * this call can fail, but for now, just leave this
-	 * decriptor without skb
+	 * descriptor without skb
 	 */
 	gelic_descr_prepare_rx(card, descr);
 
diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index a495931..f5498c2 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -56,7 +56,7 @@ MODULE_LICENSE("GPL");
 
 #define W5100_S0_REGS		0x0400
 #define W5100_S0_MR		0x0400 /* S0 Mode Register */
-#define   S0_MR_MACRAW		  0x04 /* MAC RAW mode (promiscous) */
+#define   S0_MR_MACRAW		  0x04 /* MAC RAW mode (promiscuous) */
 #define   S0_MR_MACRAW_MF	  0x44 /* MAC RAW mode (filtered) */
 #define W5100_S0_CR		0x0401 /* S0 Command Register */
 #define   S0_CR_OPEN		  0x01 /* OPEN command */
diff --git a/drivers/net/ethernet/wiznet/w5300.c b/drivers/net/ethernet/wiznet/w5300.c
index 09322d9..ca0c631 100644
--- a/drivers/net/ethernet/wiznet/w5300.c
+++ b/drivers/net/ethernet/wiznet/w5300.c
@@ -63,7 +63,7 @@ MODULE_LICENSE("GPL");
 #define   IDR_W5300		  0x5300  /* =0x5300 for WIZnet W5300 */
 #define W5300_S0_MR		0x0200	/* S0 Mode Register */
 #define   S0_MR_CLOSED		  0x0000  /* Close mode */
-#define   S0_MR_MACRAW		  0x0004  /* MAC RAW mode (promiscous) */
+#define   S0_MR_MACRAW		  0x0004  /* MAC RAW mode (promiscuous) */
 #define   S0_MR_MACRAW_MF	  0x0044  /* MAC RAW mode (filtered) */
 #define W5300_S0_CR		0x0202	/* S0 Command Register */
 #define   S0_CR_OPEN		  0x0001  /* OPEN command */
