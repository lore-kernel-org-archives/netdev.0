From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
Subject: [PATCH 1/7] e1000e: cleanup: fix spacing issues
Date: Thu,  9 Dec 2010 02:40:51 +0000
Message-ID: <1291862457-16671-2-git-send-email-asbjorn@asbjorn.biz>
References: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
In-Reply-To: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes trivial spacing issues in e1000e.

Fixes 187 errors and 59 warnings reported by checkpatch.

Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
---
 drivers/net/e1000e/82571.c   |   18 +++---
 drivers/net/e1000e/defines.h |   32 ++++++------
 drivers/net/e1000e/e1000.h   |   14 +++---
 drivers/net/e1000e/es2lan.c  |   72 ++++++++++++------------
 drivers/net/e1000e/ethtool.c |   16 +++---
 drivers/net/e1000e/hw.h      |    2 +-
 drivers/net/e1000e/ich8lan.c |   92 ++++++++++++++++----------------
 drivers/net/e1000e/lib.c     |    8 ++--
 drivers/net/e1000e/netdev.c  |   74 +++++++++++++-------------
 drivers/net/e1000e/param.c   |    2 +-
 drivers/net/e1000e/phy.c     |  124 +++++++++++++++++++++---------------------
 11 files changed, 227 insertions(+), 227 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 9333921..bbc73ce 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1225,12 +1225,12 @@ static void e1000_initialize_hw_bits_82571(struct e1000_hw *hw)
 	 * Ensure that DMA Dynamic Clock gating is disabled on 82571 and 82572
 	 */
 
-        if ((hw->mac.type == e1000_82571) ||
-           (hw->mac.type == e1000_82572)) {
-                reg = er32(CTRL_EXT);
-                reg &= ~E1000_CTRL_EXT_DMA_DYN_CLK_EN;
-                ew32(CTRL_EXT, reg);
-        }
+	if ((hw->mac.type == e1000_82571) ||
+	    (hw->mac.type == e1000_82572)) {
+		reg = er32(CTRL_EXT);
+		reg &= ~E1000_CTRL_EXT_DMA_DYN_CLK_EN;
+		ew32(CTRL_EXT, reg);
+	}
 
 
 	/* PCI-Ex Control Registers */
@@ -1880,7 +1880,7 @@ static struct e1000_phy_operations e82_phy_ops_igp = {
 	.set_d0_lplu_state	= e1000_set_d0_lplu_state_82571,
 	.set_d3_lplu_state	= e1000e_set_d3_lplu_state,
 	.write_reg		= e1000e_write_phy_reg_igp,
-	.cfg_on_link_up      	= NULL,
+	.cfg_on_link_up		= NULL,
 };
 
 static struct e1000_phy_operations e82_phy_ops_m88 = {
@@ -1898,7 +1898,7 @@ static struct e1000_phy_operations e82_phy_ops_m88 = {
 	.set_d0_lplu_state	= e1000_set_d0_lplu_state_82571,
 	.set_d3_lplu_state	= e1000e_set_d3_lplu_state,
 	.write_reg		= e1000e_write_phy_reg_m88,
-	.cfg_on_link_up      	= NULL,
+	.cfg_on_link_up		= NULL,
 };
 
 static struct e1000_phy_operations e82_phy_ops_bm = {
@@ -1916,7 +1916,7 @@ static struct e1000_phy_operations e82_phy_ops_bm = {
 	.set_d0_lplu_state	= e1000_set_d0_lplu_state_82571,
 	.set_d3_lplu_state	= e1000e_set_d3_lplu_state,
 	.write_reg		= e1000e_write_phy_reg_bm2,
-	.cfg_on_link_up      	= NULL,
+	.cfg_on_link_up		= NULL,
 };
 
 static struct e1000_nvm_operations e82571_nvm_ops = {
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 016ea38..2b969c8 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -111,19 +111,19 @@
 
 /* mask to determine if packets should be dropped due to frame errors */
 #define E1000_RXD_ERR_FRAME_ERR_MASK ( \
-    E1000_RXD_ERR_CE  |                \
-    E1000_RXD_ERR_SE  |                \
-    E1000_RXD_ERR_SEQ |                \
-    E1000_RXD_ERR_CXE |                \
-    E1000_RXD_ERR_RXE)
+	E1000_RXD_ERR_CE  |                \
+	E1000_RXD_ERR_SE  |                \
+	E1000_RXD_ERR_SEQ |                \
+	E1000_RXD_ERR_CXE |                \
+	E1000_RXD_ERR_RXE)
 
 /* Same mask, but for extended and packet split descriptors */
 #define E1000_RXDEXT_ERR_FRAME_ERR_MASK ( \
-    E1000_RXDEXT_STATERR_CE  |            \
-    E1000_RXDEXT_STATERR_SE  |            \
-    E1000_RXDEXT_STATERR_SEQ |            \
-    E1000_RXDEXT_STATERR_CXE |            \
-    E1000_RXDEXT_STATERR_RXE)
+	E1000_RXDEXT_STATERR_CE  |            \
+	E1000_RXDEXT_STATERR_SE  |            \
+	E1000_RXDEXT_STATERR_SEQ |            \
+	E1000_RXDEXT_STATERR_CXE |            \
+	E1000_RXDEXT_STATERR_RXE)
 
 #define E1000_RXDPS_HDRSTAT_HDRSP              0x00008000
 
@@ -421,11 +421,11 @@
  *   o LSC    = Link Status Change
  */
 #define IMS_ENABLE_MASK ( \
-    E1000_IMS_RXT0   |    \
-    E1000_IMS_TXDW   |    \
-    E1000_IMS_RXDMT0 |    \
-    E1000_IMS_RXSEQ  |    \
-    E1000_IMS_LSC)
+	E1000_IMS_RXT0   |    \
+	E1000_IMS_TXDW   |    \
+	E1000_IMS_RXDMT0 |    \
+	E1000_IMS_RXSEQ  |    \
+	E1000_IMS_LSC)
 
 /* Interrupt Mask Set */
 #define E1000_IMS_TXDW      E1000_ICR_TXDW      /* Transmit desc written back */
@@ -785,7 +785,7 @@
 
 #define PHY_PAGE_SHIFT 5
 #define PHY_REG(page, reg) (((page) << PHY_PAGE_SHIFT) | \
-                           ((reg) & MAX_PHY_REG_ADDRESS))
+			    ((reg) & MAX_PHY_REG_ADDRESS))
 
 /*
  * Bits...
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index fdc67fe..47eb0ba 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -580,12 +580,12 @@ extern s32 e1000e_get_cable_length_igp_2(struct e1000_hw *hw);
 extern s32 e1000e_get_phy_info_igp(struct e1000_hw *hw);
 extern s32 e1000e_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data);
 extern s32 e1000e_read_phy_reg_igp_locked(struct e1000_hw *hw, u32 offset,
-                                          u16 *data);
+					  u16 *data);
 extern s32 e1000e_phy_hw_reset_generic(struct e1000_hw *hw);
 extern s32 e1000e_set_d3_lplu_state(struct e1000_hw *hw, bool active);
 extern s32 e1000e_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data);
 extern s32 e1000e_write_phy_reg_igp_locked(struct e1000_hw *hw, u32 offset,
-                                           u16 data);
+					   u16 data);
 extern s32 e1000e_phy_sw_reset(struct e1000_hw *hw);
 extern s32 e1000e_phy_force_speed_duplex_m88(struct e1000_hw *hw);
 extern s32 e1000e_get_cfg_done(struct e1000_hw *hw);
@@ -603,12 +603,12 @@ extern s32 e1000e_write_phy_reg_bm2(struct e1000_hw *hw, u32 offset, u16 data);
 extern void e1000e_phy_force_speed_duplex_setup(struct e1000_hw *hw, u16 *phy_ctrl);
 extern s32 e1000e_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data);
 extern s32 e1000e_write_kmrn_reg_locked(struct e1000_hw *hw, u32 offset,
-                                        u16 data);
+					u16 data);
 extern s32 e1000e_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data);
 extern s32 e1000e_read_kmrn_reg_locked(struct e1000_hw *hw, u32 offset,
-                                       u16 *data);
+				       u16 *data);
 extern s32 e1000e_phy_has_link_generic(struct e1000_hw *hw, u32 iterations,
-			       u32 usec_interval, bool *success);
+				       u32 usec_interval, bool *success);
 extern s32 e1000e_phy_reset_dsp(struct e1000_hw *hw);
 extern void e1000_power_up_phy_copper(struct e1000_hw *hw);
 extern void e1000_power_down_phy_copper(struct e1000_hw *hw);
@@ -617,10 +617,10 @@ extern s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data);
 extern s32 e1000e_check_downshift(struct e1000_hw *hw);
 extern s32 e1000_read_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 *data);
 extern s32 e1000_read_phy_reg_hv_locked(struct e1000_hw *hw, u32 offset,
-                                        u16 *data);
+					u16 *data);
 extern s32 e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data);
 extern s32 e1000_write_phy_reg_hv_locked(struct e1000_hw *hw, u32 offset,
-                                         u16 data);
+					 u16 data);
 extern s32 e1000_link_stall_workaround_hv(struct e1000_hw *hw);
 extern s32 e1000_copper_link_setup_82577(struct e1000_hw *hw);
 extern s32 e1000_check_polarity_82577(struct e1000_hw *hw);
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 24f8ac9..afed60f 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -114,9 +114,9 @@ static s32 e1000_cfg_kmrn_1000_80003es2lan(struct e1000_hw *hw);
 static s32 e1000_cfg_kmrn_10_100_80003es2lan(struct e1000_hw *hw, u16 duplex);
 static s32 e1000_cfg_on_link_up_80003es2lan(struct e1000_hw *hw);
 static s32  e1000_read_kmrn_reg_80003es2lan(struct e1000_hw *hw, u32 offset,
-                                            u16 *data);
+					    u16 *data);
 static s32  e1000_write_kmrn_reg_80003es2lan(struct e1000_hw *hw, u32 offset,
-                                             u16 data);
+					     u16 data);
 static void e1000_power_down_phy_copper_80003es2lan(struct e1000_hw *hw);
 
 /**
@@ -225,8 +225,8 @@ static s32 e1000_init_mac_params_80003es2lan(struct e1000_adapter *adapter)
 	mac->has_fwsm = true;
 	/* ARC supported; valid only if manageability features are enabled. */
 	mac->arc_subsystem_valid =
-	        (er32(FWSM) & E1000_FWSM_MODE_MASK)
-	                ? true : false;
+		(er32(FWSM) & E1000_FWSM_MODE_MASK)
+			? true : false;
 	/* Adaptive IFS not supported */
 	mac->adaptive_ifs = false;
 
@@ -493,14 +493,14 @@ static s32 e1000_read_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 		udelay(200);
 
 		ret_val = e1000e_read_phy_reg_mdic(hw,
-		                                  MAX_PHY_REG_ADDRESS & offset,
-		                                  data);
+						  MAX_PHY_REG_ADDRESS & offset,
+						  data);
 
 		udelay(200);
 	} else {
 		ret_val = e1000e_read_phy_reg_mdic(hw,
-		                                  MAX_PHY_REG_ADDRESS & offset,
-		                                  data);
+						  MAX_PHY_REG_ADDRESS & offset,
+						  data);
 	}
 
 	e1000_release_phy_80003es2lan(hw);
@@ -564,14 +564,14 @@ static s32 e1000_write_phy_reg_gg82563_80003es2lan(struct e1000_hw *hw,
 		udelay(200);
 
 		ret_val = e1000e_write_phy_reg_mdic(hw,
-		                                  MAX_PHY_REG_ADDRESS & offset,
-		                                  data);
+						  MAX_PHY_REG_ADDRESS & offset,
+						  data);
 
 		udelay(200);
 	} else {
 		ret_val = e1000e_write_phy_reg_mdic(hw,
-		                                  MAX_PHY_REG_ADDRESS & offset,
-		                                  data);
+						  MAX_PHY_REG_ADDRESS & offset,
+						  data);
 	}
 
 	e1000_release_phy_80003es2lan(hw);
@@ -898,9 +898,9 @@ static s32 e1000_init_hw_80003es2lan(struct e1000_hw *hw)
 	hw->dev_spec.e80003es2lan.mdic_wa_enable = true;
 
 	ret_val = e1000_read_kmrn_reg_80003es2lan(hw,
-	                              E1000_KMRNCTRLSTA_OFFSET >>
-	                              E1000_KMRNCTRLSTA_OFFSET_SHIFT,
-	                              &i);
+				      E1000_KMRNCTRLSTA_OFFSET >>
+				      E1000_KMRNCTRLSTA_OFFSET_SHIFT,
+				      &i);
 	if (!ret_val) {
 		if ((i & E1000_KMRNCTRLSTA_OPMODE_MASK) ==
 		     E1000_KMRNCTRLSTA_OPMODE_INBAND_MDIO)
@@ -1127,16 +1127,16 @@ static s32 e1000_setup_copper_link_80003es2lan(struct e1000_hw *hw)
 	 * polling the phy; this fixes erroneous timeouts at 10Mbps.
 	 */
 	ret_val = e1000_write_kmrn_reg_80003es2lan(hw, GG82563_REG(0x34, 4),
-	                                           0xFFFF);
+						   0xFFFF);
 	if (ret_val)
 		return ret_val;
 	ret_val = e1000_read_kmrn_reg_80003es2lan(hw, GG82563_REG(0x34, 9),
-	                                          &reg_data);
+						  &reg_data);
 	if (ret_val)
 		return ret_val;
 	reg_data |= 0x3F;
 	ret_val = e1000_write_kmrn_reg_80003es2lan(hw, GG82563_REG(0x34, 9),
-	                                           reg_data);
+						   reg_data);
 	if (ret_val)
 		return ret_val;
 	ret_val = e1000_read_kmrn_reg_80003es2lan(hw,
@@ -1176,7 +1176,7 @@ static s32 e1000_cfg_on_link_up_80003es2lan(struct e1000_hw *hw)
 
 	if (hw->phy.media_type == e1000_media_type_copper) {
 		ret_val = e1000e_get_speed_and_duplex_copper(hw, &speed,
-		                                             &duplex);
+							     &duplex);
 		if (ret_val)
 			return ret_val;
 
@@ -1206,8 +1206,8 @@ static s32 e1000_cfg_kmrn_10_100_80003es2lan(struct e1000_hw *hw, u16 duplex)
 
 	reg_data = E1000_KMRNCTRLSTA_HD_CTRL_10_100_DEFAULT;
 	ret_val = e1000_write_kmrn_reg_80003es2lan(hw,
-	                               E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
-	                               reg_data);
+				       E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
+				       reg_data);
 	if (ret_val)
 		return ret_val;
 
@@ -1254,8 +1254,8 @@ static s32 e1000_cfg_kmrn_1000_80003es2lan(struct e1000_hw *hw)
 
 	reg_data = E1000_KMRNCTRLSTA_HD_CTRL_1000_DEFAULT;
 	ret_val = e1000_write_kmrn_reg_80003es2lan(hw,
-	                               E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
-	                               reg_data);
+				       E1000_KMRNCTRLSTA_OFFSET_HD_CTRL,
+				       reg_data);
 	if (ret_val)
 		return ret_val;
 
@@ -1303,7 +1303,7 @@ static s32 e1000_read_kmrn_reg_80003es2lan(struct e1000_hw *hw, u32 offset,
 		return ret_val;
 
 	kmrnctrlsta = ((offset << E1000_KMRNCTRLSTA_OFFSET_SHIFT) &
-	               E1000_KMRNCTRLSTA_OFFSET) | E1000_KMRNCTRLSTA_REN;
+		       E1000_KMRNCTRLSTA_OFFSET) | E1000_KMRNCTRLSTA_REN;
 	ew32(KMRNCTRLSTA, kmrnctrlsta);
 
 	udelay(2);
@@ -1337,7 +1337,7 @@ static s32 e1000_write_kmrn_reg_80003es2lan(struct e1000_hw *hw, u32 offset,
 		return ret_val;
 
 	kmrnctrlsta = ((offset << E1000_KMRNCTRLSTA_OFFSET_SHIFT) &
-	               E1000_KMRNCTRLSTA_OFFSET) | data;
+		       E1000_KMRNCTRLSTA_OFFSET) | data;
 	ew32(KMRNCTRLSTA, kmrnctrlsta);
 
 	udelay(2);
@@ -1457,18 +1457,18 @@ static struct e1000_phy_operations es2_phy_ops = {
 	.acquire		= e1000_acquire_phy_80003es2lan,
 	.check_polarity		= e1000_check_polarity_m88,
 	.check_reset_block	= e1000e_check_reset_block_generic,
-	.commit		 	= e1000e_phy_sw_reset,
-	.force_speed_duplex 	= e1000_phy_force_speed_duplex_80003es2lan,
-	.get_cfg_done       	= e1000_get_cfg_done_80003es2lan,
-	.get_cable_length   	= e1000_get_cable_length_80003es2lan,
-	.get_info       	= e1000e_get_phy_info_m88,
-	.read_reg       	= e1000_read_phy_reg_gg82563_80003es2lan,
+	.commit			= e1000e_phy_sw_reset,
+	.force_speed_duplex	= e1000_phy_force_speed_duplex_80003es2lan,
+	.get_cfg_done		= e1000_get_cfg_done_80003es2lan,
+	.get_cable_length	= e1000_get_cable_length_80003es2lan,
+	.get_info		= e1000e_get_phy_info_m88,
+	.read_reg		= e1000_read_phy_reg_gg82563_80003es2lan,
 	.release		= e1000_release_phy_80003es2lan,
-	.reset		  	= e1000e_phy_hw_reset_generic,
-	.set_d0_lplu_state  	= NULL,
-	.set_d3_lplu_state  	= e1000e_set_d3_lplu_state,
-	.write_reg      	= e1000_write_phy_reg_gg82563_80003es2lan,
-	.cfg_on_link_up      	= e1000_cfg_on_link_up_80003es2lan,
+	.reset			= e1000e_phy_hw_reset_generic,
+	.set_d0_lplu_state	= NULL,
+	.set_d3_lplu_state	= e1000e_set_d3_lplu_state,
+	.write_reg		= e1000_write_phy_reg_gg82563_80003es2lan,
+	.cfg_on_link_up		= e1000_cfg_on_link_up_80003es2lan,
 };
 
 static struct e1000_nvm_operations es2_nvm_ops = {
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 8984d16..8acfbca 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -47,7 +47,7 @@ struct e1000_stats {
 
 #define E1000_STAT(m)		E1000_STATS, \
 				sizeof(((struct e1000_adapter *)0)->m), \
-		      		offsetof(struct e1000_adapter, m)
+				offsetof(struct e1000_adapter, m)
 #define E1000_NETDEV_STAT(m)	NETDEV_STATS, \
 				sizeof(((struct net_device *)0)->m), \
 				offsetof(struct net_device, m)
@@ -187,7 +187,7 @@ static int e1000_get_settings(struct net_device *netdev,
 	if ((hw->phy.media_type == e1000_media_type_copper) &&
 	    netif_carrier_ok(netdev))
 		ecmd->eth_tp_mdix = hw->phy.is_mdix ? ETH_TP_MDI_X :
-		                                      ETH_TP_MDI;
+						      ETH_TP_MDI;
 	else
 		ecmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
 
@@ -830,7 +830,7 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	case e1000_80003es2lan:
 		toggle = 0x7FFFF3FF;
 		break;
-        default:
+	default:
 		toggle = 0x7FFFF033;
 		break;
 	}
@@ -890,7 +890,7 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	}
 	for (i = 0; i < mac->rar_entry_count; i++)
 		REG_PATTERN_TEST_ARRAY(E1000_RA, ((i << 1) + 1),
-		                       mask, 0xFFFFFFFF);
+				       mask, 0xFFFFFFFF);
 
 	for (i = 0; i < mac->mta_reg_count; i++)
 		REG_PATTERN_TEST_ARRAY(E1000_MTA, i, 0xFFFFFFFF, 0xFFFFFFFF);
@@ -1796,8 +1796,8 @@ static void e1000_get_wol(struct net_device *netdev,
 		return;
 
 	wol->supported = WAKE_UCAST | WAKE_MCAST |
-	                 WAKE_BCAST | WAKE_MAGIC |
-	                 WAKE_PHY | WAKE_ARP;
+			 WAKE_BCAST | WAKE_MAGIC |
+			 WAKE_PHY | WAKE_ARP;
 
 	/* apply any specific unsupported masks here */
 	if (adapter->flags & FLAG_NO_WAKE_UCAST) {
@@ -1830,7 +1830,7 @@ static int e1000_set_wol(struct net_device *netdev,
 	if (!(adapter->flags & FLAG_HAS_WOL) ||
 	    !device_can_wakeup(&adapter->pdev->dev) ||
 	    (wol->wolopts & ~(WAKE_UCAST | WAKE_MCAST | WAKE_BCAST |
-	                      WAKE_MAGIC | WAKE_PHY | WAKE_ARP)))
+			      WAKE_MAGIC | WAKE_PHY | WAKE_ARP)))
 		return -EOPNOTSUPP;
 
 	/* these settings will always override what we currently have */
@@ -1863,7 +1863,7 @@ static int e1000_set_wol(struct net_device *netdev,
 static void e1000e_led_blink_task(struct work_struct *work)
 {
 	struct e1000_adapter *adapter = container_of(work,
-	                                struct e1000_adapter, led_blink_task);
+					struct e1000_adapter, led_blink_task);
 
 	if (test_and_change_bit(E1000_LED_ON, &adapter->led_status))
 		adapter->hw.mac.ops.led_off(&adapter->hw);
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index ba302a5..0a319e1 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -37,7 +37,7 @@ struct e1000_adapter;
 #include "defines.h"
 
 #define er32(reg)	__er32(hw, E1000_##reg)
-#define ew32(reg,val)	__ew32(hw, E1000_##reg, (val))
+#define ew32(reg, val)	__ew32(hw, E1000_##reg, (val))
 #define e1e_flush()	er32(STATUS)
 
 #define E1000_WRITE_REG_ARRAY(a, reg, offset, value) \
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index e3374d9..53edfd4 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -267,8 +267,8 @@ static inline void __ew32flash(struct e1000_hw *hw, unsigned long reg, u32 val)
 
 #define er16flash(reg)		__er16flash(hw, (reg))
 #define er32flash(reg)		__er32flash(hw, (reg))
-#define ew16flash(reg,val)	__ew16flash(hw, (reg), (val))
-#define ew32flash(reg,val)	__ew32flash(hw, (reg), (val))
+#define ew16flash(reg, val)	__ew16flash(hw, (reg), (val))
+#define ew32flash(reg, val)	__ew32flash(hw, (reg), (val))
 
 /**
  *  e1000_init_phy_params_pchlan - Initialize PHY function pointers
@@ -1098,46 +1098,46 @@ static s32 e1000_k1_gig_workaround_hv(struct e1000_hw *hw, bool link)
 	if (link) {
 		if (hw->phy.type == e1000_phy_82578) {
 			ret_val = hw->phy.ops.read_reg_locked(hw, BM_CS_STATUS,
-			                                          &status_reg);
+								  &status_reg);
 			if (ret_val)
 				goto release;
 
 			status_reg &= BM_CS_STATUS_LINK_UP |
-			              BM_CS_STATUS_RESOLVED |
-			              BM_CS_STATUS_SPEED_MASK;
+				      BM_CS_STATUS_RESOLVED |
+				      BM_CS_STATUS_SPEED_MASK;
 
 			if (status_reg == (BM_CS_STATUS_LINK_UP |
-			                   BM_CS_STATUS_RESOLVED |
-			                   BM_CS_STATUS_SPEED_1000))
+					   BM_CS_STATUS_RESOLVED |
+					   BM_CS_STATUS_SPEED_1000))
 				k1_enable = false;
 		}
 
 		if (hw->phy.type == e1000_phy_82577) {
 			ret_val = hw->phy.ops.read_reg_locked(hw, HV_M_STATUS,
-			                                          &status_reg);
+								  &status_reg);
 			if (ret_val)
 				goto release;
 
 			status_reg &= HV_M_STATUS_LINK_UP |
-			              HV_M_STATUS_AUTONEG_COMPLETE |
-			              HV_M_STATUS_SPEED_MASK;
+				      HV_M_STATUS_AUTONEG_COMPLETE |
+				      HV_M_STATUS_SPEED_MASK;
 
 			if (status_reg == (HV_M_STATUS_LINK_UP |
-			                   HV_M_STATUS_AUTONEG_COMPLETE |
-			                   HV_M_STATUS_SPEED_1000))
+					   HV_M_STATUS_AUTONEG_COMPLETE |
+					   HV_M_STATUS_SPEED_1000))
 				k1_enable = false;
 		}
 
 		/* Link stall fix for link up */
 		ret_val = hw->phy.ops.write_reg_locked(hw, PHY_REG(770, 19),
-		                                           0x0100);
+							   0x0100);
 		if (ret_val)
 			goto release;
 
 	} else {
 		/* Link stall fix for link down */
 		ret_val = hw->phy.ops.write_reg_locked(hw, PHY_REG(770, 19),
-		                                           0x4100);
+							   0x4100);
 		if (ret_val)
 			goto release;
 	}
@@ -1169,8 +1169,8 @@ s32 e1000_configure_k1_ich8lan(struct e1000_hw *hw, bool k1_enable)
 	u16 kmrn_reg = 0;
 
 	ret_val = e1000e_read_kmrn_reg_locked(hw,
-	                                     E1000_KMRNCTRLSTA_K1_CONFIG,
-	                                     &kmrn_reg);
+					     E1000_KMRNCTRLSTA_K1_CONFIG,
+					     &kmrn_reg);
 	if (ret_val)
 		goto out;
 
@@ -1180,8 +1180,8 @@ s32 e1000_configure_k1_ich8lan(struct e1000_hw *hw, bool k1_enable)
 		kmrn_reg &= ~E1000_KMRNCTRLSTA_K1_ENABLE;
 
 	ret_val = e1000e_write_kmrn_reg_locked(hw,
-	                                      E1000_KMRNCTRLSTA_K1_CONFIG,
-	                                      kmrn_reg);
+					      E1000_KMRNCTRLSTA_K1_CONFIG,
+					      kmrn_reg);
 	if (ret_val)
 		goto out;
 
@@ -1356,13 +1356,13 @@ static s32 e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 	ret_val = hw->phy.ops.read_reg_locked(hw,
-	                                      PHY_REG(BM_PORT_CTRL_PAGE, 17),
-	                                      &phy_data);
+					      PHY_REG(BM_PORT_CTRL_PAGE, 17),
+					      &phy_data);
 	if (ret_val)
 		goto release;
 	ret_val = hw->phy.ops.write_reg_locked(hw,
-	                                       PHY_REG(BM_PORT_CTRL_PAGE, 17),
-	                                       phy_data & 0x00FF);
+					       PHY_REG(BM_PORT_CTRL_PAGE, 17),
+					       phy_data & 0x00FF);
 release:
 	hw->phy.ops.release(hw);
 out:
@@ -2015,7 +2015,7 @@ static s32 e1000_valid_nvm_bank_detect_ich8lan(struct e1000_hw *hw, u32 *bank)
 
 		/* Check bank 0 */
 		ret_val = e1000_read_flash_byte_ich8lan(hw, act_offset,
-		                                        &sig_byte);
+							&sig_byte);
 		if (ret_val)
 			return ret_val;
 		if ((sig_byte & E1000_ICH_NVM_VALID_SIG_MASK) ==
@@ -2026,8 +2026,8 @@ static s32 e1000_valid_nvm_bank_detect_ich8lan(struct e1000_hw *hw, u32 *bank)
 
 		/* Check bank 1 */
 		ret_val = e1000_read_flash_byte_ich8lan(hw, act_offset +
-		                                        bank1_offset,
-		                                        &sig_byte);
+							bank1_offset,
+							&sig_byte);
 		if (ret_val)
 			return ret_val;
 		if ((sig_byte & E1000_ICH_NVM_VALID_SIG_MASK) ==
@@ -2428,8 +2428,8 @@ static s32 e1000_update_nvm_checksum_ich8lan(struct e1000_hw *hw)
 			data = dev_spec->shadow_ram[i].value;
 		} else {
 			ret_val = e1000_read_flash_word_ich8lan(hw, i +
-			                                        old_bank_offset,
-			                                        &data);
+								old_bank_offset,
+								&data);
 			if (ret_val)
 				break;
 		}
@@ -2640,7 +2640,7 @@ static s32 e1000_write_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 
 		hsflctl.regval = er16flash(ICH_FLASH_HSFCTL);
 		/* 0b/1b corresponds to 1 or 2 byte size, respectively. */
-		hsflctl.hsf_ctrl.fldbcount = size -1;
+		hsflctl.hsf_ctrl.fldbcount = size - 1;
 		hsflctl.hsf_ctrl.flcycle = ICH_CYCLE_WRITE;
 		ew16flash(ICH_FLASH_HSFCTL, hsflctl.regval);
 
@@ -3272,8 +3272,8 @@ static s32 e1000_setup_link_ich8lan(struct e1000_hw *hw)
 		ew32(FCRTV_PCH, hw->fc.refresh_time);
 
 		ret_val = hw->phy.ops.write_reg(hw,
-		                             PHY_REG(BM_PORT_CTRL_PAGE, 27),
-		                             hw->fc.pause_time);
+					     PHY_REG(BM_PORT_CTRL_PAGE, 27),
+					     hw->fc.pause_time);
 		if (ret_val)
 			return ret_val;
 	}
@@ -3309,12 +3309,12 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 	ret_val = e1000e_read_kmrn_reg(hw, E1000_KMRNCTRLSTA_INBAND_PARAM,
-	                               &reg_data);
+				       &reg_data);
 	if (ret_val)
 		return ret_val;
 	reg_data |= 0x3F;
 	ret_val = e1000e_write_kmrn_reg(hw, E1000_KMRNCTRLSTA_INBAND_PARAM,
-	                                reg_data);
+					reg_data);
 	if (ret_val)
 		return ret_val;
 
@@ -3338,7 +3338,7 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
 		break;
 	case e1000_phy_ife:
 		ret_val = hw->phy.ops.read_reg(hw, IFE_PHY_MDIX_CONTROL,
-		                               &reg_data);
+					       &reg_data);
 		if (ret_val)
 			return ret_val;
 
@@ -3357,7 +3357,7 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
 			break;
 		}
 		ret_val = hw->phy.ops.write_reg(hw, IFE_PHY_MDIX_CONTROL,
-		                                reg_data);
+						reg_data);
 		if (ret_val)
 			return ret_val;
 		break;
@@ -3857,21 +3857,21 @@ static void e1000_clear_hw_cntrs_ich8lan(struct e1000_hw *hw)
 }
 
 static struct e1000_mac_operations ich8_mac_ops = {
-	.id_led_init		= e1000e_id_led_init,
+	.id_led_init			= e1000e_id_led_init,
 	/* check_mng_mode dependent on mac type */
-	.check_for_link		= e1000_check_for_copper_link_ich8lan,
+	.check_for_link			= e1000_check_for_copper_link_ich8lan,
 	/* cleanup_led dependent on mac type */
-	.clear_hw_cntrs		= e1000_clear_hw_cntrs_ich8lan,
-	.get_bus_info		= e1000_get_bus_info_ich8lan,
-	.set_lan_id		= e1000_set_lan_id_single_port,
-	.get_link_up_info	= e1000_get_link_up_info_ich8lan,
+	.clear_hw_cntrs			= e1000_clear_hw_cntrs_ich8lan,
+	.get_bus_info			= e1000_get_bus_info_ich8lan,
+	.set_lan_id			= e1000_set_lan_id_single_port,
+	.get_link_up_info		= e1000_get_link_up_info_ich8lan,
 	/* led_on dependent on mac type */
 	/* led_off dependent on mac type */
-	.update_mc_addr_list	= e1000e_update_mc_addr_list_generic,
-	.reset_hw		= e1000_reset_hw_ich8lan,
-	.init_hw		= e1000_init_hw_ich8lan,
-	.setup_link		= e1000_setup_link_ich8lan,
-	.setup_physical_interface= e1000_setup_copper_link_ich8lan,
+	.update_mc_addr_list		= e1000e_update_mc_addr_list_generic,
+	.reset_hw			= e1000_reset_hw_ich8lan,
+	.init_hw			= e1000_init_hw_ich8lan,
+	.setup_link			= e1000_setup_link_ich8lan,
+	.setup_physical_interface	= e1000_setup_copper_link_ich8lan,
 	/* id_led_init dependent on mac type */
 };
 
@@ -3891,7 +3891,7 @@ static struct e1000_phy_operations ich8_phy_ops = {
 
 static struct e1000_nvm_operations ich8_nvm_ops = {
 	.acquire		= e1000_acquire_nvm_ich8lan,
-	.read		 	= e1000_read_nvm_ich8lan,
+	.read			= e1000_read_nvm_ich8lan,
 	.release		= e1000_release_nvm_ich8lan,
 	.update			= e1000_update_nvm_checksum_ich8lan,
 	.valid_led_default	= e1000_valid_led_default_ich8lan,
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 0fd4eb5..20870b2 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -194,7 +194,7 @@ s32 e1000_check_alt_mac_addr_generic(struct e1000_hw *hw)
 		goto out;
 
 	ret_val = e1000_read_nvm(hw, NVM_ALT_MAC_ADDR_PTR, 1,
-	                         &nvm_alt_mac_addr_offset);
+				 &nvm_alt_mac_addr_offset);
 	if (ret_val) {
 		e_dbg("NVM Read Error\n");
 		goto out;
@@ -1505,10 +1505,10 @@ s32 e1000e_setup_led_generic(struct e1000_hw *hw)
 		hw->mac.ledctl_default = ledctl;
 		/* Turn off LED0 */
 		ledctl &= ~(E1000_LEDCTL_LED0_IVRT |
-		            E1000_LEDCTL_LED0_BLINK |
-		            E1000_LEDCTL_LED0_MODE_MASK);
+			    E1000_LEDCTL_LED0_BLINK |
+			    E1000_LEDCTL_LED0_MODE_MASK);
 		ledctl |= (E1000_LEDCTL_MODE_LED_OFF <<
-		           E1000_LEDCTL_LED0_MODE_SHIFT);
+			   E1000_LEDCTL_LED0_MODE_SHIFT);
 		ew32(LEDCTL, ledctl);
 	} else if (hw->phy.media_type == e1000_media_type_copper) {
 		ew32(LEDCTL, hw->mac.ledctl_mode1);
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 0adcb79..820ea48 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -682,7 +682,7 @@ no_buffers:
  **/
 
 static void e1000_alloc_jumbo_rx_buffers(struct e1000_adapter *adapter,
-                                         int cleaned_count)
+					 int cleaned_count)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
@@ -723,8 +723,8 @@ check_page:
 
 		if (!buffer_info->dma)
 			buffer_info->dma = dma_map_page(&pdev->dev,
-			                                buffer_info->page, 0,
-			                                PAGE_SIZE,
+							buffer_info->page, 0,
+							PAGE_SIZE,
 							DMA_FROM_DEVICE);
 
 		rx_desc = E1000_RX_DESC(*rx_ring, i);
@@ -921,8 +921,8 @@ static void e1000_put_txbuf(struct e1000_adapter *adapter,
 static void e1000_print_hw_hang(struct work_struct *work)
 {
 	struct e1000_adapter *adapter = container_of(work,
-	                                             struct e1000_adapter,
-	                                             print_hang_task);
+						     struct e1000_adapter,
+						     print_hang_task);
 	struct e1000_ring *tx_ring = adapter->tx_ring;
 	unsigned int i = tx_ring->next_to_clean;
 	unsigned int eop = tx_ring->buffer_info[i].next_to_watch;
@@ -1249,7 +1249,7 @@ next_desc:
  * e1000_consume_page - helper function
  **/
 static void e1000_consume_page(struct e1000_buffer *bi, struct sk_buff *skb,
-                               u16 length)
+			       u16 length)
 {
 	bi->page = NULL;
 	skb->len += length;
@@ -1266,7 +1266,7 @@ static void e1000_consume_page(struct e1000_buffer *bi, struct sk_buff *skb,
  **/
 
 static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
-                                     int *work_done, int work_to_do)
+				     int *work_done, int work_to_do)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
@@ -1277,7 +1277,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 	unsigned int i;
 	int cleaned_count = 0;
 	bool cleaned = false;
-	unsigned int total_rx_bytes=0, total_rx_packets=0;
+	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 
 	i = rx_ring->next_to_clean;
 	rx_desc = E1000_RX_DESC(*rx_ring, i);
@@ -1332,7 +1332,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 				/* this is the beginning of a chain */
 				rxtop = skb;
 				skb_fill_page_desc(rxtop, 0, buffer_info->page,
-				                   0, length);
+						   0, length);
 			} else {
 				/* this is the middle of a chain */
 				skb_fill_page_desc(rxtop,
@@ -1362,29 +1362,29 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 				    skb_tailroom(skb) >= length) {
 					u8 *vaddr;
 					vaddr = kmap_atomic(buffer_info->page,
-					                   KM_SKB_DATA_SOFTIRQ);
+							   KM_SKB_DATA_SOFTIRQ);
 					memcpy(skb_tail_pointer(skb), vaddr,
 					       length);
 					kunmap_atomic(vaddr,
-					              KM_SKB_DATA_SOFTIRQ);
+						      KM_SKB_DATA_SOFTIRQ);
 					/* re-use the page, so don't erase
 					 * buffer_info->page */
 					skb_put(skb, length);
 				} else {
 					skb_fill_page_desc(skb, 0,
-					                   buffer_info->page, 0,
-				                           length);
+							   buffer_info->page, 0,
+							   length);
 					e1000_consume_page(buffer_info, skb,
-					                   length);
+							   length);
 				}
 			}
 		}
 
 		/* Receive Checksum Offload XXX recompute due to CRC strip? */
 		e1000_rx_checksum(adapter,
-		                  (u32)(status) |
-		                  ((u32)(rx_desc->errors) << 24),
-		                  le16_to_cpu(rx_desc->csum), skb);
+				  (u32)(status) |
+				  ((u32)(rx_desc->errors) << 24),
+				  le16_to_cpu(rx_desc->csum), skb);
 
 		/* probably a little skewed due to removing CRC */
 		total_rx_bytes += skb->len;
@@ -1398,7 +1398,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 		}
 
 		e1000_receive_skb(adapter, netdev, skb, status,
-		                  rx_desc->special);
+				  rx_desc->special);
 
 next_desc:
 		rx_desc->status = 0;
@@ -1448,7 +1448,7 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter)
 						 DMA_FROM_DEVICE);
 			else if (adapter->clean_rx == e1000_clean_jumbo_rx_irq)
 				dma_unmap_page(&pdev->dev, buffer_info->dma,
-				               PAGE_SIZE,
+					       PAGE_SIZE,
 					       DMA_FROM_DEVICE);
 			else if (adapter->clean_rx == e1000_clean_rx_irq_ps)
 				dma_unmap_single(&pdev->dev, buffer_info->dma,
@@ -4034,11 +4034,11 @@ static void e1000_print_link_info(struct e1000_adapter *adapter)
 	       adapter->netdev->name,
 	       adapter->link_speed,
 	       (adapter->link_duplex == FULL_DUPLEX) ?
-	                        "Full Duplex" : "Half Duplex",
+				"Full Duplex" : "Half Duplex",
 	       ((ctrl & E1000_CTRL_TFCE) && (ctrl & E1000_CTRL_RFCE)) ?
-	                        "RX/TX" :
+				"RX/TX" :
 	       ((ctrl & E1000_CTRL_RFCE) ? "RX" :
-	       ((ctrl & E1000_CTRL_TFCE) ? "TX" : "None" )));
+	       ((ctrl & E1000_CTRL_TFCE) ? "TX" : "None")));
 }
 
 static bool e1000e_has_link(struct e1000_adapter *adapter)
@@ -4243,7 +4243,7 @@ static void e1000_watchdog_task(struct work_struct *work)
 			tctl |= E1000_TCTL_EN;
 			ew32(TCTL, tctl);
 
-                        /*
+			/*
 			 * Perform any post-link-up configuration before
 			 * reporting link up.
 			 */
@@ -4394,14 +4394,14 @@ static int e1000_tso(struct e1000_adapter *adapter,
 		iph->tot_len = 0;
 		iph->check = 0;
 		tcp_hdr(skb)->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
-		                                         0, IPPROTO_TCP, 0);
+							 0, IPPROTO_TCP, 0);
 		cmd_length = E1000_TXD_CMD_IP;
 		ipcse = skb_transport_offset(skb) - 1;
 	} else if (skb_is_gso_v6(skb)) {
 		ipv6_hdr(skb)->payload_len = 0;
 		tcp_hdr(skb)->check = ~csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-		                                       &ipv6_hdr(skb)->daddr,
-		                                       0, IPPROTO_TCP, 0);
+						       &ipv6_hdr(skb)->daddr,
+						       0, IPPROTO_TCP, 0);
 		ipcse = 0;
 	}
 	ipcss = skb_network_offset(skb);
@@ -4411,7 +4411,7 @@ static int e1000_tso(struct e1000_adapter *adapter,
 	tucse = 0;
 
 	cmd_length |= (E1000_TXD_CMD_DEXT | E1000_TXD_CMD_TSE |
-	               E1000_TXD_CMD_TCP | (skb->len - (hdr_len)));
+		       E1000_TXD_CMD_TCP | (skb->len - (hdr_len)));
 
 	i = tx_ring->next_to_use;
 	context_desc = E1000_CONTEXT_DESC(*tx_ring, i);
@@ -4589,7 +4589,7 @@ dma_error:
 		count--;
 
 	while (count--) {
-		if (i==0)
+		if (i == 0)
 			i += tx_ring->count;
 		i--;
 		buffer_info = &tx_ring->buffer_info[i];
@@ -4734,7 +4734,7 @@ static int e1000_maybe_stop_tx(struct net_device *netdev, int size)
 	return __e1000_maybe_stop_tx(netdev, size);
 }
 
-#define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
+#define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1)
 static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 				    struct net_device *netdev)
 {
@@ -5105,7 +5105,7 @@ static int e1000_init_phy_wakeup(struct e1000_adapter *adapter, u32 wufc)
 		return retval;
 	}
 	e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT,
-	                         (BM_WUC_ENABLE_PAGE << IGP_PAGE_SHIFT));
+				 (BM_WUC_ENABLE_PAGE << IGP_PAGE_SHIFT));
 	retval = e1000e_read_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, &phy_reg);
 	if (retval) {
 		e_err("Could not read PHY page 769\n");
@@ -5233,7 +5233,7 @@ static void e1000_power_off(struct pci_dev *pdev, bool sleep, bool wake)
 }
 
 static void e1000_complete_shutdown(struct pci_dev *pdev, bool sleep,
-                                    bool wake)
+				    bool wake)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -5251,7 +5251,7 @@ static void e1000_complete_shutdown(struct pci_dev *pdev, bool sleep,
 
 		pci_read_config_word(us_dev, pos + PCI_EXP_DEVCTL, &devctl);
 		pci_write_config_word(us_dev, pos + PCI_EXP_DEVCTL,
-		                      (devctl & ~PCI_EXP_DEVCTL_CERE));
+				      (devctl & ~PCI_EXP_DEVCTL_CERE));
 
 		e1000_power_off(pdev, sleep, wake);
 
@@ -5632,7 +5632,7 @@ static void e1000_print_device_info(struct e1000_adapter *adapter)
 	e_info("(PCI Express:2.5GB/s:%s) %pM\n",
 	       /* bus width */
 	       ((hw->bus.width == e1000_bus_width_pcie_x4) ? "Width x4" :
-	        "Width x1"),
+		"Width x1"),
 	       /* MAC address */
 	       netdev->dev_addr);
 	e_info("Intel(R) PRO/%s Network Connection\n",
@@ -5732,8 +5732,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	}
 
 	err = pci_request_selected_regions_exclusive(pdev,
-	                                  pci_select_bars(pdev, IORESOURCE_MEM),
-	                                  e1000e_driver_name);
+					  pci_select_bars(pdev, IORESOURCE_MEM),
+					  e1000e_driver_name);
 	if (err)
 		goto err_pci_reg;
 
@@ -6000,7 +6000,7 @@ err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
 	pci_release_selected_regions(pdev,
-	                             pci_select_bars(pdev, IORESOURCE_MEM));
+				     pci_select_bars(pdev, IORESOURCE_MEM));
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -6063,7 +6063,7 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	if (adapter->hw.flash_address)
 		iounmap(adapter->hw.flash_address);
 	pci_release_selected_regions(pdev,
-	                             pci_select_bars(pdev, IORESOURCE_MEM));
+				     pci_select_bars(pdev, IORESOURCE_MEM));
 
 	free_netdev(netdev);
 
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index 3d36911..2687295 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -157,7 +157,7 @@ E1000_PARAM(WriteProtectNVM, "Write-protect NVM [WARNING: disabling this can lea
  * Default Value: 1 (enabled)
  */
 E1000_PARAM(CrcStripping, "Enable CRC Stripping, disable if your BMC needs " \
-                          "the CRC");
+			  "the CRC");
 
 struct e1000_option {
 	enum { enable_option, range_option, list_option } type;
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 3d3dc0c..a26c296 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -39,7 +39,7 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 					  u16 *data, bool read);
 static u32 e1000_get_phy_addr_for_hv_page(u32 page);
 static s32 e1000_access_phy_debug_regs_hv(struct e1000_hw *hw, u32 offset,
-                                          u16 *data, bool read);
+					  u16 *data, bool read);
 
 /* Cable length tables */
 static const u16 e1000_m88_cable_length_table[] =
@@ -345,7 +345,7 @@ s32 e1000e_write_phy_reg_m88(struct e1000_hw *hw, u32 offset, u16 data)
  *  semaphores before exiting.
  **/
 static s32 __e1000e_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data,
-                                    bool locked)
+				     bool locked)
 {
 	s32 ret_val = 0;
 
@@ -367,7 +367,7 @@ static s32 __e1000e_read_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 *data,
 	}
 
 	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
-	                                  data);
+					  data);
 
 release:
 	if (!locked)
@@ -416,7 +416,7 @@ s32 e1000e_read_phy_reg_igp_locked(struct e1000_hw *hw, u32 offset, u16 *data)
  *  at the offset.  Release any acquired semaphores before exiting.
  **/
 static s32 __e1000e_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data,
-                                     bool locked)
+				      bool locked)
 {
 	s32 ret_val = 0;
 
@@ -488,7 +488,7 @@ s32 e1000e_write_phy_reg_igp_locked(struct e1000_hw *hw, u32 offset, u16 data)
  *  Release any acquired semaphores before exiting.
  **/
 static s32 __e1000_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data,
-                                 bool locked)
+				 bool locked)
 {
 	u32 kmrnctrlsta;
 	s32 ret_val = 0;
@@ -560,7 +560,7 @@ s32 e1000e_read_kmrn_reg_locked(struct e1000_hw *hw, u32 offset, u16 *data)
  *  before exiting.
  **/
 static s32 __e1000_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data,
-                                  bool locked)
+				  bool locked)
 {
 	u32 kmrnctrlsta;
 	s32 ret_val = 0;
@@ -761,7 +761,7 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 
 	if (phy->type == e1000_phy_82578) {
 		ret_val = phy->ops.read_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL,
-		                            &phy_data);
+					    &phy_data);
 		if (ret_val)
 			return ret_val;
 
@@ -769,7 +769,7 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 		phy_data |= I82578_EPSCR_DOWNSHIFT_ENABLE;
 		phy_data &= ~I82578_EPSCR_DOWNSHIFT_COUNTER_MASK;
 		ret_val = phy->ops.write_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL,
-		                             phy_data);
+					     phy_data);
 		if (ret_val)
 			return ret_val;
 	}
@@ -1400,9 +1400,9 @@ s32 e1000_phy_force_speed_duplex_ife(struct e1000_hw *hw)
 		e_dbg("Waiting for forced speed/duplex link on IFE phy.\n");
 
 		ret_val = e1000e_phy_has_link_generic(hw,
-		                                     PHY_FORCE_LIMIT,
-		                                     100000,
-		                                     &link);
+						     PHY_FORCE_LIMIT,
+						     100000,
+						     &link);
 		if (ret_val)
 			goto out;
 
@@ -1411,9 +1411,9 @@ s32 e1000_phy_force_speed_duplex_ife(struct e1000_hw *hw)
 
 		/* Try once more */
 		ret_val = e1000e_phy_has_link_generic(hw,
-		                                     PHY_FORCE_LIMIT,
-		                                     100000,
-		                                     &link);
+						     PHY_FORCE_LIMIT,
+						     100000,
+						     &link);
 		if (ret_val)
 			goto out;
 	}
@@ -1698,8 +1698,8 @@ s32 e1000_check_polarity_ife(struct e1000_hw *hw)
 
 	if (!ret_val)
 		phy->cable_polarity = (phy_data & mask)
-		                       ? e1000_rev_polarity_reversed
-		                       : e1000_rev_polarity_normal;
+				       ? e1000_rev_polarity_reversed
+				       : e1000_rev_polarity_normal;
 
 	return ret_val;
 }
@@ -1807,7 +1807,7 @@ s32 e1000e_get_cable_length_m88(struct e1000_hw *hw)
 		goto out;
 
 	index = (phy_data & M88E1000_PSSR_CABLE_LENGTH) >>
-	        M88E1000_PSSR_CABLE_LENGTH_SHIFT;
+		M88E1000_PSSR_CABLE_LENGTH_SHIFT;
 	if (index >= M88E1000_CABLE_LENGTH_TABLE_SIZE - 1) {
 		ret_val = -E1000_ERR_PHY;
 		goto out;
@@ -2055,7 +2055,7 @@ s32 e1000_get_phy_info_ife(struct e1000_hw *hw)
 	if (ret_val)
 		goto out;
 	phy->polarity_correction = (data & IFE_PSC_AUTO_POLARITY_DISABLE)
-	                           ? false : true;
+				   ? false : true;
 
 	if (phy->polarity_correction) {
 		ret_val = e1000_check_polarity_ife(hw);
@@ -2064,8 +2064,8 @@ s32 e1000_get_phy_info_ife(struct e1000_hw *hw)
 	} else {
 		/* Polarity is forced */
 		phy->cable_polarity = (data & IFE_PSC_FORCE_POLARITY)
-		                      ? e1000_rev_polarity_reversed
-		                      : e1000_rev_polarity_normal;
+				      ? e1000_rev_polarity_reversed
+				      : e1000_rev_polarity_normal;
 	}
 
 	ret_val = e1e_rphy(hw, IFE_PHY_MDIX_CONTROL, &data);
@@ -2432,13 +2432,13 @@ s32 e1000e_write_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 data)
 
 		/* Page is shifted left, PHY expects (page x 32) */
 		ret_val = e1000e_write_phy_reg_mdic(hw, page_select,
-		                                    (page << page_shift));
+						    (page << page_shift));
 		if (ret_val)
 			goto out;
 	}
 
 	ret_val = e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
-	                                    data);
+					    data);
 
 out:
 	hw->phy.ops.release(hw);
@@ -2491,13 +2491,13 @@ s32 e1000e_read_phy_reg_bm(struct e1000_hw *hw, u32 offset, u16 *data)
 
 		/* Page is shifted left, PHY expects (page x 32) */
 		ret_val = e1000e_write_phy_reg_mdic(hw, page_select,
-		                                    (page << page_shift));
+						    (page << page_shift));
 		if (ret_val)
 			goto out;
 	}
 
 	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & offset,
-	                                   data);
+					   data);
 out:
 	hw->phy.ops.release(hw);
 	return ret_val;
@@ -2628,7 +2628,7 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 
 	/* Set page 769 */
 	e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT,
-	                          (BM_WUC_ENABLE_PAGE << IGP_PAGE_SHIFT));
+				  (BM_WUC_ENABLE_PAGE << IGP_PAGE_SHIFT));
 
 	ret_val = e1000e_read_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, &phy_reg);
 	if (ret_val) {
@@ -2646,7 +2646,7 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 
 	/* Write bit 2 = 1, and clear bit 4 to 769_17 */
 	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ENABLE_REG,
-	                                    phy_reg | BM_WUC_ENABLE_BIT);
+					    phy_reg | BM_WUC_ENABLE_BIT);
 	if (ret_val) {
 		e_dbg("Could not write PHY page 769 bit 2\n");
 		goto out;
@@ -2654,7 +2654,7 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 
 	/* Select page 800 */
 	ret_val = e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT,
-	                                    (BM_WUC_PAGE << IGP_PAGE_SHIFT));
+					    (BM_WUC_PAGE << IGP_PAGE_SHIFT));
 
 	/* Write the page 800 offset value using opcode 0x11 */
 	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ADDRESS_OPCODE, reg);
@@ -2664,11 +2664,11 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 	}
 
 	if (read) {
-	        /* Read the page 800 value using opcode 0x12 */
+		/* Read the page 800 value using opcode 0x12 */
 		ret_val = e1000e_read_phy_reg_mdic(hw, BM_WUC_DATA_OPCODE,
-		                                   data);
+						   data);
 	} else {
-	        /* Write the page 800 value using opcode 0x12 */
+		/* Write the page 800 value using opcode 0x12 */
 		ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_DATA_OPCODE,
 						    *data);
 	}
@@ -2683,7 +2683,7 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 	 * Set page 769
 	 */
 	e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT,
-	                          (BM_WUC_ENABLE_PAGE << IGP_PAGE_SHIFT));
+				  (BM_WUC_ENABLE_PAGE << IGP_PAGE_SHIFT));
 
 	/* Clear 769_17.2 */
 	ret_val = e1000e_write_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, phy_reg);
@@ -2782,7 +2782,7 @@ static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active)
  *  semaphore before exiting.
  **/
 static s32 __e1000_read_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 *data,
-                                   bool locked)
+				   bool locked)
 {
 	s32 ret_val;
 	u16 page = BM_PHY_REG_PAGE(offset);
@@ -2797,13 +2797,13 @@ static s32 __e1000_read_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 *data,
 	/* Page 800 works differently than the rest so it has its own func */
 	if (page == BM_WUC_PAGE) {
 		ret_val = e1000_access_phy_wakeup_reg_bm(hw, offset,
-		                                         data, true);
+							 data, true);
 		goto out;
 	}
 
 	if (page > 0 && page < HV_INTC_FC_PAGE_START) {
 		ret_val = e1000_access_phy_debug_regs_hv(hw, offset,
-		                                         data, true);
+							 data, true);
 		goto out;
 	}
 
@@ -2828,7 +2828,7 @@ static s32 __e1000_read_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 *data,
 	}
 
 	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & reg,
-	                                  data);
+					  data);
 out:
 	if (!locked)
 		hw->phy.ops.release(hw);
@@ -2876,7 +2876,7 @@ s32 e1000_read_phy_reg_hv_locked(struct e1000_hw *hw, u32 offset, u16 *data)
  *  at the offset.  Release any acquired semaphores before exiting.
  **/
 static s32 __e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data,
-                                    bool locked)
+				    bool locked)
 {
 	s32 ret_val;
 	u16 page = BM_PHY_REG_PAGE(offset);
@@ -2891,13 +2891,13 @@ static s32 __e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data,
 	/* Page 800 works differently than the rest so it has its own func */
 	if (page == BM_WUC_PAGE) {
 		ret_val = e1000_access_phy_wakeup_reg_bm(hw, offset,
-		                                         &data, false);
+							 &data, false);
 		goto out;
 	}
 
 	if (page > 0 && page < HV_INTC_FC_PAGE_START) {
 		ret_val = e1000_access_phy_debug_regs_hv(hw, offset,
-		                                         &data, false);
+							 &data, false);
 		goto out;
 	}
 
@@ -2917,7 +2917,7 @@ static s32 __e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data,
 	    (data & (1 << 11))) {
 		u16 data2 = 0x7EFF;
 		ret_val = e1000_access_phy_debug_regs_hv(hw, (1 << 6) | 0x3,
-		                                         &data2, false);
+							 &data2, false);
 		if (ret_val)
 			goto out;
 	}
@@ -2938,7 +2938,7 @@ static s32 __e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data,
 	}
 
 	ret_val = e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & reg,
-	                                  data);
+					  data);
 
 out:
 	if (!locked)
@@ -3001,7 +3001,7 @@ static u32 e1000_get_phy_addr_for_hv_page(u32 page)
  *  to read these regs uses the address port and data port to read/write.
  **/
 static s32 e1000_access_phy_debug_regs_hv(struct e1000_hw *hw, u32 offset,
-                                          u16 *data, bool read)
+					  u16 *data, bool read)
 {
 	s32 ret_val;
 	u32 addr_reg = 0;
@@ -3009,7 +3009,7 @@ static s32 e1000_access_phy_debug_regs_hv(struct e1000_hw *hw, u32 offset,
 
 	/* This takes care of the difference with desktop vs mobile phy */
 	addr_reg = (hw->phy.type == e1000_phy_82578) ?
-	           I82578_ADDR_REG : I82577_ADDR_REG;
+		   I82578_ADDR_REG : I82577_ADDR_REG;
 	data_reg = addr_reg + 1;
 
 	/* All operations in this function are phy address 2 */
@@ -3067,25 +3067,25 @@ s32 e1000_link_stall_workaround_hv(struct e1000_hw *hw)
 		goto out;
 
 	data &= BM_CS_STATUS_LINK_UP |
-	        BM_CS_STATUS_RESOLVED |
-	        BM_CS_STATUS_SPEED_MASK;
+		BM_CS_STATUS_RESOLVED |
+		BM_CS_STATUS_SPEED_MASK;
 
 	if (data != (BM_CS_STATUS_LINK_UP |
-	             BM_CS_STATUS_RESOLVED |
-	             BM_CS_STATUS_SPEED_1000))
+		     BM_CS_STATUS_RESOLVED |
+		     BM_CS_STATUS_SPEED_1000))
 		goto out;
 
 	mdelay(200);
 
 	/* flush the packets in the fifo buffer */
 	ret_val = hw->phy.ops.write_reg(hw, HV_MUX_DATA_CTRL,
-	                                HV_MUX_DATA_CTRL_GEN_TO_MAC |
-	                                HV_MUX_DATA_CTRL_FORCE_SPEED);
+					HV_MUX_DATA_CTRL_GEN_TO_MAC |
+					HV_MUX_DATA_CTRL_FORCE_SPEED);
 	if (ret_val)
 		goto out;
 
 	ret_val = hw->phy.ops.write_reg(hw, HV_MUX_DATA_CTRL,
-	                                HV_MUX_DATA_CTRL_GEN_TO_MAC);
+					HV_MUX_DATA_CTRL_GEN_TO_MAC);
 
 out:
 	return ret_val;
@@ -3109,8 +3109,8 @@ s32 e1000_check_polarity_82577(struct e1000_hw *hw)
 
 	if (!ret_val)
 		phy->cable_polarity = (data & I82577_PHY_STATUS2_REV_POLARITY)
-		                      ? e1000_rev_polarity_reversed
-		                      : e1000_rev_polarity_normal;
+				      ? e1000_rev_polarity_reversed
+				      : e1000_rev_polarity_normal;
 
 	return ret_val;
 }
@@ -3144,9 +3144,9 @@ s32 e1000_phy_force_speed_duplex_82577(struct e1000_hw *hw)
 		e_dbg("Waiting for forced speed/duplex link on 82577 phy\n");
 
 		ret_val = e1000e_phy_has_link_generic(hw,
-		                                     PHY_FORCE_LIMIT,
-		                                     100000,
-		                                     &link);
+						     PHY_FORCE_LIMIT,
+						     100000,
+						     &link);
 		if (ret_val)
 			goto out;
 
@@ -3155,9 +3155,9 @@ s32 e1000_phy_force_speed_duplex_82577(struct e1000_hw *hw)
 
 		/* Try once more */
 		ret_val = e1000e_phy_has_link_generic(hw,
-		                                     PHY_FORCE_LIMIT,
-		                                     100000,
-		                                     &link);
+						     PHY_FORCE_LIMIT,
+						     100000,
+						     &link);
 		if (ret_val)
 			goto out;
 	}
@@ -3215,12 +3215,12 @@ s32 e1000_get_phy_info_82577(struct e1000_hw *hw)
 			goto out;
 
 		phy->local_rx = (data & SR_1000T_LOCAL_RX_STATUS)
-		                ? e1000_1000t_rx_status_ok
-		                : e1000_1000t_rx_status_not_ok;
+				? e1000_1000t_rx_status_ok
+				: e1000_1000t_rx_status_not_ok;
 
 		phy->remote_rx = (data & SR_1000T_REMOTE_RX_STATUS)
-		                 ? e1000_1000t_rx_status_ok
-		                 : e1000_1000t_rx_status_not_ok;
+				 ? e1000_1000t_rx_status_ok
+				 : e1000_1000t_rx_status_not_ok;
 	} else {
 		phy->cable_length = E1000_CABLE_LENGTH_UNDEFINED;
 		phy->local_rx = e1000_1000t_rx_status_undefined;
@@ -3249,7 +3249,7 @@ s32 e1000_get_cable_length_82577(struct e1000_hw *hw)
 		goto out;
 
 	length = (phy_data & I82577_DSTATUS_CABLE_LENGTH) >>
-	         I82577_DSTATUS_CABLE_LENGTH_SHIFT;
+		 I82577_DSTATUS_CABLE_LENGTH_SHIFT;
 
 	if (length == E1000_CABLE_LENGTH_UNDEFINED)
 		ret_val = -E1000_ERR_PHY;
-- 
1.7.2.3
