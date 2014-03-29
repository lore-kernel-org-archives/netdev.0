From: Joe Perches <joe@perches.com>
Subject: [ignorable RFC PATCH net-next] intel: whitespace alignment
Date: Sat, 29 Mar 2014 15:43:34 -0700
Message-ID: <1396133014.21529.7.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Linux NICS <linux.nics@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0126.hostedemail.com ([216.40.44.126]:56444 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751878AbaC2Wnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 18:43:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I tried out a new checkpatch alignment test which prefers
argument alignment of multi-line statements over long line
lengths on the intel drivers.

This is the result (with some emacsing)

git diff -w is uninteresting.

It adds several long line warnings I don't care about.

unsigned...
---
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c   |  24 +-
 drivers/net/ethernet/intel/e1000/e1000_hw.c        |  12 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c      |  84 +++----
 drivers/net/ethernet/intel/e1000/e1000_param.c     |   2 +-
 drivers/net/ethernet/intel/i40e/i40e.h             |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |  34 +--
 drivers/net/ethernet/intel/i40e/i40e_alloc.h       |  13 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 238 ++++++++++----------
 drivers/net/ethernet/intel/i40e/i40e_dcb.h         |   9 +-
 drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c      |  16 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |  36 +--
 drivers/net/ethernet/intel/i40e/i40e_diag.c        |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  12 +-
 drivers/net/ethernet/intel/i40e/i40e_hmc.c         |  34 ++-
 drivers/net/ethernet/intel/i40e/i40e_hmc.h         |  30 ++-
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c     |  81 ++++---
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h     |  22 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  78 +++----
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |  25 +--
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   | 249 +++++++++++----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   4 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    |  43 ++--
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h    |   3 +-
 drivers/net/ethernet/intel/i40evf/i40e_alloc.h     |  15 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  19 +-
 drivers/net/ethernet/intel/i40evf/i40e_hmc.h       |  30 ++-
 drivers/net/ethernet/intel/i40evf/i40e_lan_hmc.h   |  22 +-
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |  39 ++--
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |   6 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  25 +--
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  10 +-
 drivers/net/ethernet/intel/igb/e1000_82575.c       |  34 +--
 drivers/net/ethernet/intel/igb/e1000_i210.c        |  18 +-
 drivers/net/ethernet/intel/igb/e1000_mac.c         |  17 +-
 drivers/net/ethernet/intel/igb/e1000_nvm.c         |   4 +-
 drivers/net/ethernet/intel/igb/e1000_phy.c         |   3 +-
 drivers/net/ethernet/intel/igb/e1000_phy.h         |   2 +-
 drivers/net/ethernet/intel/igb/igb_ethtool.c       |  39 ++--
 drivers/net/ethernet/intel/igb/igb_main.c          | 111 ++++-----
 drivers/net/ethernet/intel/igbvf/ethtool.c         |   2 +-
 drivers/net/ethernet/intel/igbvf/netdev.c          |  10 +-
 drivers/net/ethernet/intel/igbvf/vf.c              |   4 +-
 drivers/net/ethernet/intel/ixgb/ixgb_ee.c          |  16 +-
 drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c     |  27 +--
 drivers/net/ethernet/intel/ixgb/ixgb_hw.c          |  37 +--
 drivers/net/ethernet/intel/ixgb/ixgb_hw.h          |   4 +-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c        |  25 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c     |  20 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c     |  14 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c    |  35 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c       |   8 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c |  22 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.h |  22 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h |  28 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c   |   6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |  18 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c      |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  89 ++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c       |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c       |  10 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h     |   2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c     |   8 +-
 drivers/net/ethernet/intel/ixgbevf/ethtool.c       |   4 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |  18 +-
 drivers/net/ethernet/intel/ixgbevf/vf.c            |   3 +-
 drivers/net/ethernet/intel/ixgbevf/vf.h            |   4 +-
 68 files changed, 921 insertions(+), 972 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 73a8aee..603dd09 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -157,7 +157,7 @@ static int e1000_get_settings(struct net_device *netdev,
 	if (er32(STATUS) & E1000_STATUS_LU) {
 
 		e1000_get_speed_and_duplex(hw, &adapter->link_speed,
-		                                   &adapter->link_duplex);
+					   &adapter->link_duplex);
 		ethtool_cmd_speed_set(ecmd, adapter->link_speed);
 
 		/* unfortunately FULL_DUPLEX != DUPLEX_FULL
@@ -526,7 +526,7 @@ static int e1000_set_eeprom(struct net_device *netdev,
 		 * only the first byte of the word is being modified
 		 */
 		ret_val = e1000_read_eeprom(hw, last_word, 1,
-		                  &eeprom_buff[last_word - first_word]);
+					    &eeprom_buff[last_word - first_word]);
 	}
 
 	/* Device's eeprom is always little-endian, word addressable */
@@ -1149,8 +1149,7 @@ static void e1000_phy_reset_clk_and_crs(struct e1000_adapter *adapter)
 	 */
 	e1000_read_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL, &phy_reg);
 	phy_reg |= M88E1000_EPSCR_TX_CLK_25;
-	e1000_write_phy_reg(hw,
-		M88E1000_EXT_PHY_SPEC_CTRL, phy_reg);
+	e1000_write_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL, phy_reg);
 
 	/* In addition, because of the s/w reset above, we need to enable
 	 * CRS on TX.  This must be set for both full and half duplex
@@ -1158,8 +1157,7 @@ static void e1000_phy_reset_clk_and_crs(struct e1000_adapter *adapter)
 	 */
 	e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_reg);
 	phy_reg |= M88E1000_PSCR_ASSERT_CRS_ON_TX;
-	e1000_write_phy_reg(hw,
-		M88E1000_PHY_SPEC_CTRL, phy_reg);
+	e1000_write_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_reg);
 }
 
 static int e1000_nonintegrated_phy_loopback(struct e1000_adapter *adapter)
@@ -1261,9 +1259,9 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 			E1000_CTRL_FD); /* Force Duplex to FULL */
 
 	if (hw->media_type == e1000_media_type_copper &&
-	   hw->phy_type == e1000_phy_m88)
+	    hw->phy_type == e1000_phy_m88) {
 		ctrl_reg |= E1000_CTRL_ILOS; /* Invert Loss of Signal */
-	else {
+	} else {
 		/* Set the ILOS bit on the fiber Nic is half
 		 * duplex link is detected.
 		 */
@@ -1299,7 +1297,8 @@ static int e1000_set_phy_loopback(struct e1000_adapter *adapter)
 			 * attempt this 10 times.
 			 */
 			while (e1000_nonintegrated_phy_loopback(adapter) &&
-			      count++ < 10);
+			       count++ < 10)
+				;
 			if (count < 11)
 				return 0;
 		}
@@ -1400,7 +1399,7 @@ static int e1000_check_lbtest_frame(struct sk_buff *skb,
 	frame_size &= ~1;
 	if (*(skb->data + 3) == 0xFF) {
 		if ((*(skb->data + frame_size / 2 + 10) == 0xBE) &&
-		   (*(skb->data + frame_size / 2 + 12) == 0xAF)) {
+		    (*(skb->data + frame_size / 2 + 12) == 0xAF)) {
 			return 0;
 		}
 	}
@@ -1432,7 +1431,7 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 	for (j = 0; j <= lc; j++) { /* loop count loop */
 		for (i = 0; i < 64; i++) { /* send the packets */
 			e1000_create_lbtest_frame(txdr->buffer_info[i].skb,
-					1024);
+						  1024);
 			dma_sync_single_for_device(&pdev->dev,
 						   txdr->buffer_info[k].dma,
 						   txdr->buffer_info[k].length,
@@ -1860,8 +1859,7 @@ static void e1000_get_strings(struct net_device *netdev, u32 stringset,
 
 	switch (stringset) {
 	case ETH_SS_TEST:
-		memcpy(data, *e1000_gstrings_test,
-			sizeof(e1000_gstrings_test));
+		memcpy(data, *e1000_gstrings_test, sizeof(e1000_gstrings_test));
 		break;
 	case ETH_SS_STATS:
 		for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.c b/drivers/net/ethernet/intel/e1000/e1000_hw.c
index 2879b96..b407789 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.c
@@ -5378,8 +5378,8 @@ static s32 e1000_1000Mb_check_cable_length(struct e1000_hw *hw)
 				hw->ffe_config_state = e1000_ffe_config_active;
 
 				ret_val = e1000_write_phy_reg(hw,
-					      IGP01E1000_PHY_DSP_FFE,
-					      IGP01E1000_PHY_DSP_FFE_CM_CP);
+							      IGP01E1000_PHY_DSP_FFE,
+							      IGP01E1000_PHY_DSP_FFE_CM_CP);
 				if (ret_val)
 					return ret_val;
 				break;
@@ -5448,7 +5448,7 @@ static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw, bool link_up)
 			msleep(20);
 
 			ret_val = e1000_write_phy_reg(hw, 0x0000,
-						    IGP01E1000_IEEE_FORCE_GIGA);
+						      IGP01E1000_IEEE_FORCE_GIGA);
 			if (ret_val)
 				return ret_val;
 			for (i = 0; i < IGP01E1000_PHY_CHANNEL_NUM; i++) {
@@ -5469,7 +5469,7 @@ static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw, bool link_up)
 			}
 
 			ret_val = e1000_write_phy_reg(hw, 0x0000,
-					IGP01E1000_IEEE_RESTART_AUTONEG);
+						      IGP01E1000_IEEE_RESTART_AUTONEG);
 			if (ret_val)
 				return ret_val;
 
@@ -5504,7 +5504,7 @@ static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw, bool link_up)
 			msleep(20);
 
 			ret_val = e1000_write_phy_reg(hw, 0x0000,
-						    IGP01E1000_IEEE_FORCE_GIGA);
+						      IGP01E1000_IEEE_FORCE_GIGA);
 			if (ret_val)
 				return ret_val;
 			ret_val =
@@ -5514,7 +5514,7 @@ static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw, bool link_up)
 				return ret_val;
 
 			ret_val = e1000_write_phy_reg(hw, 0x0000,
-					IGP01E1000_IEEE_RESTART_AUTONEG);
+						      IGP01E1000_IEEE_RESTART_AUTONEG);
 			if (ret_val)
 				return ret_val;
 
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 46e6544..2ce5332 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -99,13 +99,13 @@ int e1000_setup_all_rx_resources(struct e1000_adapter *adapter);
 void e1000_free_all_tx_resources(struct e1000_adapter *adapter);
 void e1000_free_all_rx_resources(struct e1000_adapter *adapter);
 static int e1000_setup_tx_resources(struct e1000_adapter *adapter,
-                             struct e1000_tx_ring *txdr);
+				    struct e1000_tx_ring *txdr);
 static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
-                             struct e1000_rx_ring *rxdr);
+				    struct e1000_rx_ring *rxdr);
 static void e1000_free_tx_resources(struct e1000_adapter *adapter,
-                             struct e1000_tx_ring *tx_ring);
+				    struct e1000_tx_ring *tx_ring);
 static void e1000_free_rx_resources(struct e1000_adapter *adapter,
-                             struct e1000_rx_ring *rx_ring);
+				    struct e1000_rx_ring *rx_ring);
 void e1000_update_stats(struct e1000_adapter *adapter);
 
 static int e1000_init_module(void);
@@ -187,10 +187,10 @@ static void e1000_netpoll (struct net_device *netdev);
 static unsigned int copybreak __read_mostly = COPYBREAK_DEFAULT;
 module_param(copybreak, uint, 0644);
 MODULE_PARM_DESC(copybreak,
-	"Maximum size of packet that is copied to a new buffer on receive");
+		 "Maximum size of packet that is copied to a new buffer on receive");
 
 static pci_ers_result_t e1000_io_error_detected(struct pci_dev *pdev,
-                     pci_channel_state_t state);
+						pci_channel_state_t state);
 static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev);
 static void e1000_io_resume(struct pci_dev *pdev);
 
@@ -461,7 +461,7 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 	 * (c) SoL/IDER session is active
 	 */
 	if (!adapter->wol && hw->mac_type >= e1000_82540 &&
-	   hw->media_type == e1000_media_type_copper) {
+	    hw->media_type == e1000_media_type_copper) {
 		u16 mii_reg = 0;
 
 		switch (hw->mac_type) {
@@ -801,7 +801,7 @@ static int e1000_is_need_ioport(struct pci_dev *pdev)
 }
 
 static netdev_features_t e1000_fix_features(struct net_device *netdev,
-	netdev_features_t features)
+					    netdev_features_t features)
 {
 	/* Since there is no support for separate Rx/Tx vlan accel
 	 * enable/disable make sure Tx flag is always in same state as Rx.
@@ -815,7 +815,7 @@ static netdev_features_t e1000_fix_features(struct net_device *netdev,
 }
 
 static int e1000_set_features(struct net_device *netdev,
-	netdev_features_t features)
+			      netdev_features_t features)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	netdev_features_t changed = features ^ netdev->features;
@@ -1041,7 +1041,7 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (hw->mac_type == e1000_ce4100) {
 		hw->ce4100_gbe_mdio_base_virt =
 					ioremap(pci_resource_start(pdev, BAR_1),
-		                                pci_resource_len(pdev, BAR_1));
+						pci_resource_len(pdev, BAR_1));
 
 		if (!hw->ce4100_gbe_mdio_base_virt)
 			goto err_mdio_ioremap;
@@ -1056,7 +1056,7 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	if ((hw->mac_type >= e1000_82544) &&
-	   (hw->mac_type != e1000_82547))
+	    (hw->mac_type != e1000_82547))
 		netdev->hw_features |= NETIF_F_TSO;
 
 	netdev->priv_flags |= IFF_SUPP_NOFCS;
@@ -1134,21 +1134,21 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	case e1000_82543:
 		break;
 	case e1000_82544:
-		e1000_read_eeprom(hw,
-			EEPROM_INIT_CONTROL2_REG, 1, &eeprom_data);
+		e1000_read_eeprom(hw, EEPROM_INIT_CONTROL2_REG, 1,
+				  &eeprom_data);
 		eeprom_apme_mask = E1000_EEPROM_82544_APM;
 		break;
 	case e1000_82546:
 	case e1000_82546_rev_3:
 		if (er32(STATUS) & E1000_STATUS_FUNC_1){
-			e1000_read_eeprom(hw,
-				EEPROM_INIT_CONTROL3_PORT_B, 1, &eeprom_data);
+			e1000_read_eeprom(hw, EEPROM_INIT_CONTROL3_PORT_B, 1,
+					  &eeprom_data);
 			break;
 		}
 		/* Fall Through */
 	default:
-		e1000_read_eeprom(hw,
-			EEPROM_INIT_CONTROL3_PORT_A, 1, &eeprom_data);
+		e1000_read_eeprom(hw, EEPROM_INIT_CONTROL3_PORT_A, 1,
+				  &eeprom_data);
 		break;
 	}
 	if (eeprom_data & eeprom_apme_mask)
@@ -2341,8 +2341,8 @@ static void e1000_82547_tx_fifo_stall_task(struct work_struct *work)
 
 	if (atomic_read(&adapter->tx_fifo_stall)) {
 		if ((er32(TDT) == er32(TDH)) &&
-		   (er32(TDFT) == er32(TDFH)) &&
-		   (er32(TDFTS) == er32(TDFHS))) {
+		    (er32(TDFT) == er32(TDFH)) &&
+		    (er32(TDFTS) == er32(TDFHS))) {
 			tctl = er32(TCTL);
 			ew32(TCTL, tctl & ~E1000_TCTL_EN);
 			ew32(TDFT, adapter->tx_head_addr);
@@ -2840,15 +2840,15 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 		 * packet is smaller than 2048 - 16 - 16 (or 2016) bytes
 		 */
 		if (unlikely((hw->bus_type == e1000_bus_type_pcix) &&
-		                (size > 2015) && count == 0))
+			     (size > 2015) && count == 0))
 		        size = 2015;
 
 		/* Workaround for potential 82544 hang in PCI-X.  Avoid
 		 * terminating buffers within evenly-aligned dwords.
 		 */
 		if (unlikely(adapter->pcix_82544 &&
-		   !((unsigned long)(skb->data + offset + size - 1) & 4) &&
-		   size > 4))
+			     !((unsigned long)(skb->data + offset + size - 1) & 4) &&
+			     size > 4))
 			size -= 4;
 
 		buffer_info->length = size;
@@ -2891,7 +2891,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			 * in TSO mode.  Append 4-byte sentinel desc
 			 */
 			if (unlikely(mss && f == (nr_frags-1) &&
-			    size == len && size > 8))
+				     size == len && size > 8))
 				size -= 4;
 			/* Workaround for potential 82544 hang in PCI-X.
 			 * Avoid terminating buffers within evenly-aligned
@@ -3184,8 +3184,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	/* work-around for errata 10 and it applies to all controllers
 	 * in PCI-X mode, so add one more descriptor to the count
 	 */
-	if (unlikely((hw->bus_type == e1000_bus_type_pcix) &&
-			(len > 2015)))
+	if (unlikely((hw->bus_type == e1000_bus_type_pcix) && (len > 2015)))
 		count++;
 
 	nr_frags = skb_shinfo(skb)->nr_frags;
@@ -3704,14 +3703,14 @@ void e1000_update_stats(struct e1000_adapter *adapter)
 	/* Phy Stats */
 	if (hw->media_type == e1000_media_type_copper) {
 		if ((adapter->link_speed == SPEED_1000) &&
-		   (!e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_tmp))) {
+		    (!e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_tmp))) {
 			phy_tmp &= PHY_IDLE_ERROR_COUNT_MASK;
 			adapter->phy_stats.idle_errors += phy_tmp;
 		}
 
 		if ((hw->mac_type <= e1000_82546) &&
-		   (hw->phy_type == e1000_phy_m88) &&
-		   !e1000_read_phy_reg(hw, M88E1000_RX_ERR_CNTR, &phy_tmp))
+		    (hw->phy_type == e1000_phy_m88) &&
+		    !e1000_read_phy_reg(hw, M88E1000_RX_ERR_CNTR, &phy_tmp))
 			adapter->phy_stats.receive_errors += phy_tmp;
 	}
 
@@ -4042,7 +4041,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 
 		/* errors is only valid for DD + EOP descriptors */
 		if (unlikely((status & E1000_RXD_STAT_EOP) &&
-		    (rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK))) {
+			     (rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK))) {
 			u8 *mapped;
 			u8 last_byte;
 
@@ -4084,8 +4083,9 @@ process_skb:
 			} else {
 				/* this is the middle of a chain */
 				skb_fill_page_desc(rxtop,
-				    skb_shinfo(rxtop)->nr_frags,
-				    buffer_info->page, 0, length);
+						   skb_shinfo(rxtop)->nr_frags,
+						   buffer_info->page, 0,
+						   length);
 				/* re-use the skb, only consumed the page */
 				buffer_info->skb = skb;
 			}
@@ -4095,8 +4095,9 @@ process_skb:
 			if (rxtop) {
 				/* end of the chain */
 				skb_fill_page_desc(rxtop,
-				    skb_shinfo(rxtop)->nr_frags,
-				    buffer_info->page, 0, length);
+						   skb_shinfo(rxtop)->nr_frags,
+						   buffer_info->page, 0,
+						   length);
 				/* re-use the current skb, we only consumed the
 				 * page
 				 */
@@ -4179,8 +4180,8 @@ next_desc:
  * of reassembly being done in the stack
  */
 static void e1000_check_copybreak(struct net_device *netdev,
-				 struct e1000_buffer *buffer_info,
-				 u32 length, struct sk_buff **skb)
+				  struct e1000_buffer *buffer_info,
+				  u32 length, struct sk_buff **skb)
 {
 	struct sk_buff *new_skb;
 
@@ -4506,8 +4507,8 @@ map_skb:
 
 		/* Fix for errata 23, can't cross 64kB boundary */
 		if (!e1000_check_64k_bound(adapter,
-					(void *)(unsigned long)buffer_info->dma,
-					adapter->rx_buffer_len)) {
+					   (void *)(unsigned long)buffer_info->dma,
+					   adapter->rx_buffer_len)) {
 			e_err(rx_err, "dma align check failed: %u bytes at "
 			      "%p\n", adapter->rx_buffer_len,
 			      (void *)(unsigned long)buffer_info->dma);
@@ -4556,7 +4557,7 @@ static void e1000_smartspeed(struct e1000_adapter *adapter)
 	u16 phy_ctrl;
 
 	if ((hw->phy_type != e1000_phy_igp) || !hw->autoneg ||
-	   !(hw->autoneg_advertised & ADVERTISE_1000_FULL))
+	    !(hw->autoneg_advertised & ADVERTISE_1000_FULL))
 		return;
 
 	if (adapter->smartspeed == 0) {
@@ -4574,8 +4575,7 @@ static void e1000_smartspeed(struct e1000_adapter *adapter)
 					    phy_ctrl);
 			adapter->smartspeed++;
 			if (!e1000_phy_setup_autoneg(hw) &&
-			   !e1000_read_phy_reg(hw, PHY_CTRL,
-					       &phy_ctrl)) {
+			    !e1000_read_phy_reg(hw, PHY_CTRL, &phy_ctrl)) {
 				phy_ctrl |= (MII_CR_AUTO_NEG_EN |
 					     MII_CR_RESTART_AUTO_NEG);
 				e1000_write_phy_reg(hw, PHY_CTRL,
@@ -4589,7 +4589,7 @@ static void e1000_smartspeed(struct e1000_adapter *adapter)
 		phy_ctrl |= CR_1000T_MS_ENABLE;
 		e1000_write_phy_reg(hw, PHY_1000T_CTRL, phy_ctrl);
 		if (!e1000_phy_setup_autoneg(hw) &&
-		   !e1000_read_phy_reg(hw, PHY_CTRL, &phy_ctrl)) {
+		    !e1000_read_phy_reg(hw, PHY_CTRL, &phy_ctrl)) {
 			phy_ctrl |= (MII_CR_AUTO_NEG_EN |
 				     MII_CR_RESTART_AUTO_NEG);
 			e1000_write_phy_reg(hw, PHY_CTRL, phy_ctrl);
@@ -4644,7 +4644,7 @@ static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 	case SIOCGMIIREG:
 		spin_lock_irqsave(&adapter->stats_lock, flags);
 		if (e1000_read_phy_reg(hw, data->reg_num & 0x1F,
-				   &data->val_out)) {
+				       &data->val_out)) {
 			spin_unlock_irqrestore(&adapter->stats_lock, flags);
 			return -EIO;
 		}
diff --git a/drivers/net/ethernet/intel/e1000/e1000_param.c b/drivers/net/ethernet/intel/e1000/e1000_param.c
index c9cde35..3d9a61f 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_param.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_param.c
@@ -250,7 +250,7 @@ static int e1000_validate_option(unsigned int *value,
 	}
 
 	e_dev_info("Invalid %s value specified (%i) %s\n",
-	       opt->name, *value, opt->err);
+		   opt->name, *value, opt->err);
 	*value = opt->def;
 	return -1;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 33cd8b6..c117504 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -519,7 +519,7 @@ static inline struct i40e_pf *i40e_netdev_to_pf(struct net_device *netdev)
 }
 
 static inline void i40e_vsi_setup_irqhandler(struct i40e_vsi *vsi,
-				irqreturn_t (*irq_handler)(int, void *))
+					     irqreturn_t (*irq_handler)(int, void *))
 {
 	vsi->irq_handler = irq_handler;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index ed3902b..3645477 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -143,7 +143,8 @@ static i40e_status i40e_alloc_arq_bufs(struct i40e_hw *hw)
 
 	/* buffer_info structures do not need alignment */
 	ret_code = i40e_allocate_virt_mem(hw, &hw->aq.arq.dma_head,
-		(hw->aq.num_arq_entries * sizeof(struct i40e_dma_mem)));
+					  hw->aq.num_arq_entries *
+					  sizeof(struct i40e_dma_mem));
 	if (ret_code)
 		goto alloc_arq_bufs;
 	hw->aq.arq.r.arq_bi = (struct i40e_dma_mem *)hw->aq.arq.dma_head.va;
@@ -205,7 +206,8 @@ static i40e_status i40e_alloc_asq_bufs(struct i40e_hw *hw)
 
 	/* No mapped memory needed yet, just the buffer info structures */
 	ret_code = i40e_allocate_virt_mem(hw, &hw->aq.asq.dma_head,
-		(hw->aq.num_asq_entries * sizeof(struct i40e_dma_mem)));
+					  hw->aq.num_asq_entries *
+					  sizeof(struct i40e_dma_mem));
 	if (ret_code)
 		goto alloc_asq_bufs;
 	hw->aq.asq.r.asq_bi = (struct i40e_dma_mem *)hw->aq.asq.dma_head.va;
@@ -286,17 +288,17 @@ static void i40e_config_asq_regs(struct i40e_hw *hw)
 	if (hw->mac.type == I40E_MAC_VF) {
 		/* configure the transmit queue */
 		wr32(hw, I40E_VF_ATQBAH1,
-		    upper_32_bits(hw->aq.asq.desc_buf.pa));
+		     upper_32_bits(hw->aq.asq.desc_buf.pa));
 		wr32(hw, I40E_VF_ATQBAL1,
-		    lower_32_bits(hw->aq.asq.desc_buf.pa));
+		     lower_32_bits(hw->aq.asq.desc_buf.pa));
 		wr32(hw, I40E_VF_ATQLEN1, (hw->aq.num_asq_entries |
 					  I40E_VF_ATQLEN1_ATQENABLE_MASK));
 	} else {
 		/* configure the transmit queue */
 		wr32(hw, I40E_PF_ATQBAH,
-		    upper_32_bits(hw->aq.asq.desc_buf.pa));
+		     upper_32_bits(hw->aq.asq.desc_buf.pa));
 		wr32(hw, I40E_PF_ATQBAL,
-		    lower_32_bits(hw->aq.asq.desc_buf.pa));
+		     lower_32_bits(hw->aq.asq.desc_buf.pa));
 		wr32(hw, I40E_PF_ATQLEN, (hw->aq.num_asq_entries |
 					  I40E_PF_ATQLEN_ATQENABLE_MASK));
 	}
@@ -313,17 +315,17 @@ static void i40e_config_arq_regs(struct i40e_hw *hw)
 	if (hw->mac.type == I40E_MAC_VF) {
 		/* configure the receive queue */
 		wr32(hw, I40E_VF_ARQBAH1,
-		    upper_32_bits(hw->aq.arq.desc_buf.pa));
+		     upper_32_bits(hw->aq.arq.desc_buf.pa));
 		wr32(hw, I40E_VF_ARQBAL1,
-		    lower_32_bits(hw->aq.arq.desc_buf.pa));
+		     lower_32_bits(hw->aq.arq.desc_buf.pa));
 		wr32(hw, I40E_VF_ARQLEN1, (hw->aq.num_arq_entries |
 					  I40E_VF_ARQLEN1_ARQENABLE_MASK));
 	} else {
 		/* configure the receive queue */
 		wr32(hw, I40E_PF_ARQBAH,
-		    upper_32_bits(hw->aq.arq.desc_buf.pa));
+		     upper_32_bits(hw->aq.arq.desc_buf.pa));
 		wr32(hw, I40E_PF_ARQBAL,
-		    lower_32_bits(hw->aq.arq.desc_buf.pa));
+		     lower_32_bits(hw->aq.arq.desc_buf.pa));
 		wr32(hw, I40E_PF_ARQLEN, (hw->aq.num_arq_entries |
 					  I40E_PF_ARQLEN_ARQENABLE_MASK));
 	}
@@ -689,10 +691,10 @@ static bool i40e_asq_done(struct i40e_hw *hw)
  *  queue.  It runs the queue, cleans the queue, etc
  **/
 i40e_status i40e_asq_send_command(struct i40e_hw *hw,
-				struct i40e_aq_desc *desc,
-				void *buff, /* can be NULL */
-				u16  buff_size,
-				struct i40e_asq_cmd_details *cmd_details)
+				  struct i40e_aq_desc *desc,
+				  void *buff, /* can be NULL */
+				  u16  buff_size,
+				  struct i40e_asq_cmd_details *cmd_details)
 {
 	i40e_status status = 0;
 	struct i40e_dma_mem *dma_buff = NULL;
@@ -877,8 +879,8 @@ void i40e_fill_default_direct_cmd_desc(struct i40e_aq_desc *desc,
  *  left to process through 'pending'
  **/
 i40e_status i40e_clean_arq_element(struct i40e_hw *hw,
-					     struct i40e_arq_event_info *e,
-					     u16 *pending)
+				   struct i40e_arq_event_info *e,
+				   u16 *pending)
 {
 	i40e_status ret_code = 0;
 	u16 ntc = hw->aq.arq.next_to_clean;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_alloc.h b/drivers/net/ethernet/intel/i40e/i40e_alloc.h
index 926811a..cb1e2c5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_alloc.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_alloc.h
@@ -44,15 +44,14 @@ enum i40e_memory_type {
 
 /* prototype for functions used for dynamic memory allocation */
 i40e_status i40e_allocate_dma_mem(struct i40e_hw *hw,
-					    struct i40e_dma_mem *mem,
-					    enum i40e_memory_type type,
-					    u64 size, u32 alignment);
+				  struct i40e_dma_mem *mem,
+				  enum i40e_memory_type type,
+				  u64 size, u32 alignment);
 i40e_status i40e_free_dma_mem(struct i40e_hw *hw,
-					struct i40e_dma_mem *mem);
+			      struct i40e_dma_mem *mem);
 i40e_status i40e_allocate_virt_mem(struct i40e_hw *hw,
-					     struct i40e_virt_mem *mem,
-					     u32 size);
+				   struct i40e_virt_mem *mem, u32 size);
 i40e_status i40e_free_virt_mem(struct i40e_hw *hw,
-					 struct i40e_virt_mem *mem);
+			       struct i40e_virt_mem *mem);
 
 #endif /* _I40E_ALLOC_H_ */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index bb948dd..43d8d71 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -67,7 +67,7 @@ static i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 	}
 
 	hw_dbg(hw, "i40e_set_mac_type found mac: %d, returns: %d\n",
-		  hw->mac.type, status);
+	       hw->mac.type, status);
 	return status;
 }
 
@@ -144,8 +144,7 @@ bool i40e_check_asq_alive(struct i40e_hw *hw)
  * Tell the Firmware that we're shutting down the AdminQ and whether
  * or not the driver is unloading as well.
  **/
-i40e_status i40e_aq_queue_shutdown(struct i40e_hw *hw,
-					     bool unloading)
+i40e_status i40e_aq_queue_shutdown(struct i40e_hw *hw, bool unloading)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_queue_shutdown *cmd =
@@ -582,9 +581,9 @@ i40e_status i40e_init_shared_code(struct i40e_hw *hw)
  * @cmd_details: pointer to command details structure or NULL
  **/
 static i40e_status i40e_aq_mac_address_read(struct i40e_hw *hw,
-				   u16 *flags,
-				   struct i40e_aqc_mac_address_read_data *addrs,
-				   struct i40e_asq_cmd_details *cmd_details)
+					    u16 *flags,
+					    struct i40e_aqc_mac_address_read_data *addrs,
+					    struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_mac_address_read *cmd_data =
@@ -609,8 +608,8 @@ static i40e_status i40e_aq_mac_address_read(struct i40e_hw *hw,
  * @cmd_details: pointer to command details structure or NULL
  **/
 i40e_status i40e_aq_mac_address_write(struct i40e_hw *hw,
-				    u16 flags, u8 *mac_addr,
-				    struct i40e_asq_cmd_details *cmd_details)
+				      u16 flags, u8 *mac_addr,
+				      struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_mac_address_write *cmd_data =
@@ -914,7 +913,7 @@ void i40e_led_set(struct i40e_hw *hw, u32 mode, bool blink)
  * Sets up the link and restarts the Auto-Negotiation over the link.
  **/
 i40e_status i40e_aq_set_link_restart_an(struct i40e_hw *hw,
-				struct i40e_asq_cmd_details *cmd_details)
+					struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_set_link_restart_an *cmd =
@@ -941,8 +940,8 @@ i40e_status i40e_aq_set_link_restart_an(struct i40e_hw *hw,
  * Returns the link status of the adapter.
  **/
 i40e_status i40e_aq_get_link_info(struct i40e_hw *hw,
-				bool enable_lse, struct i40e_link_status *link,
-				struct i40e_asq_cmd_details *cmd_details)
+				  bool enable_lse, struct i40e_link_status *link,
+				  struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_get_link_status *resp =
@@ -1001,8 +1000,8 @@ aq_get_link_info_exit:
  * Add a VSI context to the hardware.
 **/
 i40e_status i40e_aq_add_vsi(struct i40e_hw *hw,
-				struct i40e_vsi_context *vsi_ctx,
-				struct i40e_asq_cmd_details *cmd_details)
+			    struct i40e_vsi_context *vsi_ctx,
+			    struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_add_get_update_vsi *cmd =
@@ -1025,7 +1024,7 @@ i40e_status i40e_aq_add_vsi(struct i40e_hw *hw,
 		desc.flags |= cpu_to_le16((u16)I40E_AQ_FLAG_LB);
 
 	status = i40e_asq_send_command(hw, &desc, &vsi_ctx->info,
-				    sizeof(vsi_ctx->info), cmd_details);
+				       sizeof(vsi_ctx->info), cmd_details);
 
 	if (status)
 		goto aq_add_vsi_exit;
@@ -1047,8 +1046,8 @@ aq_add_vsi_exit:
  * @cmd_details: pointer to command details structure or NULL
  **/
 i40e_status i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw,
-				u16 seid, bool set,
-				struct i40e_asq_cmd_details *cmd_details)
+						u16 seid, bool set,
+						struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_set_vsi_promiscuous_modes *cmd =
@@ -1057,7 +1056,7 @@ i40e_status i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw,
 	u16 flags = 0;
 
 	i40e_fill_default_direct_cmd_desc(&desc,
-					i40e_aqc_opc_set_vsi_promiscuous_modes);
+					  i40e_aqc_opc_set_vsi_promiscuous_modes);
 
 	if (set)
 		flags |= I40E_AQC_SET_VSI_PROMISC_UNICAST;
@@ -1080,7 +1079,8 @@ i40e_status i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw,
  * @cmd_details: pointer to command details structure or NULL
  **/
 i40e_status i40e_aq_set_vsi_multicast_promiscuous(struct i40e_hw *hw,
-				u16 seid, bool set, struct i40e_asq_cmd_details *cmd_details)
+						  u16 seid, bool set,
+						  struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_set_vsi_promiscuous_modes *cmd =
@@ -1089,7 +1089,7 @@ i40e_status i40e_aq_set_vsi_multicast_promiscuous(struct i40e_hw *hw,
 	u16 flags = 0;
 
 	i40e_fill_default_direct_cmd_desc(&desc,
-					i40e_aqc_opc_set_vsi_promiscuous_modes);
+					  i40e_aqc_opc_set_vsi_promiscuous_modes);
 
 	if (set)
 		flags |= I40E_AQC_SET_VSI_PROMISC_MULTICAST;
@@ -1114,8 +1114,8 @@ i40e_status i40e_aq_set_vsi_multicast_promiscuous(struct i40e_hw *hw,
  * Set or clear the broadcast promiscuous flag (filter) for a given VSI.
  **/
 i40e_status i40e_aq_set_vsi_broadcast(struct i40e_hw *hw,
-				u16 seid, bool set_filter,
-				struct i40e_asq_cmd_details *cmd_details)
+				      u16 seid, bool set_filter,
+				      struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_set_vsi_promiscuous_modes *cmd =
@@ -1123,7 +1123,7 @@ i40e_status i40e_aq_set_vsi_broadcast(struct i40e_hw *hw,
 	i40e_status status;
 
 	i40e_fill_default_direct_cmd_desc(&desc,
-					i40e_aqc_opc_set_vsi_promiscuous_modes);
+					  i40e_aqc_opc_set_vsi_promiscuous_modes);
 
 	if (set_filter)
 		cmd->promiscuous_flags
@@ -1146,8 +1146,8 @@ i40e_status i40e_aq_set_vsi_broadcast(struct i40e_hw *hw,
  * @cmd_details: pointer to command details structure or NULL
  **/
 i40e_status i40e_aq_get_vsi_params(struct i40e_hw *hw,
-				struct i40e_vsi_context *vsi_ctx,
-				struct i40e_asq_cmd_details *cmd_details)
+				   struct i40e_vsi_context *vsi_ctx,
+				   struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_add_get_update_vsi *cmd =
@@ -1167,7 +1167,7 @@ i40e_status i40e_aq_get_vsi_params(struct i40e_hw *hw,
 		desc.flags |= cpu_to_le16((u16)I40E_AQ_FLAG_LB);
 
 	status = i40e_asq_send_command(hw, &desc, &vsi_ctx->info,
-				    sizeof(vsi_ctx->info), NULL);
+				       sizeof(vsi_ctx->info), NULL);
 
 	if (status)
 		goto aq_get_vsi_params_exit;
@@ -1190,8 +1190,8 @@ aq_get_vsi_params_exit:
  * Update a VSI context.
  **/
 i40e_status i40e_aq_update_vsi_params(struct i40e_hw *hw,
-				struct i40e_vsi_context *vsi_ctx,
-				struct i40e_asq_cmd_details *cmd_details)
+				      struct i40e_vsi_context *vsi_ctx,
+				      struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_add_get_update_vsi *cmd =
@@ -1207,7 +1207,7 @@ i40e_status i40e_aq_update_vsi_params(struct i40e_hw *hw,
 		desc.flags |= cpu_to_le16((u16)I40E_AQ_FLAG_LB);
 
 	status = i40e_asq_send_command(hw, &desc, &vsi_ctx->info,
-				    sizeof(vsi_ctx->info), cmd_details);
+				       sizeof(vsi_ctx->info), cmd_details);
 
 	return status;
 }
@@ -1223,9 +1223,9 @@ i40e_status i40e_aq_update_vsi_params(struct i40e_hw *hw,
  * Fill the buf with switch configuration returned from AdminQ command
  **/
 i40e_status i40e_aq_get_switch_config(struct i40e_hw *hw,
-				struct i40e_aqc_get_switch_config_resp *buf,
-				u16 buf_size, u16 *start_seid,
-				struct i40e_asq_cmd_details *cmd_details)
+				      struct i40e_aqc_get_switch_config_resp *buf,
+				      u16 buf_size, u16 *start_seid,
+				      struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_switch_seid *scfg =
@@ -1257,9 +1257,9 @@ i40e_status i40e_aq_get_switch_config(struct i40e_hw *hw,
  * Get the firmware version from the admin queue commands
  **/
 i40e_status i40e_aq_get_firmware_version(struct i40e_hw *hw,
-				u16 *fw_major_version, u16 *fw_minor_version,
-				u16 *api_major_version, u16 *api_minor_version,
-				struct i40e_asq_cmd_details *cmd_details)
+					 u16 *fw_major_version, u16 *fw_minor_version,
+					 u16 *api_major_version, u16 *api_minor_version,
+					 struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_get_version *resp =
@@ -1293,8 +1293,8 @@ i40e_status i40e_aq_get_firmware_version(struct i40e_hw *hw,
  * Send the driver version to the firmware
  **/
 i40e_status i40e_aq_send_driver_version(struct i40e_hw *hw,
-				struct i40e_driver_version *dv,
-				struct i40e_asq_cmd_details *cmd_details)
+					struct i40e_driver_version *dv,
+					struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_driver_version *cmd =
@@ -1357,10 +1357,10 @@ i40e_get_link_status_exit:
  * elements.  If the uplink SEID is 0, this will be a floating VEB.
  **/
 i40e_status i40e_aq_add_veb(struct i40e_hw *hw, u16 uplink_seid,
-				u16 downlink_seid, u8 enabled_tc,
-				bool default_port, bool enable_l2_filtering,
-				u16 *veb_seid,
-				struct i40e_asq_cmd_details *cmd_details)
+			    u16 downlink_seid, u8 enabled_tc,
+			    bool default_port, bool enable_l2_filtering,
+			    u16 *veb_seid,
+			    struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_add_veb *cmd =
@@ -1414,10 +1414,10 @@ i40e_status i40e_aq_add_veb(struct i40e_hw *hw, u16 uplink_seid,
  * uplink_seid, and returns them to the caller.
  **/
 i40e_status i40e_aq_get_veb_parameters(struct i40e_hw *hw,
-				u16 veb_seid, u16 *switch_id,
-				bool *floating, u16 *statistic_index,
-				u16 *vebs_used, u16 *vebs_free,
-				struct i40e_asq_cmd_details *cmd_details)
+				       u16 veb_seid, u16 *switch_id,
+				       bool *floating, u16 *statistic_index,
+				       u16 *vebs_used, u16 *vebs_free,
+				       struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_get_veb_parameters_completion *cmd_resp =
@@ -1467,8 +1467,8 @@ get_veb_exit:
  * Add MAC/VLAN addresses to the HW filtering
  **/
 i40e_status i40e_aq_add_macvlan(struct i40e_hw *hw, u16 seid,
-			struct i40e_aqc_add_macvlan_element_data *mv_list,
-			u16 count, struct i40e_asq_cmd_details *cmd_details)
+				struct i40e_aqc_add_macvlan_element_data *mv_list,
+				u16 count, struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_macvlan *cmd =
@@ -1493,7 +1493,7 @@ i40e_status i40e_aq_add_macvlan(struct i40e_hw *hw, u16 seid,
 		desc.flags |= cpu_to_le16((u16)I40E_AQ_FLAG_LB);
 
 	status = i40e_asq_send_command(hw, &desc, mv_list, buf_size,
-				    cmd_details);
+				       cmd_details);
 
 	return status;
 }
@@ -1509,8 +1509,8 @@ i40e_status i40e_aq_add_macvlan(struct i40e_hw *hw, u16 seid,
  * Remove MAC/VLAN addresses from the HW filtering
  **/
 i40e_status i40e_aq_remove_macvlan(struct i40e_hw *hw, u16 seid,
-			struct i40e_aqc_remove_macvlan_element_data *mv_list,
-			u16 count, struct i40e_asq_cmd_details *cmd_details)
+				   struct i40e_aqc_remove_macvlan_element_data *mv_list,
+				   u16 count, struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_macvlan *cmd =
@@ -1553,8 +1553,8 @@ i40e_status i40e_aq_remove_macvlan(struct i40e_hw *hw, u16 seid,
  * send msg to vf
  **/
 i40e_status i40e_aq_send_msg_to_vf(struct i40e_hw *hw, u16 vfid,
-				u32 v_opcode, u32 v_retval, u8 *msg, u16 msglen,
-				struct i40e_asq_cmd_details *cmd_details)
+				   u32 v_opcode, u32 v_retval, u8 *msg, u16 msglen,
+				   struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_pf_vf_message *cmd =
@@ -1588,9 +1588,9 @@ i40e_status i40e_aq_send_msg_to_vf(struct i40e_hw *hw, u16 vfid,
  * set the HMC profile of the device.
  **/
 i40e_status i40e_aq_set_hmc_resource_profile(struct i40e_hw *hw,
-				enum i40e_aq_hmc_profile profile,
-				u8 pe_vf_enabled_count,
-				struct i40e_asq_cmd_details *cmd_details)
+					     enum i40e_aq_hmc_profile profile,
+					     u8 pe_vf_enabled_count,
+					     struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aq_get_set_hmc_resource_profile *cmd =
@@ -1598,7 +1598,7 @@ i40e_status i40e_aq_set_hmc_resource_profile(struct i40e_hw *hw,
 	i40e_status status;
 
 	i40e_fill_default_direct_cmd_desc(&desc,
-					i40e_aqc_opc_set_hmc_resource_profile);
+					  i40e_aqc_opc_set_hmc_resource_profile);
 
 	cmd->pm_profile = (u8)profile;
 	cmd->pe_vf_enabled = pe_vf_enabled_count;
@@ -1620,10 +1620,10 @@ i40e_status i40e_aq_set_hmc_resource_profile(struct i40e_hw *hw,
  * requests common resource using the admin queue commands
  **/
 i40e_status i40e_aq_request_resource(struct i40e_hw *hw,
-				enum i40e_aq_resources_ids resource,
-				enum i40e_aq_resource_access_type access,
-				u8 sdp_number, u64 *timeout,
-				struct i40e_asq_cmd_details *cmd_details)
+				     enum i40e_aq_resources_ids resource,
+				     enum i40e_aq_resource_access_type access,
+				     u8 sdp_number, u64 *timeout,
+				     struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_request_resource *cmd_resp =
@@ -1659,9 +1659,9 @@ i40e_status i40e_aq_request_resource(struct i40e_hw *hw,
  * release common resource using the admin queue commands
  **/
 i40e_status i40e_aq_release_resource(struct i40e_hw *hw,
-				enum i40e_aq_resources_ids resource,
-				u8 sdp_number,
-				struct i40e_asq_cmd_details *cmd_details)
+				     enum i40e_aq_resources_ids resource,
+				     u8 sdp_number,
+				     struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_request_resource *cmd =
@@ -1691,9 +1691,9 @@ i40e_status i40e_aq_release_resource(struct i40e_hw *hw,
  * Read the NVM using the admin queue commands
  **/
 i40e_status i40e_aq_read_nvm(struct i40e_hw *hw, u8 module_pointer,
-				u32 offset, u16 length, void *data,
-				bool last_command,
-				struct i40e_asq_cmd_details *cmd_details)
+			     u32 offset, u16 length, void *data,
+			     bool last_command,
+			     struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_nvm_update *cmd =
@@ -1762,8 +1762,8 @@ i40e_aq_read_nvm_exit:
  * Parse the device/function capabilities list.
  **/
 static void i40e_parse_discover_capabilities(struct i40e_hw *hw, void *buff,
-				     u32 cap_count,
-				     enum i40e_admin_queue_opc list_type_opc)
+					     u32 cap_count,
+					     enum i40e_admin_queue_opc list_type_opc)
 {
 	struct i40e_aqc_list_capabilities_element_resp *cap;
 	u32 number, logical_id, phys_id;
@@ -1918,9 +1918,9 @@ static void i40e_parse_discover_capabilities(struct i40e_hw *hw, void *buff,
  * Get the device capabilities descriptions from the firmware
  **/
 i40e_status i40e_aq_discover_capabilities(struct i40e_hw *hw,
-				void *buff, u16 buff_size, u16 *data_size,
-				enum i40e_admin_queue_opc list_type_opc,
-				struct i40e_asq_cmd_details *cmd_details)
+					  void *buff, u16 buff_size, u16 *data_size,
+					  enum i40e_admin_queue_opc list_type_opc,
+					  struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aqc_list_capabilites *cmd;
 	struct i40e_aq_desc desc;
@@ -1929,7 +1929,7 @@ i40e_status i40e_aq_discover_capabilities(struct i40e_hw *hw,
 	cmd = (struct i40e_aqc_list_capabilites *)&desc.params.raw;
 
 	if (list_type_opc != i40e_aqc_opc_list_func_capabilities &&
-		list_type_opc != i40e_aqc_opc_list_dev_capabilities) {
+	    list_type_opc != i40e_aqc_opc_list_dev_capabilities) {
 		status = I40E_ERR_PARAM;
 		goto exit;
 	}
@@ -1967,9 +1967,9 @@ exit:
  * Requests the complete LLDP MIB (entire packet).
  **/
 i40e_status i40e_aq_get_lldp_mib(struct i40e_hw *hw, u8 bridge_type,
-				u8 mib_type, void *buff, u16 buff_size,
-				u16 *local_len, u16 *remote_len,
-				struct i40e_asq_cmd_details *cmd_details)
+				 u8 mib_type, void *buff, u16 buff_size,
+				 u16 *local_len, u16 *remote_len,
+				 struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_lldp_get_mib *cmd =
@@ -2016,8 +2016,8 @@ i40e_status i40e_aq_get_lldp_mib(struct i40e_hw *hw, u8 bridge_type,
  * associated with the interface changes
  **/
 i40e_status i40e_aq_cfg_lldp_mib_change_event(struct i40e_hw *hw,
-				bool enable_update,
-				struct i40e_asq_cmd_details *cmd_details)
+					      bool enable_update,
+					      struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_lldp_update_mib *cmd =
@@ -2043,7 +2043,7 @@ i40e_status i40e_aq_cfg_lldp_mib_change_event(struct i40e_hw *hw,
  * Stop or Shutdown the embedded LLDP Agent
  **/
 i40e_status i40e_aq_stop_lldp(struct i40e_hw *hw, bool shutdown_agent,
-				struct i40e_asq_cmd_details *cmd_details)
+			      struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_lldp_stop *cmd =
@@ -2068,7 +2068,7 @@ i40e_status i40e_aq_stop_lldp(struct i40e_hw *hw, bool shutdown_agent,
  * Start the embedded LLDP Agent on all ports.
  **/
 i40e_status i40e_aq_start_lldp(struct i40e_hw *hw,
-				struct i40e_asq_cmd_details *cmd_details)
+			       struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_lldp_start *cmd =
@@ -2094,9 +2094,9 @@ i40e_status i40e_aq_start_lldp(struct i40e_hw *hw,
  * @cmd_details: pointer to command details structure or NULL
  **/
 i40e_status i40e_aq_add_udp_tunnel(struct i40e_hw *hw,
-				u16 udp_port, u8 header_len,
-				u8 protocol_index, u8 *filter_index,
-				struct i40e_asq_cmd_details *cmd_details)
+				   u16 udp_port, u8 header_len,
+				   u8 protocol_index, u8 *filter_index,
+				   struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_add_udp_tunnel *cmd =
@@ -2125,7 +2125,7 @@ i40e_status i40e_aq_add_udp_tunnel(struct i40e_hw *hw,
  * @cmd_details: pointer to command details structure or NULL
  **/
 i40e_status i40e_aq_del_udp_tunnel(struct i40e_hw *hw, u8 index,
-				struct i40e_asq_cmd_details *cmd_details)
+				   struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_remove_udp_tunnel *cmd =
@@ -2150,7 +2150,7 @@ i40e_status i40e_aq_del_udp_tunnel(struct i40e_hw *hw, u8 index,
  * This deletes a switch element from the switch.
  **/
 i40e_status i40e_aq_delete_element(struct i40e_hw *hw, u16 seid,
-				struct i40e_asq_cmd_details *cmd_details)
+				   struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_switch_seid *cmd =
@@ -2203,9 +2203,9 @@ i40e_status i40e_aq_dcb_updated(struct i40e_hw *hw,
  * Generic command handler for Tx scheduler AQ commands
  **/
 static i40e_status i40e_aq_tx_sched_cmd(struct i40e_hw *hw, u16 seid,
-				void *buff, u16 buff_size,
-				 enum i40e_admin_queue_opc opcode,
-				struct i40e_asq_cmd_details *cmd_details)
+					void *buff, u16 buff_size,
+					enum i40e_admin_queue_opc opcode,
+					struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_tx_sched_ind *cmd =
@@ -2260,9 +2260,9 @@ static i40e_status i40e_aq_tx_sched_cmd(struct i40e_hw *hw, u16 seid,
  * @cmd_details: pointer to command details structure or NULL
  **/
 i40e_status i40e_aq_config_vsi_tc_bw(struct i40e_hw *hw,
-			u16 seid,
-			struct i40e_aqc_configure_vsi_tc_bw_data *bw_data,
-			struct i40e_asq_cmd_details *cmd_details)
+				     u16 seid,
+				     struct i40e_aqc_configure_vsi_tc_bw_data *bw_data,
+				     struct i40e_asq_cmd_details *cmd_details)
 {
 	return i40e_aq_tx_sched_cmd(hw, seid, (void *)bw_data, sizeof(*bw_data),
 				    i40e_aqc_opc_configure_vsi_tc_bw,
@@ -2277,10 +2277,10 @@ i40e_status i40e_aq_config_vsi_tc_bw(struct i40e_hw *hw,
  * @cmd_details: pointer to command details structure or NULL
  **/
 i40e_status i40e_aq_config_switch_comp_ets(struct i40e_hw *hw,
-		u16 seid,
-		struct i40e_aqc_configure_switching_comp_ets_data *ets_data,
-		enum i40e_admin_queue_opc opcode,
-		struct i40e_asq_cmd_details *cmd_details)
+					   u16 seid,
+					   struct i40e_aqc_configure_switching_comp_ets_data *ets_data,
+					   enum i40e_admin_queue_opc opcode,
+					   struct i40e_asq_cmd_details *cmd_details)
 {
 	return i40e_aq_tx_sched_cmd(hw, seid, (void *)ets_data,
 				    sizeof(*ets_data), opcode, cmd_details);
@@ -2294,9 +2294,9 @@ i40e_status i40e_aq_config_switch_comp_ets(struct i40e_hw *hw,
  * @cmd_details: pointer to command details structure or NULL
  **/
 i40e_status i40e_aq_config_switch_comp_bw_config(struct i40e_hw *hw,
-	u16 seid,
-	struct i40e_aqc_configure_switching_comp_bw_config_data *bw_data,
-	struct i40e_asq_cmd_details *cmd_details)
+						 u16 seid,
+						 struct i40e_aqc_configure_switching_comp_bw_config_data *bw_data,
+						 struct i40e_asq_cmd_details *cmd_details)
 {
 	return i40e_aq_tx_sched_cmd(hw, seid, (void *)bw_data, sizeof(*bw_data),
 			    i40e_aqc_opc_configure_switching_comp_bw_config,
@@ -2311,9 +2311,9 @@ i40e_status i40e_aq_config_switch_comp_bw_config(struct i40e_hw *hw,
  * @cmd_details: pointer to command details structure or NULL
  **/
 i40e_status i40e_aq_query_vsi_bw_config(struct i40e_hw *hw,
-			u16 seid,
-			struct i40e_aqc_query_vsi_bw_config_resp *bw_data,
-			struct i40e_asq_cmd_details *cmd_details)
+					u16 seid,
+					struct i40e_aqc_query_vsi_bw_config_resp *bw_data,
+					struct i40e_asq_cmd_details *cmd_details)
 {
 	return i40e_aq_tx_sched_cmd(hw, seid, (void *)bw_data, sizeof(*bw_data),
 				    i40e_aqc_opc_query_vsi_bw_config,
@@ -2328,9 +2328,9 @@ i40e_status i40e_aq_query_vsi_bw_config(struct i40e_hw *hw,
  * @cmd_details: pointer to command details structure or NULL
  **/
 i40e_status i40e_aq_query_vsi_ets_sla_config(struct i40e_hw *hw,
-			u16 seid,
-			struct i40e_aqc_query_vsi_ets_sla_config_resp *bw_data,
-			struct i40e_asq_cmd_details *cmd_details)
+					     u16 seid,
+					     struct i40e_aqc_query_vsi_ets_sla_config_resp *bw_data,
+					     struct i40e_asq_cmd_details *cmd_details)
 {
 	return i40e_aq_tx_sched_cmd(hw, seid, (void *)bw_data, sizeof(*bw_data),
 				    i40e_aqc_opc_query_vsi_ets_sla_config,
@@ -2345,9 +2345,9 @@ i40e_status i40e_aq_query_vsi_ets_sla_config(struct i40e_hw *hw,
  * @cmd_details: pointer to command details structure or NULL
  **/
 i40e_status i40e_aq_query_switch_comp_ets_config(struct i40e_hw *hw,
-		u16 seid,
-		struct i40e_aqc_query_switching_comp_ets_config_resp *bw_data,
-		struct i40e_asq_cmd_details *cmd_details)
+						 u16 seid,
+						 struct i40e_aqc_query_switching_comp_ets_config_resp *bw_data,
+						 struct i40e_asq_cmd_details *cmd_details)
 {
 	return i40e_aq_tx_sched_cmd(hw, seid, (void *)bw_data, sizeof(*bw_data),
 				   i40e_aqc_opc_query_switching_comp_ets_config,
@@ -2362,9 +2362,9 @@ i40e_status i40e_aq_query_switch_comp_ets_config(struct i40e_hw *hw,
  * @cmd_details: pointer to command details structure or NULL
  **/
 i40e_status i40e_aq_query_port_ets_config(struct i40e_hw *hw,
-			u16 seid,
-			struct i40e_aqc_query_port_ets_config_resp *bw_data,
-			struct i40e_asq_cmd_details *cmd_details)
+					  u16 seid,
+					  struct i40e_aqc_query_port_ets_config_resp *bw_data,
+					  struct i40e_asq_cmd_details *cmd_details)
 {
 	return i40e_aq_tx_sched_cmd(hw, seid, (void *)bw_data, sizeof(*bw_data),
 				    i40e_aqc_opc_query_port_ets_config,
@@ -2379,9 +2379,9 @@ i40e_status i40e_aq_query_port_ets_config(struct i40e_hw *hw,
  * @cmd_details: pointer to command details structure or NULL
  **/
 i40e_status i40e_aq_query_switch_comp_bw_config(struct i40e_hw *hw,
-		u16 seid,
-		struct i40e_aqc_query_switching_comp_bw_config_resp *bw_data,
-		struct i40e_asq_cmd_details *cmd_details)
+						u16 seid,
+						struct i40e_aqc_query_switching_comp_bw_config_resp *bw_data,
+						struct i40e_asq_cmd_details *cmd_details)
 {
 	return i40e_aq_tx_sched_cmd(hw, seid, (void *)bw_data, sizeof(*bw_data),
 				    i40e_aqc_opc_query_switching_comp_bw_config,
@@ -2401,7 +2401,7 @@ i40e_status i40e_aq_query_switch_comp_bw_config(struct i40e_hw *hw,
  * range else returns an error.
  **/
 static i40e_status i40e_validate_filter_settings(struct i40e_hw *hw,
-				struct i40e_filter_control_settings *settings)
+						 struct i40e_filter_control_settings *settings)
 {
 	u32 fcoe_cntx_size, fcoe_filt_size;
 	u32 pe_cntx_size, pe_filt_size;
@@ -2500,7 +2500,7 @@ static i40e_status i40e_validate_filter_settings(struct i40e_hw *hw,
  * at the driver initialization time.
  **/
 i40e_status i40e_set_filter_control(struct i40e_hw *hw,
-				struct i40e_filter_control_settings *settings)
+				    struct i40e_filter_control_settings *settings)
 {
 	i40e_status ret = 0;
 	u32 hash_lut_size = 0;
@@ -2574,10 +2574,10 @@ i40e_status i40e_set_filter_control(struct i40e_hw *hw,
  * the stats member.
  **/
 i40e_status i40e_aq_add_rem_control_packet_filter(struct i40e_hw *hw,
-				u8 *mac_addr, u16 ethtype, u16 flags,
-				u16 vsi_seid, u16 queue, bool is_add,
-				struct i40e_control_filter_stats *stats,
-				struct i40e_asq_cmd_details *cmd_details)
+						  u8 *mac_addr, u16 ethtype, u16 flags,
+						  u16 vsi_seid, u16 queue, bool is_add,
+						  struct i40e_control_filter_stats *stats,
+						  struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_add_remove_control_packet_filter *cmd =
@@ -2593,11 +2593,11 @@ i40e_status i40e_aq_add_rem_control_packet_filter(struct i40e_hw *hw,
 
 	if (is_add) {
 		i40e_fill_default_direct_cmd_desc(&desc,
-				i40e_aqc_opc_add_control_packet_filter);
+						  i40e_aqc_opc_add_control_packet_filter);
 		cmd->queue = cpu_to_le16(queue);
 	} else {
 		i40e_fill_default_direct_cmd_desc(&desc,
-				i40e_aqc_opc_remove_control_packet_filter);
+						  i40e_aqc_opc_remove_control_packet_filter);
 	}
 
 	if (mac_addr)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb.h b/drivers/net/ethernet/intel/i40e/i40e_dcb.h
index 34cf1c3..affd8ee 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb.h
@@ -95,13 +95,12 @@ struct i40e_lldp_org_tlv {
 };
 #pragma pack()
 
-i40e_status i40e_get_dcbx_status(struct i40e_hw *hw,
-					   u16 *status);
+i40e_status i40e_get_dcbx_status(struct i40e_hw *hw, u16 *status);
 i40e_status i40e_lldp_to_dcb_config(u8 *lldpmib,
-					      struct i40e_dcbx_config *dcbcfg);
+				    struct i40e_dcbx_config *dcbcfg);
 i40e_status i40e_aq_get_dcb_config(struct i40e_hw *hw, u8 mib_type,
-					     u8 bridgetype,
-					     struct i40e_dcbx_config *dcbcfg);
+				   u8 bridgetype,
+				   struct i40e_dcbx_config *dcbcfg);
 i40e_status i40e_get_dcb_config(struct i40e_hw *hw);
 i40e_status i40e_init_dcb(struct i40e_hw *hw);
 #endif /* _I40E_DCB_H_ */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c b/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c
index 6e8103a..39e14a6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_dcb_nl.c
@@ -66,19 +66,19 @@ static int i40e_dcbnl_ieee_getets(struct net_device *dev,
 	ets->ets_cap = dcbxcfg->etscfg.maxtcs;
 	ets->cbs = dcbxcfg->etscfg.cbs;
 	memcpy(ets->tc_tx_bw, dcbxcfg->etscfg.tcbwtable,
-		sizeof(ets->tc_tx_bw));
+	       sizeof(ets->tc_tx_bw));
 	memcpy(ets->tc_rx_bw, dcbxcfg->etscfg.tcbwtable,
-		sizeof(ets->tc_rx_bw));
+	       sizeof(ets->tc_rx_bw));
 	memcpy(ets->tc_tsa, dcbxcfg->etscfg.tsatable,
-		sizeof(ets->tc_tsa));
+	       sizeof(ets->tc_tsa));
 	memcpy(ets->prio_tc, dcbxcfg->etscfg.prioritytable,
-		sizeof(ets->prio_tc));
+	       sizeof(ets->prio_tc));
 	memcpy(ets->tc_reco_bw, dcbxcfg->etsrec.tcbwtable,
-		sizeof(ets->tc_reco_bw));
+	       sizeof(ets->tc_reco_bw));
 	memcpy(ets->tc_reco_tsa, dcbxcfg->etsrec.tsatable,
-		sizeof(ets->tc_reco_tsa));
+	       sizeof(ets->tc_reco_tsa));
 	memcpy(ets->reco_prio_tc, dcbxcfg->etscfg.prioritytable,
-		sizeof(ets->reco_prio_tc));
+	       sizeof(ets->reco_prio_tc));
 
 	return 0;
 }
@@ -229,7 +229,7 @@ static int i40e_dcbnl_vsi_del_app(struct i40e_vsi *vsi,
  * Delete given APP from all the VSIs for given PF
  **/
 static void i40e_dcbnl_del_app(struct i40e_pf *pf,
-			      struct i40e_ieee_app_priority_table *app)
+			       struct i40e_ieee_app_priority_table *app)
 {
 	int v, err;
 	for (v = 0; v < pf->hw.func_caps.num_vsis; v++) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index afd43d7..d09e0bd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1759,14 +1759,14 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 				goto command_write_done;
 			}
 			ret = i40e_aq_add_rem_control_packet_filter(&pf->hw,
-						pf->hw.mac.addr,
-						I40E_ETH_P_LLDP, 0,
-						pf->vsi[pf->lan_vsi]->seid,
-						0, true, NULL, NULL);
+								    pf->hw.mac.addr,
+								    I40E_ETH_P_LLDP, 0,
+								    pf->vsi[pf->lan_vsi]->seid,
+								    0, true, NULL, NULL);
 			if (ret) {
 				dev_info(&pf->pdev->dev,
-					"%s: Add Control Packet Filter AQ command failed =0x%x\n",
-					__func__, pf->hw.aq.asq_last_status);
+					 "%s: Add Control Packet Filter AQ command failed =0x%x\n",
+					 __func__, pf->hw.aq.asq_last_status);
 				goto command_write_done;
 			}
 #ifdef CONFIG_I40E_DCB
@@ -1776,14 +1776,14 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		} else if (strncmp(&cmd_buf[5], "start", 5) == 0) {
 			int ret;
 			ret = i40e_aq_add_rem_control_packet_filter(&pf->hw,
-						pf->hw.mac.addr,
-						I40E_ETH_P_LLDP, 0,
-						pf->vsi[pf->lan_vsi]->seid,
-						0, false, NULL, NULL);
+								    pf->hw.mac.addr,
+								    I40E_ETH_P_LLDP, 0,
+								    pf->vsi[pf->lan_vsi]->seid,
+								    0, false, NULL, NULL);
 			if (ret) {
 				dev_info(&pf->pdev->dev,
-					"%s: Remove Control Packet Filter AQ command failed =0x%x\n",
-					__func__, pf->hw.aq.asq_last_status);
+					 "%s: Remove Control Packet Filter AQ command failed =0x%x\n",
+					 __func__, pf->hw.aq.asq_last_status);
 				/* Continue and start FW LLDP anyways */
 			}
 
@@ -1834,10 +1834,10 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 				goto command_write_done;
 
 			ret = i40e_aq_get_lldp_mib(&pf->hw,
-					I40E_AQ_LLDP_BRIDGE_TYPE_NEAREST_BRIDGE,
-					I40E_AQ_LLDP_MIB_LOCAL,
-					buff, I40E_LLDPDU_SIZE,
-					&llen, &rlen, NULL);
+						   I40E_AQ_LLDP_BRIDGE_TYPE_NEAREST_BRIDGE,
+						   I40E_AQ_LLDP_MIB_LOCAL,
+						   buff, I40E_LLDPDU_SIZE,
+						   &llen, &rlen, NULL);
 			if (ret) {
 				dev_info(&pf->pdev->dev,
 					 "Get LLDP MIB (remote) AQ command failed =0x%x\n",
@@ -1930,8 +1930,8 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 				 module, offset, buffer_len);
 			if (bytes)
 				print_hex_dump(KERN_INFO, "NVM Dump: ",
-					DUMP_PREFIX_OFFSET, 16, 2,
-					buff, bytes, true);
+					       DUMP_PREFIX_OFFSET, 16, 2,
+					       buff, bytes, true);
 		}
 		kfree(buff);
 		buff = NULL;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_diag.c b/drivers/net/ethernet/intel/i40e/i40e_diag.c
index b2380da..cf0de2e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_diag.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_diag.c
@@ -34,7 +34,7 @@
  * @mask: bits to be touched
  **/
 static i40e_status i40e_diag_reg_pattern_test(struct i40e_hw *hw,
-							u32 reg, u32 mask)
+					      u32 reg, u32 mask)
 {
 	const u32 patterns[] = {0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
 	u32 pat, val, orig_val;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 28da412..c4d62d3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -394,10 +394,10 @@ static int i40e_get_eeprom(struct net_device *netdev,
 			last = true;
 		}
 		ret_val = i40e_aq_read_nvm(hw, 0x0,
-				eeprom->offset + (I40E_NVM_SECTOR_SIZE * i),
-				len,
-				(u8 *)eeprom_buff + (I40E_NVM_SECTOR_SIZE * i),
-				last, NULL);
+					   eeprom->offset + (I40E_NVM_SECTOR_SIZE * i),
+					   len,
+					   (u8 *)eeprom_buff + (I40E_NVM_SECTOR_SIZE * i),
+					   last, NULL);
 		if (ret_val) {
 			dev_info(&pf->pdev->dev,
 				 "read NVM failed err=%d status=0x%x\n",
@@ -1594,7 +1594,7 @@ static unsigned int i40e_max_channels(struct i40e_vsi *vsi)
  * q_vectors since we support a lot more queue pairs than q_vectors.
  **/
 static void i40e_get_channels(struct net_device *dev,
-			       struct ethtool_channels *ch)
+			      struct ethtool_channels *ch)
 {
 	struct i40e_netdev_priv *np = netdev_priv(dev);
 	struct i40e_vsi *vsi = np->vsi;
@@ -1620,7 +1620,7 @@ static void i40e_get_channels(struct net_device *dev,
  * since it gets rounded down to a power of 2 value.
  **/
 static int i40e_set_channels(struct net_device *dev,
-			      struct ethtool_channels *ch)
+			     struct ethtool_channels *ch)
 {
 	struct i40e_netdev_priv *np = netdev_priv(dev);
 	unsigned int count = ch->combined_count;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_hmc.c b/drivers/net/ethernet/intel/i40e/i40e_hmc.c
index bf2d4cc..e66d500 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_hmc.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_hmc.c
@@ -40,10 +40,10 @@
  * @direct_mode_sz: size to alloc in direct mode
  **/
 i40e_status i40e_add_sd_table_entry(struct i40e_hw *hw,
-					      struct i40e_hmc_info *hmc_info,
-					      u32 sd_index,
-					      enum i40e_sd_entry_type type,
-					      u64 direct_mode_sz)
+				    struct i40e_hmc_info *hmc_info,
+				    u32 sd_index,
+				    enum i40e_sd_entry_type type,
+				    u64 direct_mode_sz)
 {
 	enum i40e_memory_type mem_type __attribute__((unused));
 	struct i40e_hmc_sd_entry *sd_entry;
@@ -82,8 +82,8 @@ i40e_status i40e_add_sd_table_entry(struct i40e_hw *hw,
 		dma_mem_alloc_done = true;
 		if (I40E_SD_TYPE_PAGED == type) {
 			ret_code = i40e_allocate_virt_mem(hw,
-					&sd_entry->u.pd_table.pd_entry_virt_mem,
-					sizeof(struct i40e_hmc_pd_entry) * 512);
+							  &sd_entry->u.pd_table.pd_entry_virt_mem,
+							  sizeof(struct i40e_hmc_pd_entry) * 512);
 			if (ret_code)
 				goto exit;
 			sd_entry->u.pd_table.pd_entry =
@@ -128,8 +128,8 @@ exit:
  *	2. It should be 4K in size.
  **/
 i40e_status i40e_add_pd_table_entry(struct i40e_hw *hw,
-					      struct i40e_hmc_info *hmc_info,
-					      u32 pd_index)
+				    struct i40e_hmc_info *hmc_info,
+				    u32 pd_index)
 {
 	i40e_status ret_code = 0;
 	struct i40e_hmc_pd_table *pd_table;
@@ -200,8 +200,8 @@ exit:
  *	   function returns.
  **/
 i40e_status i40e_remove_pd_bp(struct i40e_hw *hw,
-					struct i40e_hmc_info *hmc_info,
-					u32 idx, bool is_pf)
+			      struct i40e_hmc_info *hmc_info,
+			      u32 idx, bool is_pf)
 {
 	i40e_status ret_code = 0;
 	struct i40e_hmc_pd_entry *pd_entry;
@@ -257,8 +257,7 @@ exit:
  * @hmc_info: pointer to the HMC configuration information structure
  * @idx: the page index
  **/
-i40e_status i40e_prep_remove_sd_bp(struct i40e_hmc_info *hmc_info,
-					     u32 idx)
+i40e_status i40e_prep_remove_sd_bp(struct i40e_hmc_info *hmc_info, u32 idx)
 {
 	i40e_status ret_code = 0;
 	struct i40e_hmc_sd_entry *sd_entry;
@@ -286,8 +285,8 @@ exit:
  * @is_pf: used to distinguish between VF and PF
  **/
 i40e_status i40e_remove_sd_bp_new(struct i40e_hw *hw,
-					    struct i40e_hmc_info *hmc_info,
-					    u32 idx, bool is_pf)
+				  struct i40e_hmc_info *hmc_info,
+				  u32 idx, bool is_pf)
 {
 	struct i40e_hmc_sd_entry *sd_entry;
 	i40e_status ret_code = 0;
@@ -312,8 +311,7 @@ exit:
  * @hmc_info: pointer to the HMC configuration information structure
  * @idx: segment descriptor index to find the relevant page descriptor
  **/
-i40e_status i40e_prep_remove_pd_page(struct i40e_hmc_info *hmc_info,
-					       u32 idx)
+i40e_status i40e_prep_remove_pd_page(struct i40e_hmc_info *hmc_info, u32 idx)
 {
 	i40e_status ret_code = 0;
 	struct i40e_hmc_sd_entry *sd_entry;
@@ -341,8 +339,8 @@ exit:
  * @is_pf: used to distinguish between VF and PF
  **/
 i40e_status i40e_remove_pd_page_new(struct i40e_hw *hw,
-					      struct i40e_hmc_info *hmc_info,
-					      u32 idx, bool is_pf)
+				    struct i40e_hmc_info *hmc_info,
+				    u32 idx, bool is_pf)
 {
 	i40e_status ret_code = 0;
 	struct i40e_hmc_sd_entry *sd_entry;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_hmc.h b/drivers/net/ethernet/intel/i40e/i40e_hmc.h
index 0cd4701..49964ce 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_hmc.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_hmc.h
@@ -216,26 +216,24 @@ struct i40e_hmc_info {
 	*(pd_limit) += 1;						\
 }
 i40e_status i40e_add_sd_table_entry(struct i40e_hw *hw,
-					      struct i40e_hmc_info *hmc_info,
-					      u32 sd_index,
-					      enum i40e_sd_entry_type type,
-					      u64 direct_mode_sz);
+				    struct i40e_hmc_info *hmc_info,
+				    u32 sd_index,
+				    enum i40e_sd_entry_type type,
+				    u64 direct_mode_sz);
 
 i40e_status i40e_add_pd_table_entry(struct i40e_hw *hw,
-					      struct i40e_hmc_info *hmc_info,
-					      u32 pd_index);
+				    struct i40e_hmc_info *hmc_info,
+				    u32 pd_index);
 i40e_status i40e_remove_pd_bp(struct i40e_hw *hw,
-					struct i40e_hmc_info *hmc_info,
-					u32 idx, bool is_pf);
-i40e_status i40e_prep_remove_sd_bp(struct i40e_hmc_info *hmc_info,
-					     u32 idx);
+			      struct i40e_hmc_info *hmc_info,
+			      u32 idx, bool is_pf);
+i40e_status i40e_prep_remove_sd_bp(struct i40e_hmc_info *hmc_info, u32 idx);
 i40e_status i40e_remove_sd_bp_new(struct i40e_hw *hw,
-					    struct i40e_hmc_info *hmc_info,
-					    u32 idx, bool is_pf);
-i40e_status i40e_prep_remove_pd_page(struct i40e_hmc_info *hmc_info,
-					       u32 idx);
+				  struct i40e_hmc_info *hmc_info,
+				  u32 idx, bool is_pf);
+i40e_status i40e_prep_remove_pd_page(struct i40e_hmc_info *hmc_info, u32 idx);
 i40e_status i40e_remove_pd_page_new(struct i40e_hw *hw,
-					      struct i40e_hmc_info *hmc_info,
-					      u32 idx, bool is_pf);
+				    struct i40e_hmc_info *hmc_info,
+				    u32 idx, bool is_pf);
 
 #endif /* _I40E_HMC_H_ */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
index d5d98fe..13c5bba 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c
@@ -61,7 +61,7 @@ static u64 i40e_align_l2obj_base(u64 offset)
  * on the number of resources it must provide context for.
  **/
 static u64 i40e_calculate_l2fpm_size(u32 txq_num, u32 rxq_num,
-			      u32 fcoe_cntx_num, u32 fcoe_filt_num)
+				     u32 fcoe_cntx_num, u32 fcoe_filt_num)
 {
 	u64 fpm_size = 0;
 
@@ -97,8 +97,8 @@ static u64 i40e_calculate_l2fpm_size(u32 txq_num, u32 rxq_num,
  *   - HMC Resource Profile has been selected before calling this function.
  **/
 i40e_status i40e_init_lan_hmc(struct i40e_hw *hw, u32 txq_num,
-					u32 rxq_num, u32 fcoe_cntx_num,
-					u32 fcoe_filt_num)
+			      u32 rxq_num, u32 fcoe_cntx_num,
+			      u32 fcoe_filt_num)
 {
 	struct i40e_hmc_obj_info *obj, *full_obj;
 	i40e_status ret_code = 0;
@@ -110,7 +110,8 @@ i40e_status i40e_init_lan_hmc(struct i40e_hw *hw, u32 txq_num,
 
 	/* allocate memory for hmc_obj */
 	ret_code = i40e_allocate_virt_mem(hw, &hw->hmc.hmc_obj_virt_mem,
-			sizeof(struct i40e_hmc_obj_info) * I40E_HMC_LAN_MAX);
+					  sizeof(struct i40e_hmc_obj_info) *
+					  I40E_HMC_LAN_MAX);
 	if (ret_code)
 		goto init_lan_hmc_out;
 	hw->hmc.hmc_obj = (struct i40e_hmc_obj_info *)
@@ -135,7 +136,7 @@ i40e_status i40e_init_lan_hmc(struct i40e_hw *hw, u32 txq_num,
 	if (txq_num > obj->max_cnt) {
 		ret_code = I40E_ERR_INVALID_HMC_OBJ_COUNT;
 		hw_dbg(hw, "i40e_init_lan_hmc: Tx context: asks for 0x%x but max allowed is 0x%x, returns error %d\n",
-			  txq_num, obj->max_cnt, ret_code);
+		       txq_num, obj->max_cnt, ret_code);
 		goto init_lan_hmc_out;
 	}
 
@@ -158,7 +159,7 @@ i40e_status i40e_init_lan_hmc(struct i40e_hw *hw, u32 txq_num,
 	if (rxq_num > obj->max_cnt) {
 		ret_code = I40E_ERR_INVALID_HMC_OBJ_COUNT;
 		hw_dbg(hw, "i40e_init_lan_hmc: Rx context: asks for 0x%x but max allowed is 0x%x, returns error %d\n",
-			  rxq_num, obj->max_cnt, ret_code);
+		       rxq_num, obj->max_cnt, ret_code);
 		goto init_lan_hmc_out;
 	}
 
@@ -181,7 +182,7 @@ i40e_status i40e_init_lan_hmc(struct i40e_hw *hw, u32 txq_num,
 	if (fcoe_cntx_num > obj->max_cnt) {
 		ret_code = I40E_ERR_INVALID_HMC_OBJ_COUNT;
 		hw_dbg(hw, "i40e_init_lan_hmc: FCoE context: asks for 0x%x but max allowed is 0x%x, returns error %d\n",
-			  fcoe_cntx_num, obj->max_cnt, ret_code);
+		       fcoe_cntx_num, obj->max_cnt, ret_code);
 		goto init_lan_hmc_out;
 	}
 
@@ -204,7 +205,7 @@ i40e_status i40e_init_lan_hmc(struct i40e_hw *hw, u32 txq_num,
 	if (fcoe_filt_num > obj->max_cnt) {
 		ret_code = I40E_ERR_INVALID_HMC_OBJ_COUNT;
 		hw_dbg(hw, "i40e_init_lan_hmc: FCoE filter: asks for 0x%x but max allowed is 0x%x, returns error %d\n",
-			  fcoe_filt_num, obj->max_cnt, ret_code);
+		       fcoe_filt_num, obj->max_cnt, ret_code);
 		goto init_lan_hmc_out;
 	}
 
@@ -223,8 +224,8 @@ i40e_status i40e_init_lan_hmc(struct i40e_hw *hw, u32 txq_num,
 
 		/* allocate the sd_entry members in the sd_table */
 		ret_code = i40e_allocate_virt_mem(hw, &hw->hmc.sd_table.addr,
-					  (sizeof(struct i40e_hmc_sd_entry) *
-					  hw->hmc.sd_table.sd_cnt));
+						  (sizeof(struct i40e_hmc_sd_entry) *
+						   hw->hmc.sd_table.sd_cnt));
 		if (ret_code)
 			goto init_lan_hmc_out;
 		hw->hmc.sd_table.sd_entry =
@@ -252,8 +253,7 @@ init_lan_hmc_out:
  *	   returns.
  **/
 static i40e_status i40e_remove_pd_page(struct i40e_hw *hw,
-						 struct i40e_hmc_info *hmc_info,
-						 u32 idx)
+				       struct i40e_hmc_info *hmc_info, u32 idx)
 {
 	i40e_status ret_code = 0;
 
@@ -279,8 +279,7 @@ static i40e_status i40e_remove_pd_page(struct i40e_hw *hw,
  *	   function returns.
  **/
 static i40e_status i40e_remove_sd_bp(struct i40e_hw *hw,
-					       struct i40e_hmc_info *hmc_info,
-					       u32 idx)
+				     struct i40e_hmc_info *hmc_info, u32 idx)
 {
 	i40e_status ret_code = 0;
 
@@ -299,7 +298,7 @@ static i40e_status i40e_remove_sd_bp(struct i40e_hw *hw,
  * the sd and pd entries.
  **/
 static i40e_status i40e_create_lan_hmc_object(struct i40e_hw *hw,
-				struct i40e_hmc_lan_create_obj_info *info)
+					      struct i40e_hmc_lan_create_obj_info *info)
 {
 	i40e_status ret_code = 0;
 	struct i40e_hmc_sd_entry *sd_entry;
@@ -329,14 +328,14 @@ static i40e_status i40e_create_lan_hmc_object(struct i40e_hw *hw,
 	if (info->start_idx >= info->hmc_info->hmc_obj[info->rsrc_type].cnt) {
 		ret_code = I40E_ERR_INVALID_HMC_OBJ_INDEX;
 		hw_dbg(hw, "i40e_create_lan_hmc_object: returns error %d\n",
-			  ret_code);
+		       ret_code);
 		goto exit;
 	}
 	if ((info->start_idx + info->count) >
 	    info->hmc_info->hmc_obj[info->rsrc_type].cnt) {
 		ret_code = I40E_ERR_INVALID_HMC_OBJ_COUNT;
 		hw_dbg(hw, "i40e_create_lan_hmc_object: returns error %d\n",
-			  ret_code);
+		       ret_code);
 		goto exit;
 	}
 
@@ -386,8 +385,8 @@ static i40e_status i40e_create_lan_hmc_object(struct i40e_hw *hw,
 			for (i = pd_idx1; i < pd_lmt1; i++) {
 				/* update the pd table entry */
 				ret_code = i40e_add_pd_table_entry(hw,
-								info->hmc_info,
-								i);
+								   info->hmc_info,
+								   i);
 				if (ret_code) {
 					pd_error = true;
 					break;
@@ -407,8 +406,8 @@ static i40e_status i40e_create_lan_hmc_object(struct i40e_hw *hw,
 			switch (sd_entry->entry_type) {
 			case I40E_SD_TYPE_PAGED:
 				I40E_SET_PF_SD_ENTRY(hw,
-					sd_entry->u.pd_table.pd_page_addr.pa,
-					j, sd_entry->entry_type);
+						     sd_entry->u.pd_table.pd_page_addr.pa,
+						     j, sd_entry->entry_type);
 				break;
 			case I40E_SD_TYPE_DIRECT:
 				I40E_SET_PF_SD_ENTRY(hw, sd_entry->u.bp.addr.pa,
@@ -464,7 +463,7 @@ exit:
  *   any LAN/FCoE HMC objects can be created.
  **/
 i40e_status i40e_configure_lan_hmc(struct i40e_hw *hw,
-					     enum i40e_hmc_model model)
+				   enum i40e_hmc_model model)
 {
 	struct i40e_hmc_lan_create_obj_info info;
 	i40e_status ret_code = 0;
@@ -504,7 +503,7 @@ try_type_paged:
 		/* unsupported type */
 		ret_code = I40E_ERR_INVALID_SD_TYPE;
 		hw_dbg(hw, "i40e_configure_lan_hmc: Unknown SD type: %d\n",
-			  ret_code);
+		       ret_code);
 		goto configure_lan_hmc_out;
 		break;
 	}
@@ -526,7 +525,7 @@ try_type_paged:
 	/* FCoE contexts */
 	obj = &hw->hmc.hmc_obj[I40E_HMC_FCOE_CTX];
 	wr32(hw, I40E_GLHMC_FCOEDDPBASE(hmc_fn_id),
-	 (u32)((obj->base & I40E_GLHMC_FCOEDDPBASE_FPMFCOEDDPBASE_MASK) / 512));
+	     (u32)((obj->base & I40E_GLHMC_FCOEDDPBASE_FPMFCOEDDPBASE_MASK) / 512));
 	wr32(hw, I40E_GLHMC_FCOEDDPCNT(hmc_fn_id), obj->cnt);
 
 	/* FCoE filters */
@@ -550,7 +549,7 @@ configure_lan_hmc_out:
  * book-keeping information about PDs and backing storage.
  **/
 static i40e_status i40e_delete_lan_hmc_object(struct i40e_hw *hw,
-				struct i40e_hmc_lan_delete_obj_info *info)
+					      struct i40e_hmc_lan_delete_obj_info *info)
 {
 	i40e_status ret_code = 0;
 	struct i40e_hmc_pd_table *pd_table;
@@ -588,7 +587,7 @@ static i40e_status i40e_delete_lan_hmc_object(struct i40e_hw *hw,
 	if (info->start_idx >= info->hmc_info->hmc_obj[info->rsrc_type].cnt) {
 		ret_code = I40E_ERR_INVALID_HMC_OBJ_INDEX;
 		hw_dbg(hw, "i40e_delete_hmc_object: returns error %d\n",
-			  ret_code);
+		       ret_code);
 		goto exit;
 	}
 
@@ -596,7 +595,7 @@ static i40e_status i40e_delete_lan_hmc_object(struct i40e_hw *hw,
 	    info->hmc_info->hmc_obj[info->rsrc_type].cnt) {
 		ret_code = I40E_ERR_INVALID_HMC_OBJ_COUNT;
 		hw_dbg(hw, "i40e_delete_hmc_object: returns error %d\n",
-			  ret_code);
+		       ret_code);
 		goto exit;
 	}
 
@@ -757,8 +756,8 @@ static struct i40e_context_ele i40e_hmc_rxq_ce_info[] = {
  * @hmc_type: the type of HMC resource
  **/
 static i40e_status i40e_clear_hmc_context(struct i40e_hw *hw,
-					u8 *context_bytes,
-					enum i40e_hmc_lan_rsrc_type hmc_type)
+					  u8 *context_bytes,
+					  enum i40e_hmc_lan_rsrc_type hmc_type)
 {
 	/* clean the bit array */
 	memset(context_bytes, 0, (u32)hw->hmc.hmc_obj[hmc_type].size);
@@ -858,9 +857,9 @@ static i40e_status i40e_set_hmc_context(u8 *context_bytes,
  **/
 static
 i40e_status i40e_hmc_get_object_va(struct i40e_hmc_info *hmc_info,
-					u8 **object_base,
-					enum i40e_hmc_lan_rsrc_type rsrc_type,
-					u32 obj_idx)
+				   u8 **object_base,
+				   enum i40e_hmc_lan_rsrc_type rsrc_type,
+				   u32 obj_idx)
 {
 	u32 obj_offset_in_sd, obj_offset_in_pd;
 	i40e_status ret_code = 0;
@@ -892,7 +891,7 @@ i40e_status i40e_hmc_get_object_va(struct i40e_hmc_info *hmc_info,
 	}
 	if (obj_idx >= hmc_info->hmc_obj[rsrc_type].cnt) {
 		hw_dbg(hw, "i40e_hmc_get_object_va: returns error %d\n",
-			  ret_code);
+		       ret_code);
 		ret_code = I40E_ERR_INVALID_HMC_OBJ_INDEX;
 		goto exit;
 	}
@@ -926,8 +925,7 @@ exit:
  * @hw:    the hardware struct
  * @queue: the queue we care about
  **/
-i40e_status i40e_clear_lan_tx_queue_context(struct i40e_hw *hw,
-						      u16 queue)
+i40e_status i40e_clear_lan_tx_queue_context(struct i40e_hw *hw, u16 queue)
 {
 	i40e_status err;
 	u8 *context_bytes;
@@ -946,9 +944,8 @@ i40e_status i40e_clear_lan_tx_queue_context(struct i40e_hw *hw,
  * @queue: the queue we care about
  * @s:     the struct to be filled
  **/
-i40e_status i40e_set_lan_tx_queue_context(struct i40e_hw *hw,
-						    u16 queue,
-						    struct i40e_hmc_obj_txq *s)
+i40e_status i40e_set_lan_tx_queue_context(struct i40e_hw *hw, u16 queue,
+					  struct i40e_hmc_obj_txq *s)
 {
 	i40e_status err;
 	u8 *context_bytes;
@@ -967,8 +964,7 @@ i40e_status i40e_set_lan_tx_queue_context(struct i40e_hw *hw,
  * @hw:    the hardware struct
  * @queue: the queue we care about
  **/
-i40e_status i40e_clear_lan_rx_queue_context(struct i40e_hw *hw,
-						      u16 queue)
+i40e_status i40e_clear_lan_rx_queue_context(struct i40e_hw *hw, u16 queue)
 {
 	i40e_status err;
 	u8 *context_bytes;
@@ -987,9 +983,8 @@ i40e_status i40e_clear_lan_rx_queue_context(struct i40e_hw *hw,
  * @queue: the queue we care about
  * @s:     the struct to be filled
  **/
-i40e_status i40e_set_lan_rx_queue_context(struct i40e_hw *hw,
-						    u16 queue,
-						    struct i40e_hmc_obj_rxq *s)
+i40e_status i40e_set_lan_rx_queue_context(struct i40e_hw *hw, u16 queue,
+					  struct i40e_hmc_obj_rxq *s)
 {
 	i40e_status err;
 	u8 *context_bytes;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h
index 341de92..a9b1fb7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_lan_hmc.h
@@ -148,21 +148,17 @@ struct i40e_hmc_lan_delete_obj_info {
 };
 
 i40e_status i40e_init_lan_hmc(struct i40e_hw *hw, u32 txq_num,
-					u32 rxq_num, u32 fcoe_cntx_num,
-					u32 fcoe_filt_num);
+			      u32 rxq_num, u32 fcoe_cntx_num,
+			      u32 fcoe_filt_num);
 i40e_status i40e_configure_lan_hmc(struct i40e_hw *hw,
-					     enum i40e_hmc_model model);
+				   enum i40e_hmc_model model);
 i40e_status i40e_shutdown_lan_hmc(struct i40e_hw *hw);
 
-i40e_status i40e_clear_lan_tx_queue_context(struct i40e_hw *hw,
-						      u16 queue);
-i40e_status i40e_set_lan_tx_queue_context(struct i40e_hw *hw,
-						    u16 queue,
-						    struct i40e_hmc_obj_txq *s);
-i40e_status i40e_clear_lan_rx_queue_context(struct i40e_hw *hw,
-						      u16 queue);
-i40e_status i40e_set_lan_rx_queue_context(struct i40e_hw *hw,
-						    u16 queue,
-						    struct i40e_hmc_obj_rxq *s);
+i40e_status i40e_clear_lan_tx_queue_context(struct i40e_hw *hw, u16 queue);
+i40e_status i40e_set_lan_tx_queue_context(struct i40e_hw *hw, u16 queue,
+					  struct i40e_hmc_obj_txq *s);
+i40e_status i40e_clear_lan_rx_queue_context(struct i40e_hw *hw, u16 queue);
+i40e_status i40e_set_lan_rx_queue_context(struct i40e_hw *hw, u16 queue,
+					  struct i40e_hmc_obj_rxq *s);
 
 #endif /* _I40E_LAN_HMC_H_ */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 28df88e..5d337cd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1504,8 +1504,8 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 		filter_list_len = pf->hw.aq.asq_buf_size /
 			    sizeof(struct i40e_aqc_remove_macvlan_element_data);
 		del_list = kcalloc(filter_list_len,
-			    sizeof(struct i40e_aqc_remove_macvlan_element_data),
-			    GFP_KERNEL);
+				   sizeof(struct i40e_aqc_remove_macvlan_element_data),
+				   GFP_KERNEL);
 		if (!del_list)
 			return -ENOMEM;
 
@@ -1536,8 +1536,8 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 			/* flush a full buffer */
 			if (num_del == filter_list_len) {
 				aq_ret = i40e_aq_remove_macvlan(&pf->hw,
-					    vsi->seid, del_list, num_del,
-					    NULL);
+								vsi->seid, del_list, num_del,
+								NULL);
 				num_del = 0;
 				memset(del_list, 0, sizeof(*del_list));
 
@@ -1550,7 +1550,7 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 		}
 		if (num_del) {
 			aq_ret = i40e_aq_remove_macvlan(&pf->hw, vsi->seid,
-						     del_list, num_del, NULL);
+							del_list, num_del, NULL);
 			num_del = 0;
 
 			if (aq_ret)
@@ -1566,8 +1566,8 @@ int i40e_sync_vsi_filters(struct i40e_vsi *vsi)
 		filter_list_len = pf->hw.aq.asq_buf_size /
 			       sizeof(struct i40e_aqc_add_macvlan_element_data),
 		add_list = kcalloc(filter_list_len,
-			       sizeof(struct i40e_aqc_add_macvlan_element_data),
-			       GFP_KERNEL);
+				   sizeof(struct i40e_aqc_add_macvlan_element_data),
+				   GFP_KERNEL);
 		if (!add_list)
 			return -ENOMEM;
 
@@ -1944,7 +1944,7 @@ int i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
 		list_for_each_entry(f, &vsi->mac_filter_list, list) {
 			i40e_del_filter(vsi, f->macaddr, 0, is_vf, is_netdev);
 			add_f = i40e_add_filter(vsi, f->macaddr, I40E_VLAN_ANY,
-					    is_vf, is_netdev);
+						is_vf, is_netdev);
 			if (!add_f) {
 				dev_info(&vsi->back->pdev->dev,
 					 "Could not add filter %d for %pM\n",
@@ -2996,7 +2996,8 @@ static bool i40e_clean_fdir_tx_irq(struct i40e_ring *tx_ring, int budget)
 
 	if (vsi->back->flags & I40E_FLAG_MSIX_ENABLED) {
 		i40e_irq_dynamic_enable(vsi,
-				tx_ring->q_vector->v_idx + vsi->base_vector);
+					tx_ring->q_vector->v_idx +
+					vsi->base_vector);
 	}
 	return budget > 0;
 }
@@ -3824,9 +3825,9 @@ static void i40e_vsi_config_netdev_tc(struct i40e_vsi *vsi, u8 enabled_tc)
 		 */
 		if (vsi->tc_config.enabled_tc & (1 << i))
 			netdev_set_tc_queue(netdev,
-					vsi->tc_config.tc_info[i].netdev_tc,
-					vsi->tc_config.tc_info[i].qcount,
-					vsi->tc_config.tc_info[i].qoffset);
+					    vsi->tc_config.tc_info[i].netdev_tc,
+					    vsi->tc_config.tc_info[i].qcount,
+					    vsi->tc_config.tc_info[i].qoffset);
 	}
 
 	/* Assign UP2TC map for the VSI */
@@ -4567,8 +4568,8 @@ static int i40e_handle_lldp_event(struct i40e_pf *pf,
 	if (type == I40E_AQ_LLDP_MIB_REMOTE) {
 		/* Update the remote cached instance and return */
 		ret = i40e_aq_get_dcb_config(hw, I40E_AQ_LLDP_MIB_REMOTE,
-				I40E_AQ_LLDP_BRIDGE_TYPE_NEAREST_BRIDGE,
-				&hw->remote_dcbx_config);
+					     I40E_AQ_LLDP_BRIDGE_TYPE_NEAREST_BRIDGE,
+					     &hw->remote_dcbx_config);
 		goto exit;
 	}
 
@@ -5038,11 +5039,11 @@ static void i40e_clean_adminq_subtask(struct i40e_pf *pf)
 			break;
 		case i40e_aqc_opc_send_msg_to_pf:
 			ret = i40e_vc_process_vf_msg(pf,
-					le16_to_cpu(event.desc.retval),
-					le32_to_cpu(event.desc.cookie_high),
-					le32_to_cpu(event.desc.cookie_low),
-					event.msg_buf,
-					event.msg_size);
+						     le16_to_cpu(event.desc.retval),
+						     le32_to_cpu(event.desc.cookie_high),
+						     le32_to_cpu(event.desc.cookie_low),
+						     event.msg_buf,
+						     event.msg_size);
 			break;
 		case i40e_aqc_opc_lldp_update_mib:
 			dev_dbg(&pf->pdev->dev, "ARQ: Update LLDP MIB event received\n");
@@ -5175,9 +5176,9 @@ static int i40e_get_capabilities(struct i40e_pf *pf)
 
 		/* this loads the data into the hw struct for us */
 		err = i40e_aq_discover_capabilities(&pf->hw, cap_buf, buf_len,
-					    &data_size,
-					    i40e_aqc_opc_list_func_capabilities,
-					    NULL);
+						    &data_size,
+						    i40e_aqc_opc_list_func_capabilities,
+						    NULL);
 		/* data loaded, buffer no longer needed */
 		kfree(cap_buf);
 
@@ -7198,8 +7199,7 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 	else if (type == I40E_VSI_SRIOV)
 		vsi->vf_id = param1;
 	/* assign it some queues */
-	ret = i40e_get_lump(pf, pf->qp_pile, vsi->alloc_queue_pairs,
-				vsi->idx);
+	ret = i40e_get_lump(pf, pf->qp_pile, vsi->alloc_queue_pairs, vsi->idx);
 	if (ret < 0) {
 		dev_info(&pf->pdev->dev, "VSI %d get_lump failed %d\n",
 			 vsi->seid, ret);
@@ -7398,7 +7398,7 @@ static void i40e_switch_branch_release(struct i40e_veb *branch)
 		if (!pf->vsi[i])
 			continue;
 		if (pf->vsi[i]->uplink_seid == branch_seid &&
-		   (pf->vsi[i]->flags & I40E_VSI_FLAG_VEB_OWNER) == 0) {
+		    (pf->vsi[i]->flags & I40E_VSI_FLAG_VEB_OWNER) == 0) {
 			i40e_vsi_release(pf->vsi[i]);
 		}
 	}
@@ -7617,8 +7617,8 @@ err_alloc:
  * helper function to assist in extracting a few useful SEID values.
  **/
 static void i40e_setup_pf_switch_element(struct i40e_pf *pf,
-				struct i40e_aqc_switch_config_element_resp *ele,
-				u16 num_reported, bool printconfig)
+					 struct i40e_aqc_switch_config_element_resp *ele,
+					 u16 num_reported, bool printconfig)
 {
 	u16 downlink_seid = le16_to_cpu(ele->downlink_seid);
 	u16 uplink_seid = le16_to_cpu(ele->uplink_seid);
@@ -8065,8 +8065,10 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	/* set up pci connections */
-	err = pci_request_selected_regions(pdev, pci_select_bars(pdev,
-					   IORESOURCE_MEM), i40e_driver_name);
+	err = pci_request_selected_regions(pdev,
+					   pci_select_bars(pdev,
+							   IORESOURCE_MEM),
+					   i40e_driver_name);
 	if (err) {
 		dev_info(&pdev->dev,
 			 "pci_request_selected_regions failed %d\n", err);
@@ -8299,15 +8301,15 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	i40e_set_pci_config_data(hw, link_status);
 
 	dev_info(&pdev->dev, "PCI-Express: %s %s\n",
-		(hw->bus.speed == i40e_bus_speed_8000 ? "Speed 8.0GT/s" :
-		 hw->bus.speed == i40e_bus_speed_5000 ? "Speed 5.0GT/s" :
-		 hw->bus.speed == i40e_bus_speed_2500 ? "Speed 2.5GT/s" :
-		 "Unknown"),
-		(hw->bus.width == i40e_bus_width_pcie_x8 ? "Width x8" :
-		 hw->bus.width == i40e_bus_width_pcie_x4 ? "Width x4" :
-		 hw->bus.width == i40e_bus_width_pcie_x2 ? "Width x2" :
-		 hw->bus.width == i40e_bus_width_pcie_x1 ? "Width x1" :
-		 "Unknown"));
+		 (hw->bus.speed == i40e_bus_speed_8000 ? "Speed 8.0GT/s" :
+		  hw->bus.speed == i40e_bus_speed_5000 ? "Speed 5.0GT/s" :
+		  hw->bus.speed == i40e_bus_speed_2500 ? "Speed 2.5GT/s" :
+		  "Unknown"),
+		 (hw->bus.width == i40e_bus_width_pcie_x8 ? "Width x8" :
+		  hw->bus.width == i40e_bus_width_pcie_x4 ? "Width x4" :
+		  hw->bus.width == i40e_bus_width_pcie_x2 ? "Width x2" :
+		  hw->bus.width == i40e_bus_width_pcie_x1 ? "Width x1" :
+		  "Unknown"));
 
 	if (hw->bus.width < i40e_bus_width_pcie_x8 ||
 	    hw->bus.speed < i40e_bus_speed_8000) {
diff --git a/drivers/net/ethernet/intel/i40e/i40e_nvm.c b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
index 262bdf1..2aac050 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_nvm.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_nvm.c
@@ -76,7 +76,7 @@ i40e_status i40e_init_nvm(struct i40e_hw *hw)
  * via the proper Admin Command.
  **/
 i40e_status i40e_acquire_nvm(struct i40e_hw *hw,
-				       enum i40e_aq_resource_access_type access)
+			     enum i40e_aq_resource_access_type access)
 {
 	i40e_status ret_code = 0;
 	u64 gtime, timeout;
@@ -104,9 +104,9 @@ i40e_status i40e_acquire_nvm(struct i40e_hw *hw,
 		while (gtime < timeout) {
 			usleep_range(10000, 20000);
 			ret_code = i40e_aq_request_resource(hw,
-							I40E_NVM_RESOURCE_ID,
-							access, 0, &time,
-							NULL);
+							    I40E_NVM_RESOURCE_ID,
+							    access, 0, &time,
+							    NULL);
 			if (!ret_code) {
 				hw->nvm.hw_semaphore_timeout =
 						I40E_MS_TO_GTIME(time) + gtime;
@@ -119,7 +119,7 @@ i40e_status i40e_acquire_nvm(struct i40e_hw *hw,
 			hw->nvm.hw_semaphore_wait =
 						I40E_MS_TO_GTIME(time) + gtime;
 			hw_dbg(hw, "NVM acquire timed out, wait %llu ms before trying again.\n",
-				  time);
+			       time);
 		}
 	}
 
@@ -172,8 +172,7 @@ static i40e_status i40e_poll_sr_srctl_done_bit(struct i40e_hw *hw)
  *
  * Reads one 16 bit word from the Shadow RAM using the GLNVM_SRCTL register.
  **/
-i40e_status i40e_read_nvm_word(struct i40e_hw *hw, u16 offset,
-					 u16 *data)
+i40e_status i40e_read_nvm_word(struct i40e_hw *hw, u16 offset, u16 *data)
 {
 	i40e_status ret_code = I40E_ERR_TIMEOUT;
 	u32 sr_reg;
@@ -203,7 +202,7 @@ i40e_status i40e_read_nvm_word(struct i40e_hw *hw, u16 offset,
 	}
 	if (ret_code)
 		hw_dbg(hw, "NVM read error: Couldn't access Shadow RAM address: 0x%x\n",
-			  offset);
+		       offset);
 
 read_nvm_exit:
 	return ret_code;
@@ -221,7 +220,7 @@ read_nvm_exit:
  * and followed by the release.
  **/
 i40e_status i40e_read_nvm_buffer(struct i40e_hw *hw, u16 offset,
-					   u16 *words, u16 *data)
+				 u16 *words, u16 *data)
 {
 	i40e_status ret_code = 0;
 	u16 index, word;
@@ -250,8 +249,7 @@ i40e_status i40e_read_nvm_buffer(struct i40e_hw *hw, u16 offset,
  * is customer specific and unknown. Therefore, this function skips all maximum
  * possible size of VPD (1kB).
  **/
-static i40e_status i40e_calc_nvm_checksum(struct i40e_hw *hw,
-						    u16 *checksum)
+static i40e_status i40e_calc_nvm_checksum(struct i40e_hw *hw, u16 *checksum)
 {
 	i40e_status ret_code = 0;
 	u16 pcie_alt_module = 0;
@@ -269,7 +267,7 @@ static i40e_status i40e_calc_nvm_checksum(struct i40e_hw *hw,
 
 	/* read pointer to PCIe Alt Auto-load module */
 	ret_code = i40e_read_nvm_word(hw, I40E_SR_PCIE_ALT_AUTO_LOAD_PTR,
-				       &pcie_alt_module);
+				      &pcie_alt_module);
 	if (ret_code) {
 		ret_code = I40E_ERR_NVM_CHECKSUM;
 		goto i40e_calc_nvm_checksum_exit;
@@ -317,8 +315,7 @@ i40e_calc_nvm_checksum_exit:
  * Performs checksum calculation and validates the NVM SW checksum. If the
  * caller does not need checksum, the value can be NULL.
  **/
-i40e_status i40e_validate_nvm_checksum(struct i40e_hw *hw,
-						 u16 *checksum)
+i40e_status i40e_validate_nvm_checksum(struct i40e_hw *hw, u16 *checksum)
 {
 	i40e_status ret_code = 0;
 	u16 checksum_sr = 0;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index 9cd57e6..c01bf61 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -43,13 +43,13 @@ i40e_status i40e_init_adminq(struct i40e_hw *hw);
 i40e_status i40e_shutdown_adminq(struct i40e_hw *hw);
 void i40e_adminq_init_ring_data(struct i40e_hw *hw);
 i40e_status i40e_clean_arq_element(struct i40e_hw *hw,
-					     struct i40e_arq_event_info *e,
-					     u16 *events_pending);
+				   struct i40e_arq_event_info *e,
+				   u16 *events_pending);
 i40e_status i40e_asq_send_command(struct i40e_hw *hw,
-				struct i40e_aq_desc *desc,
-				void *buff, /* can be NULL */
-				u16  buff_size,
-				struct i40e_asq_cmd_details *cmd_details);
+				  struct i40e_aq_desc *desc,
+				  void *buff, /* can be NULL */
+				  u16  buff_size,
+				  struct i40e_asq_cmd_details *cmd_details);
 
 /* debug function for adminq */
 void i40e_debug_aq(struct i40e_hw *hw,
@@ -67,168 +67,171 @@ void i40e_led_set(struct i40e_hw *hw, u32 mode, bool blink);
 /* admin send queue commands */
 
 i40e_status i40e_aq_get_firmware_version(struct i40e_hw *hw,
-				u16 *fw_major_version, u16 *fw_minor_version,
-				u16 *api_major_version, u16 *api_minor_version,
-				struct i40e_asq_cmd_details *cmd_details);
+					 u16 *fw_major_version, u16 *fw_minor_version,
+					 u16 *api_major_version, u16 *api_minor_version,
+					 struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_set_phy_reset(struct i40e_hw *hw,
-				struct i40e_asq_cmd_details *cmd_details);
+				  struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_set_default_vsi(struct i40e_hw *hw, u16 vsi_id,
-				struct i40e_asq_cmd_details *cmd_details);
+				    struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_set_link_restart_an(struct i40e_hw *hw,
-				struct i40e_asq_cmd_details *cmd_details);
+					struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_get_link_info(struct i40e_hw *hw,
-				bool enable_lse, struct i40e_link_status *link,
-				struct i40e_asq_cmd_details *cmd_details);
+				  bool enable_lse, struct i40e_link_status *link,
+				  struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_set_local_advt_reg(struct i40e_hw *hw,
-				u64 advt_reg,
-				struct i40e_asq_cmd_details *cmd_details);
+				       u64 advt_reg,
+				       struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_send_driver_version(struct i40e_hw *hw,
-				struct i40e_driver_version *dv,
-				struct i40e_asq_cmd_details *cmd_details);
+					struct i40e_driver_version *dv,
+					struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_add_vsi(struct i40e_hw *hw,
-				struct i40e_vsi_context *vsi_ctx,
-				struct i40e_asq_cmd_details *cmd_details);
+			    struct i40e_vsi_context *vsi_ctx,
+			    struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_set_vsi_broadcast(struct i40e_hw *hw,
-				u16 vsi_id, bool set_filter,
-				struct i40e_asq_cmd_details *cmd_details);
+				      u16 vsi_id, bool set_filter,
+				      struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw,
-		u16 vsi_id, bool set, struct i40e_asq_cmd_details *cmd_details);
+						u16 vsi_id, bool set,
+						struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_set_vsi_multicast_promiscuous(struct i40e_hw *hw,
-		u16 vsi_id, bool set, struct i40e_asq_cmd_details *cmd_details);
+						  u16 vsi_id, bool set,
+						  struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_get_vsi_params(struct i40e_hw *hw,
-				struct i40e_vsi_context *vsi_ctx,
-				struct i40e_asq_cmd_details *cmd_details);
+				   struct i40e_vsi_context *vsi_ctx,
+				   struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_update_vsi_params(struct i40e_hw *hw,
-				struct i40e_vsi_context *vsi_ctx,
-				struct i40e_asq_cmd_details *cmd_details);
+				      struct i40e_vsi_context *vsi_ctx,
+				      struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_add_veb(struct i40e_hw *hw, u16 uplink_seid,
-				u16 downlink_seid, u8 enabled_tc,
-				bool default_port, bool enable_l2_filtering,
-				u16 *pveb_seid,
-				struct i40e_asq_cmd_details *cmd_details);
+			    u16 downlink_seid, u8 enabled_tc,
+			    bool default_port, bool enable_l2_filtering,
+			    u16 *pveb_seid,
+			    struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_get_veb_parameters(struct i40e_hw *hw,
-				u16 veb_seid, u16 *switch_id, bool *floating,
-				u16 *statistic_index, u16 *vebs_used,
-				u16 *vebs_free,
-				struct i40e_asq_cmd_details *cmd_details);
+				       u16 veb_seid, u16 *switch_id,
+				       bool *floating,
+				       u16 *statistic_index, u16 *vebs_used,
+				       u16 *vebs_free,
+				       struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_add_macvlan(struct i40e_hw *hw, u16 vsi_id,
-			struct i40e_aqc_add_macvlan_element_data *mv_list,
-			u16 count, struct i40e_asq_cmd_details *cmd_details);
+				struct i40e_aqc_add_macvlan_element_data *mv_list,
+				u16 count,
+				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_remove_macvlan(struct i40e_hw *hw, u16 vsi_id,
-			struct i40e_aqc_remove_macvlan_element_data *mv_list,
-			u16 count, struct i40e_asq_cmd_details *cmd_details);
+				   struct i40e_aqc_remove_macvlan_element_data *mv_list,
+				   u16 count,
+				   struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_send_msg_to_vf(struct i40e_hw *hw, u16 vfid,
-				u32 v_opcode, u32 v_retval, u8 *msg, u16 msglen,
-				struct i40e_asq_cmd_details *cmd_details);
+				   u32 v_opcode, u32 v_retval,
+				   u8 *msg, u16 msglen,
+				   struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_get_switch_config(struct i40e_hw *hw,
-				struct i40e_aqc_get_switch_config_resp *buf,
-				u16 buf_size, u16 *start_seid,
-				struct i40e_asq_cmd_details *cmd_details);
+				      struct i40e_aqc_get_switch_config_resp *buf,
+				      u16 buf_size, u16 *start_seid,
+				      struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_request_resource(struct i40e_hw *hw,
-				enum i40e_aq_resources_ids resource,
-				enum i40e_aq_resource_access_type access,
-				u8 sdp_number, u64 *timeout,
-				struct i40e_asq_cmd_details *cmd_details);
+				     enum i40e_aq_resources_ids resource,
+				     enum i40e_aq_resource_access_type access,
+				     u8 sdp_number, u64 *timeout,
+				     struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_release_resource(struct i40e_hw *hw,
-				enum i40e_aq_resources_ids resource,
-				u8 sdp_number,
-				struct i40e_asq_cmd_details *cmd_details);
+				     enum i40e_aq_resources_ids resource,
+				     u8 sdp_number,
+				     struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_read_nvm(struct i40e_hw *hw, u8 module_pointer,
-				u32 offset, u16 length, void *data,
-				bool last_command,
-				struct i40e_asq_cmd_details *cmd_details);
+			     u32 offset, u16 length, void *data,
+			     bool last_command,
+			     struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_discover_capabilities(struct i40e_hw *hw,
-				void *buff, u16 buff_size, u16 *data_size,
-				enum i40e_admin_queue_opc list_type_opc,
-				struct i40e_asq_cmd_details *cmd_details);
+					  void *buff, u16 buff_size,
+					  u16 *data_size,
+					  enum i40e_admin_queue_opc list_type_opc,
+					  struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_update_nvm(struct i40e_hw *hw, u8 module_pointer,
-				u32 offset, u16 length, void *data,
-				bool last_command,
-				struct i40e_asq_cmd_details *cmd_details);
+			       u32 offset, u16 length, void *data,
+			       bool last_command,
+			       struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_get_lldp_mib(struct i40e_hw *hw, u8 bridge_type,
-				u8 mib_type, void *buff, u16 buff_size,
-				u16 *local_len, u16 *remote_len,
-				struct i40e_asq_cmd_details *cmd_details);
+				 u8 mib_type, void *buff, u16 buff_size,
+				 u16 *local_len, u16 *remote_len,
+				 struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_cfg_lldp_mib_change_event(struct i40e_hw *hw,
-				bool enable_update,
-				struct i40e_asq_cmd_details *cmd_details);
+					      bool enable_update,
+					      struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_stop_lldp(struct i40e_hw *hw, bool shutdown_agent,
-				struct i40e_asq_cmd_details *cmd_details);
+			      struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_start_lldp(struct i40e_hw *hw,
-				struct i40e_asq_cmd_details *cmd_details);
+			       struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_add_udp_tunnel(struct i40e_hw *hw,
-				u16 udp_port, u8 header_len,
-				u8 protocol_index, u8 *filter_index,
-				struct i40e_asq_cmd_details *cmd_details);
+				   u16 udp_port, u8 header_len,
+				   u8 protocol_index, u8 *filter_index,
+				   struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_del_udp_tunnel(struct i40e_hw *hw, u8 index,
-				struct i40e_asq_cmd_details *cmd_details);
+				   struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_delete_element(struct i40e_hw *hw, u16 seid,
-				struct i40e_asq_cmd_details *cmd_details);
+				   struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_mac_address_write(struct i40e_hw *hw,
-				    u16 flags, u8 *mac_addr,
-				    struct i40e_asq_cmd_details *cmd_details);
+				      u16 flags, u8 *mac_addr,
+				      struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_dcb_updated(struct i40e_hw *hw,
 				struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_set_hmc_resource_profile(struct i40e_hw *hw,
-				enum i40e_aq_hmc_profile profile,
-				u8 pe_vf_enabled_count,
-				struct i40e_asq_cmd_details *cmd_details);
+					     enum i40e_aq_hmc_profile profile,
+					     u8 pe_vf_enabled_count,
+					     struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_config_switch_comp_bw_limit(struct i40e_hw *hw,
-				u16 seid, u16 credit, u8 max_bw,
-				struct i40e_asq_cmd_details *cmd_details);
+						u16 seid, u16 credit, u8 max_bw,
+						struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_config_vsi_tc_bw(struct i40e_hw *hw, u16 seid,
-			struct i40e_aqc_configure_vsi_tc_bw_data *bw_data,
-			struct i40e_asq_cmd_details *cmd_details);
+				     struct i40e_aqc_configure_vsi_tc_bw_data *bw_data,
+				     struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_config_switch_comp_ets(struct i40e_hw *hw,
-		u16 seid,
-		struct i40e_aqc_configure_switching_comp_ets_data *ets_data,
-		enum i40e_admin_queue_opc opcode,
-		struct i40e_asq_cmd_details *cmd_details);
+					   u16 seid,
+					   struct i40e_aqc_configure_switching_comp_ets_data *ets_data,
+					   enum i40e_admin_queue_opc opcode,
+					   struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_config_switch_comp_bw_config(struct i40e_hw *hw,
-	u16 seid,
-	struct i40e_aqc_configure_switching_comp_bw_config_data *bw_data,
-	struct i40e_asq_cmd_details *cmd_details);
+						 u16 seid,
+						 struct i40e_aqc_configure_switching_comp_bw_config_data *bw_data,
+						 struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_query_vsi_bw_config(struct i40e_hw *hw,
-			u16 seid,
-			struct i40e_aqc_query_vsi_bw_config_resp *bw_data,
-			struct i40e_asq_cmd_details *cmd_details);
+					u16 seid,
+					struct i40e_aqc_query_vsi_bw_config_resp *bw_data,
+					struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_query_vsi_ets_sla_config(struct i40e_hw *hw,
-			u16 seid,
-			struct i40e_aqc_query_vsi_ets_sla_config_resp *bw_data,
-			struct i40e_asq_cmd_details *cmd_details);
+					     u16 seid,
+					     struct i40e_aqc_query_vsi_ets_sla_config_resp *bw_data,
+					     struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_query_switch_comp_ets_config(struct i40e_hw *hw,
-		u16 seid,
-		struct i40e_aqc_query_switching_comp_ets_config_resp *bw_data,
-		struct i40e_asq_cmd_details *cmd_details);
+						 u16 seid,
+						 struct i40e_aqc_query_switching_comp_ets_config_resp *bw_data,
+						 struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_query_port_ets_config(struct i40e_hw *hw,
-		u16 seid,
-		struct i40e_aqc_query_port_ets_config_resp *bw_data,
-		struct i40e_asq_cmd_details *cmd_details);
+					  u16 seid,
+					  struct i40e_aqc_query_port_ets_config_resp *bw_data,
+					  struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_aq_query_switch_comp_bw_config(struct i40e_hw *hw,
-		u16 seid,
-		struct i40e_aqc_query_switching_comp_bw_config_resp *bw_data,
-		struct i40e_asq_cmd_details *cmd_details);
+						u16 seid,
+						struct i40e_aqc_query_switching_comp_bw_config_resp *bw_data,
+						struct i40e_asq_cmd_details *cmd_details);
 /* i40e_common */
 i40e_status i40e_init_shared_code(struct i40e_hw *hw);
 i40e_status i40e_pf_reset(struct i40e_hw *hw);
 void i40e_clear_pxe_mode(struct i40e_hw *hw);
 bool i40e_get_link_status(struct i40e_hw *hw);
-i40e_status i40e_get_mac_addr(struct i40e_hw *hw,
-						u8 *mac_addr);
+i40e_status i40e_get_mac_addr(struct i40e_hw *hw, u8 *mac_addr);
 i40e_status i40e_validate_mac_addr(u8 *mac_addr);
 /* prototype for functions used for NVM access */
 i40e_status i40e_init_nvm(struct i40e_hw *hw);
 i40e_status i40e_acquire_nvm(struct i40e_hw *hw,
-				      enum i40e_aq_resource_access_type access);
+			     enum i40e_aq_resource_access_type access);
 void i40e_release_nvm(struct i40e_hw *hw);
-i40e_status i40e_read_nvm_srrd(struct i40e_hw *hw, u16 offset,
-					 u16 *data);
-i40e_status i40e_read_nvm_word(struct i40e_hw *hw, u16 offset,
-					 u16 *data);
+i40e_status i40e_read_nvm_srrd(struct i40e_hw *hw, u16 offset, u16 *data);
+i40e_status i40e_read_nvm_word(struct i40e_hw *hw, u16 offset, u16 *data);
 i40e_status i40e_read_nvm_buffer(struct i40e_hw *hw, u16 offset,
-					   u16 *words, u16 *data);
-i40e_status i40e_validate_nvm_checksum(struct i40e_hw *hw,
-						 u16 *checksum);
+				 u16 *words, u16 *data);
+i40e_status i40e_validate_nvm_checksum(struct i40e_hw *hw, u16 *checksum);
 void i40e_set_pci_config_data(struct i40e_hw *hw, u16 link_status);
 
 extern struct i40e_rx_ptype_decoded i40e_ptype_lookup[];
@@ -245,15 +248,15 @@ void i40e_vf_parse_hw_config(struct i40e_hw *hw,
 			     struct i40e_virtchnl_vf_resource *msg);
 i40e_status i40e_vf_reset(struct i40e_hw *hw);
 i40e_status i40e_aq_send_msg_to_pf(struct i40e_hw *hw,
-				enum i40e_virtchnl_ops v_opcode,
-				i40e_status v_retval,
-				u8 *msg, u16 msglen,
-				struct i40e_asq_cmd_details *cmd_details);
+				   enum i40e_virtchnl_ops v_opcode,
+				   i40e_status v_retval,
+				   u8 *msg, u16 msglen,
+				   struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_set_filter_control(struct i40e_hw *hw,
-				struct i40e_filter_control_settings *settings);
+				    struct i40e_filter_control_settings *settings);
 i40e_status i40e_aq_add_rem_control_packet_filter(struct i40e_hw *hw,
-				u8 *mac_addr, u16 ethtype, u16 flags,
-				u16 vsi_seid, u16 queue, bool is_add,
-				struct i40e_control_filter_stats *stats,
-				struct i40e_asq_cmd_details *cmd_details);
+						  u8 *mac_addr, u16 ethtype, u16 flags,
+						  u16 vsi_seid, u16 queue, bool is_add,
+						  struct i40e_control_filter_stats *stats,
+						  struct i40e_asq_cmd_details *cmd_details);
 #endif /* _I40E_PROTOTYPE_H_ */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 851f653..7cbd36a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -285,7 +285,7 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 		err = true;
 	} else {
 		dev_info(&pf->pdev->dev, "Filter OK for PCTYPE %d (ret = %d)\n",
-			  fd_data->pctype, ret);
+			 fd_data->pctype, ret);
 	}
 
 	return err ? -EOPNOTSUPP : 0;
@@ -1544,7 +1544,7 @@ int i40e_napi_poll(struct napi_struct *napi, int budget)
 	if (!test_bit(__I40E_DOWN, &vsi->state)) {
 		if (vsi->back->flags & I40E_FLAG_MSIX_ENABLED) {
 			i40e_irq_dynamic_enable(vsi,
-					q_vector->v_idx + vsi->base_vector);
+						q_vector->v_idx + vsi->base_vector);
 		} else {
 			struct i40e_hw *hw = &vsi->back->hw;
 			/* We re-enable the queue 0 cause, but
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 02c11a7..efb435f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1415,7 +1415,7 @@ static inline int i40e_check_vf_permission(struct i40e_vf *vf, u8 *macaddr)
 	int ret = 0;
 
 	if (is_broadcast_ether_addr(macaddr) ||
-		   is_zero_ether_addr(macaddr)) {
+	    is_zero_ether_addr(macaddr)) {
 		dev_err(&pf->pdev->dev, "invalid VF MAC addr %pM\n", macaddr);
 		ret = I40E_ERR_INVALID_MAC_ADDR;
 	} else if (vf->pf_set_mac && !is_multicast_ether_addr(macaddr) &&
@@ -2114,7 +2114,7 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 	}
 	if (vlan_id || qos)
 		ret = i40e_vsi_add_pvid(vsi,
-				vlan_id | (qos << I40E_VLAN_PRIORITY_SHIFT));
+					vlan_id | (qos << I40E_VLAN_PRIORITY_SHIFT));
 	else
 		i40e_vsi_remove_pvid(vsi);
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
index 5470ce9..c5758f6 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.c
@@ -138,7 +138,8 @@ static i40e_status i40e_alloc_arq_bufs(struct i40e_hw *hw)
 
 	/* buffer_info structures do not need alignment */
 	ret_code = i40e_allocate_virt_mem(hw, &hw->aq.arq.dma_head,
-		(hw->aq.num_arq_entries * sizeof(struct i40e_dma_mem)));
+					  hw->aq.num_arq_entries *
+					  sizeof(struct i40e_dma_mem));
 	if (ret_code)
 		goto alloc_arq_bufs;
 	hw->aq.arq.r.arq_bi = (struct i40e_dma_mem *)hw->aq.arq.dma_head.va;
@@ -200,7 +201,8 @@ static i40e_status i40e_alloc_asq_bufs(struct i40e_hw *hw)
 
 	/* No mapped memory needed yet, just the buffer info structures */
 	ret_code = i40e_allocate_virt_mem(hw, &hw->aq.asq.dma_head,
-		(hw->aq.num_asq_entries * sizeof(struct i40e_dma_mem)));
+					  hw->aq.num_asq_entries *
+					  sizeof(struct i40e_dma_mem));
 	if (ret_code)
 		goto alloc_asq_bufs;
 	hw->aq.asq.r.asq_bi = (struct i40e_dma_mem *)hw->aq.asq.dma_head.va;
@@ -281,17 +283,17 @@ static void i40e_config_asq_regs(struct i40e_hw *hw)
 	if (hw->mac.type == I40E_MAC_VF) {
 		/* configure the transmit queue */
 		wr32(hw, I40E_VF_ATQBAH1,
-		    upper_32_bits(hw->aq.asq.desc_buf.pa));
+		     upper_32_bits(hw->aq.asq.desc_buf.pa));
 		wr32(hw, I40E_VF_ATQBAL1,
-		    lower_32_bits(hw->aq.asq.desc_buf.pa));
+		     lower_32_bits(hw->aq.asq.desc_buf.pa));
 		wr32(hw, I40E_VF_ATQLEN1, (hw->aq.num_asq_entries |
 					  I40E_VF_ATQLEN1_ATQENABLE_MASK));
 	} else {
 		/* configure the transmit queue */
 		wr32(hw, I40E_PF_ATQBAH,
-		    upper_32_bits(hw->aq.asq.desc_buf.pa));
+		     upper_32_bits(hw->aq.asq.desc_buf.pa));
 		wr32(hw, I40E_PF_ATQBAL,
-		    lower_32_bits(hw->aq.asq.desc_buf.pa));
+		     lower_32_bits(hw->aq.asq.desc_buf.pa));
 		wr32(hw, I40E_PF_ATQLEN, (hw->aq.num_asq_entries |
 					  I40E_PF_ATQLEN_ATQENABLE_MASK));
 	}
@@ -308,17 +310,17 @@ static void i40e_config_arq_regs(struct i40e_hw *hw)
 	if (hw->mac.type == I40E_MAC_VF) {
 		/* configure the receive queue */
 		wr32(hw, I40E_VF_ARQBAH1,
-		    upper_32_bits(hw->aq.arq.desc_buf.pa));
+		     upper_32_bits(hw->aq.arq.desc_buf.pa));
 		wr32(hw, I40E_VF_ARQBAL1,
-		    lower_32_bits(hw->aq.arq.desc_buf.pa));
+		     lower_32_bits(hw->aq.arq.desc_buf.pa));
 		wr32(hw, I40E_VF_ARQLEN1, (hw->aq.num_arq_entries |
 					  I40E_VF_ARQLEN1_ARQENABLE_MASK));
 	} else {
 		/* configure the receive queue */
 		wr32(hw, I40E_PF_ARQBAH,
-		    upper_32_bits(hw->aq.arq.desc_buf.pa));
+		     upper_32_bits(hw->aq.arq.desc_buf.pa));
 		wr32(hw, I40E_PF_ARQBAL,
-		    lower_32_bits(hw->aq.arq.desc_buf.pa));
+		     lower_32_bits(hw->aq.arq.desc_buf.pa));
 		wr32(hw, I40E_PF_ARQLEN, (hw->aq.num_arq_entries |
 					  I40E_PF_ARQLEN_ARQENABLE_MASK));
 	}
@@ -640,10 +642,10 @@ bool i40evf_asq_done(struct i40e_hw *hw)
  *  queue.  It runs the queue, cleans the queue, etc
  **/
 i40e_status i40evf_asq_send_command(struct i40e_hw *hw,
-				struct i40e_aq_desc *desc,
-				void *buff, /* can be NULL */
-				u16  buff_size,
-				struct i40e_asq_cmd_details *cmd_details)
+				    struct i40e_aq_desc *desc,
+				    void *buff, /* can be NULL */
+				    u16  buff_size,
+				    struct i40e_asq_cmd_details *cmd_details)
 {
 	i40e_status status = 0;
 	struct i40e_dma_mem *dma_buff = NULL;
@@ -808,8 +810,7 @@ asq_send_command_exit:
  *
  *  Fill the desc with default values
  **/
-void i40evf_fill_default_direct_cmd_desc(struct i40e_aq_desc *desc,
-				       u16 opcode)
+void i40evf_fill_default_direct_cmd_desc(struct i40e_aq_desc *desc, u16 opcode)
 {
 	/* zero out the desc */
 	memset((void *)desc, 0, sizeof(struct i40e_aq_desc));
@@ -828,8 +829,8 @@ void i40evf_fill_default_direct_cmd_desc(struct i40e_aq_desc *desc,
  *  left to process through 'pending'
  **/
 i40e_status i40evf_clean_arq_element(struct i40e_hw *hw,
-					     struct i40e_arq_event_info *e,
-					     u16 *pending)
+				     struct i40e_arq_event_info *e,
+				     u16 *pending)
 {
 	i40e_status ret_code = 0;
 	u16 ntc = hw->aq.arq.next_to_clean;
@@ -857,10 +858,8 @@ i40e_status i40evf_clean_arq_element(struct i40e_hw *hw,
 	/* now clean the next descriptor */
 	desc = I40E_ADMINQ_DESC(hw->aq.arq, ntc);
 	desc_idx = ntc;
-	i40evf_debug_aq(hw,
-		      I40E_DEBUG_AQ_COMMAND,
-		      (void *)desc,
-		      hw->aq.arq.r.arq_bi[desc_idx].va);
+	i40evf_debug_aq(hw, I40E_DEBUG_AQ_COMMAND, (void *)desc,
+			hw->aq.arq.r.arq_bi[desc_idx].va);
 
 	flags = le16_to_cpu(desc->flags);
 	if (flags & I40E_AQ_FLAG_ERR) {
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
index 8f72c31d..302ae0f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_adminq.h
@@ -100,7 +100,6 @@ struct i40e_adminq_info {
 #define I40E_AQ_LARGE_BUF	512
 #define I40E_ASQ_CMD_TIMEOUT	100000  /* usecs */
 
-void i40evf_fill_default_direct_cmd_desc(struct i40e_aq_desc *desc,
-				       u16 opcode);
+void i40evf_fill_default_direct_cmd_desc(struct i40e_aq_desc *desc, u16 opcode);
 
 #endif /* _I40E_ADMINQ_H_ */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_alloc.h b/drivers/net/ethernet/intel/i40evf/i40e_alloc.h
index d8654fb..f112958 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_alloc.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_alloc.h
@@ -41,15 +41,12 @@ enum i40e_memory_type {
 
 /* prototype for functions used for dynamic memory allocation */
 i40e_status i40e_allocate_dma_mem(struct i40e_hw *hw,
-					    struct i40e_dma_mem *mem,
-					    enum i40e_memory_type type,
-					    u64 size, u32 alignment);
-i40e_status i40e_free_dma_mem(struct i40e_hw *hw,
-					struct i40e_dma_mem *mem);
+				  struct i40e_dma_mem *mem,
+				  enum i40e_memory_type type,
+				  u64 size, u32 alignment);
+i40e_status i40e_free_dma_mem(struct i40e_hw *hw, struct i40e_dma_mem *mem);
 i40e_status i40e_allocate_virt_mem(struct i40e_hw *hw,
-					     struct i40e_virt_mem *mem,
-					     u32 size);
-i40e_status i40e_free_virt_mem(struct i40e_hw *hw,
-					 struct i40e_virt_mem *mem);
+				   struct i40e_virt_mem *mem, u32 size);
+i40e_status i40e_free_virt_mem(struct i40e_hw *hw, struct i40e_virt_mem *mem);
 
 #endif /* _I40E_ALLOC_H_ */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index c688a0f..a6c091a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -64,7 +64,7 @@ i40e_status i40e_set_mac_type(struct i40e_hw *hw)
 	}
 
 	hw_dbg(hw, "i40e_set_mac_type found mac: %d, returns: %d\n",
-		  hw->mac.type, status);
+	       hw->mac.type, status);
 	return status;
 }
 
@@ -78,7 +78,7 @@ i40e_status i40e_set_mac_type(struct i40e_hw *hw)
  * Dumps debug log about adminq command with descriptor contents.
  **/
 void i40evf_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask, void *desc,
-		   void *buffer)
+		     void *buffer)
 {
 	struct i40e_aq_desc *aq_desc = (struct i40e_aq_desc *)desc;
 	u8 *aq_buffer = (u8 *)buffer;
@@ -141,8 +141,7 @@ bool i40evf_check_asq_alive(struct i40e_hw *hw)
  * Tell the Firmware that we're shutting down the AdminQ and whether
  * or not the driver is unloading as well.
  **/
-i40e_status i40evf_aq_queue_shutdown(struct i40e_hw *hw,
-					     bool unloading)
+i40e_status i40evf_aq_queue_shutdown(struct i40e_hw *hw, bool unloading)
 {
 	struct i40e_aq_desc desc;
 	struct i40e_aqc_queue_shutdown *cmd =
@@ -150,7 +149,7 @@ i40e_status i40evf_aq_queue_shutdown(struct i40e_hw *hw,
 	i40e_status status;
 
 	i40evf_fill_default_direct_cmd_desc(&desc,
-					  i40e_aqc_opc_queue_shutdown);
+					    i40e_aqc_opc_queue_shutdown);
 
 	if (unloading)
 		cmd->driver_unloading = cpu_to_le32(I40E_AQ_DRIVER_UNLOADING);
@@ -540,10 +539,10 @@ struct i40e_rx_ptype_decoded i40evf_ptype_lookup[] = {
  * completion before returning.
  **/
 i40e_status i40e_aq_send_msg_to_pf(struct i40e_hw *hw,
-				enum i40e_virtchnl_ops v_opcode,
-				i40e_status v_retval,
-				u8 *msg, u16 msglen,
-				struct i40e_asq_cmd_details *cmd_details)
+				   enum i40e_virtchnl_ops v_opcode,
+				   i40e_status v_retval,
+				   u8 *msg, u16 msglen,
+				   struct i40e_asq_cmd_details *cmd_details)
 {
 	struct i40e_aq_desc desc;
 	i40e_status status;
@@ -566,7 +565,7 @@ i40e_status i40e_aq_send_msg_to_pf(struct i40e_hw *hw,
 		cmd_details = &details;
 	}
 	status = i40evf_asq_send_command(hw, (struct i40e_aq_desc *)&desc, msg,
-				       msglen, cmd_details);
+					 msglen, cmd_details);
 	return status;
 }
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_hmc.h b/drivers/net/ethernet/intel/i40evf/i40e_hmc.h
index cb97b3e..1ca32c6 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_hmc.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_hmc.h
@@ -213,26 +213,24 @@ struct i40e_hmc_info {
 	*(pd_limit) += 1;						\
 }
 i40e_status i40e_add_sd_table_entry(struct i40e_hw *hw,
-					      struct i40e_hmc_info *hmc_info,
-					      u32 sd_index,
-					      enum i40e_sd_entry_type type,
-					      u64 direct_mode_sz);
+				    struct i40e_hmc_info *hmc_info,
+				    u32 sd_index,
+				    enum i40e_sd_entry_type type,
+				    u64 direct_mode_sz);
 
 i40e_status i40e_add_pd_table_entry(struct i40e_hw *hw,
-					      struct i40e_hmc_info *hmc_info,
-					      u32 pd_index);
+				    struct i40e_hmc_info *hmc_info,
+				    u32 pd_index);
 i40e_status i40e_remove_pd_bp(struct i40e_hw *hw,
-					struct i40e_hmc_info *hmc_info,
-					u32 idx, bool is_pf);
-i40e_status i40e_prep_remove_sd_bp(struct i40e_hmc_info *hmc_info,
-					     u32 idx);
+			      struct i40e_hmc_info *hmc_info,
+			      u32 idx, bool is_pf);
+i40e_status i40e_prep_remove_sd_bp(struct i40e_hmc_info *hmc_info, u32 idx);
 i40e_status i40e_remove_sd_bp_new(struct i40e_hw *hw,
-					    struct i40e_hmc_info *hmc_info,
-					    u32 idx, bool is_pf);
-i40e_status i40e_prep_remove_pd_page(struct i40e_hmc_info *hmc_info,
-					       u32 idx);
+				  struct i40e_hmc_info *hmc_info,
+				  u32 idx, bool is_pf);
+i40e_status i40e_prep_remove_pd_page(struct i40e_hmc_info *hmc_info, u32 idx);
 i40e_status i40e_remove_pd_page_new(struct i40e_hw *hw,
-					      struct i40e_hmc_info *hmc_info,
-					      u32 idx, bool is_pf);
+				    struct i40e_hmc_info *hmc_info,
+				    u32 idx, bool is_pf);
 
 #endif /* _I40E_HMC_H_ */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_lan_hmc.h b/drivers/net/ethernet/intel/i40evf/i40e_lan_hmc.h
index 17e42ca..14439bd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_lan_hmc.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_lan_hmc.h
@@ -145,21 +145,17 @@ struct i40e_hmc_lan_delete_obj_info {
 };
 
 i40e_status i40e_init_lan_hmc(struct i40e_hw *hw, u32 txq_num,
-					u32 rxq_num, u32 fcoe_cntx_num,
-					u32 fcoe_filt_num);
+			      u32 rxq_num, u32 fcoe_cntx_num,
+			      u32 fcoe_filt_num);
 i40e_status i40e_configure_lan_hmc(struct i40e_hw *hw,
-					     enum i40e_hmc_model model);
+				   enum i40e_hmc_model model);
 i40e_status i40e_shutdown_lan_hmc(struct i40e_hw *hw);
 
-i40e_status i40e_clear_lan_tx_queue_context(struct i40e_hw *hw,
-						      u16 queue);
-i40e_status i40e_set_lan_tx_queue_context(struct i40e_hw *hw,
-						    u16 queue,
-						    struct i40e_hmc_obj_txq *s);
-i40e_status i40e_clear_lan_rx_queue_context(struct i40e_hw *hw,
-						      u16 queue);
-i40e_status i40e_set_lan_rx_queue_context(struct i40e_hw *hw,
-						    u16 queue,
-						    struct i40e_hmc_obj_rxq *s);
+i40e_status i40e_clear_lan_tx_queue_context(struct i40e_hw *hw, u16 queue);
+i40e_status i40e_set_lan_tx_queue_context(struct i40e_hw *hw, u16 queue,
+					  struct i40e_hmc_obj_txq *s);
+i40e_status i40e_clear_lan_rx_queue_context(struct i40e_hw *hw, u16 queue);
+i40e_status i40e_set_lan_rx_queue_context(struct i40e_hw *hw, u16 queue,
+					  struct i40e_hmc_obj_rxq *s);
 
 #endif /* _I40E_LAN_HMC_H_ */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
index 862fcdf..1c5a9cb 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
@@ -40,26 +40,23 @@ i40e_status i40evf_init_adminq(struct i40e_hw *hw);
 i40e_status i40evf_shutdown_adminq(struct i40e_hw *hw);
 void i40e_adminq_init_ring_data(struct i40e_hw *hw);
 i40e_status i40evf_clean_arq_element(struct i40e_hw *hw,
-					     struct i40e_arq_event_info *e,
-					     u16 *events_pending);
+				     struct i40e_arq_event_info *e,
+				     u16 *events_pending);
 i40e_status i40evf_asq_send_command(struct i40e_hw *hw,
-				struct i40e_aq_desc *desc,
-				void *buff, /* can be NULL */
-				u16  buff_size,
-				struct i40e_asq_cmd_details *cmd_details);
+				    struct i40e_aq_desc *desc,
+				    void *buff, /* can be NULL */
+				    u16  buff_size,
+				    struct i40e_asq_cmd_details *cmd_details);
 bool i40evf_asq_done(struct i40e_hw *hw);
 
 /* debug function for adminq */
-void i40evf_debug_aq(struct i40e_hw *hw,
-		   enum i40e_debug_mask mask,
-		   void *desc,
-		   void *buffer);
+void i40evf_debug_aq(struct i40e_hw *hw, enum i40e_debug_mask mask,
+		     void *desc, void *buffer);
 
 void i40e_idle_aq(struct i40e_hw *hw);
 void i40evf_resume_aq(struct i40e_hw *hw);
 bool i40evf_check_asq_alive(struct i40e_hw *hw);
-i40e_status i40evf_aq_queue_shutdown(struct i40e_hw *hw,
-					     bool unloading);
+i40e_status i40evf_aq_queue_shutdown(struct i40e_hw *hw, bool unloading);
 
 i40e_status i40e_set_mac_type(struct i40e_hw *hw);
 
@@ -77,15 +74,15 @@ void i40e_vf_parse_hw_config(struct i40e_hw *hw,
 			     struct i40e_virtchnl_vf_resource *msg);
 i40e_status i40e_vf_reset(struct i40e_hw *hw);
 i40e_status i40e_aq_send_msg_to_pf(struct i40e_hw *hw,
-				enum i40e_virtchnl_ops v_opcode,
-				i40e_status v_retval,
-				u8 *msg, u16 msglen,
-				struct i40e_asq_cmd_details *cmd_details);
+				   enum i40e_virtchnl_ops v_opcode,
+				   i40e_status v_retval,
+				   u8 *msg, u16 msglen,
+				   struct i40e_asq_cmd_details *cmd_details);
 i40e_status i40e_set_filter_control(struct i40e_hw *hw,
-				struct i40e_filter_control_settings *settings);
+				    struct i40e_filter_control_settings *settings);
 i40e_status i40e_aq_add_rem_control_packet_filter(struct i40e_hw *hw,
-				u8 *mac_addr, u16 ethtype, u16 flags,
-				u16 vsi_seid, u16 queue, bool is_add,
-				struct i40e_control_filter_stats *stats,
-				struct i40e_asq_cmd_details *cmd_details);
+						  u8 *mac_addr, u16 ethtype, u16 flags,
+						  u16 vsi_seid, u16 queue, bool is_add,
+						  struct i40e_control_filter_stats *stats,
+						  struct i40e_asq_cmd_details *cmd_details);
 #endif /* _I40E_PROTOTYPE_H_ */
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index 8b0db1c..793c872 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -216,7 +216,7 @@ static void i40evf_get_drvinfo(struct net_device *netdev,
  * but the number of rings is not reported.
  **/
 static void i40evf_get_ringparam(struct net_device *netdev,
-				  struct ethtool_ringparam *ring)
+				 struct ethtool_ringparam *ring)
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 	struct i40e_ring *tx_ring = adapter->tx_rings[0];
@@ -281,7 +281,7 @@ static int i40evf_set_ringparam(struct net_device *netdev,
  * this functionality.
  **/
 static int i40evf_get_coalesce(struct net_device *netdev,
-			     struct ethtool_coalesce *ec)
+			       struct ethtool_coalesce *ec)
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 	struct i40e_vsi *vsi = &adapter->vsi;
@@ -310,7 +310,7 @@ static int i40evf_get_coalesce(struct net_device *netdev,
  * Change current coalescing settings.
  **/
 static int i40evf_set_coalesce(struct net_device *netdev,
-			     struct ethtool_coalesce *ec)
+			       struct ethtool_coalesce *ec)
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 	struct i40e_hw *hw = &adapter->hw;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index d3eafa3..3e057cd 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -251,8 +251,7 @@ void i40evf_irq_enable_queues(struct i40evf_adapter *adapter, u32 mask)
  * @adapter: board private structure
  * @mask: bitmap of vectors to trigger
  **/
-static void i40evf_fire_sw_int(struct i40evf_adapter *adapter,
-					    u32 mask)
+static void i40evf_fire_sw_int(struct i40evf_adapter *adapter, u32 mask)
 {
 	struct i40e_hw *hw = &adapter->hw;
 	int i;
@@ -699,7 +698,7 @@ static void i40evf_del_vlan(struct i40evf_adapter *adapter, u16 vlan)
  * @vid: VLAN tag
  **/
 static int i40evf_vlan_rx_add_vid(struct net_device *netdev,
-			 __always_unused __be16 proto, u16 vid)
+				  __always_unused __be16 proto, u16 vid)
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 
@@ -714,7 +713,7 @@ static int i40evf_vlan_rx_add_vid(struct net_device *netdev,
  * @vid: VLAN tag
  **/
 static int i40evf_vlan_rx_kill_vid(struct net_device *netdev,
-			  __always_unused __be16 proto, u16 vid)
+				   __always_unused __be16 proto, u16 vid)
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 
@@ -1185,7 +1184,7 @@ static int i40evf_alloc_q_vectors(struct i40evf_adapter *adapter)
 		q_vector->vsi = &adapter->vsi;
 		q_vector->v_idx = q_idx;
 		netif_napi_add(adapter->netdev, &q_vector->napi,
-				       i40evf_napi_poll, 64);
+			       i40evf_napi_poll, 64);
 		adapter->q_vector[q_idx] = q_vector;
 	}
 
@@ -1273,8 +1272,8 @@ int i40evf_init_interrupt_scheme(struct i40evf_adapter *adapter)
 	}
 
 	dev_info(&adapter->pdev->dev, "Multiqueue %s: Queue pair count = %u",
-		(adapter->vsi_res->num_queue_pairs > 1) ? "Enabled" :
-		"Disabled", adapter->vsi_res->num_queue_pairs);
+		 adapter->vsi_res->num_queue_pairs > 1 ? "Enabled" : "Disabled",
+		 adapter->vsi_res->num_queue_pairs);
 
 	return 0;
 err_alloc_queues:
@@ -1540,12 +1539,12 @@ continue_reset:
 	/* kill and reinit the admin queue */
 	if (i40evf_shutdown_adminq(hw))
 		dev_warn(&adapter->pdev->dev,
-			"%s: Failed to destroy the Admin Queue resources\n",
-			__func__);
+			 "%s: Failed to destroy the Admin Queue resources\n",
+			 __func__);
 	err = i40evf_init_adminq(hw);
 	if (err)
 		dev_info(&adapter->pdev->dev, "%s: init_adminq failed: %d\n",
-			__func__, err);
+			 __func__, err);
 
 	adapter->aq_pending = 0;
 	adapter->aq_required = 0;
@@ -1600,7 +1599,7 @@ static void i40evf_adminq_task(struct work_struct *work)
 	event.msg_buf = kzalloc(event.msg_size, GFP_KERNEL);
 	if (!event.msg_buf) {
 		dev_info(&adapter->pdev->dev, "%s: no memory for ARQ clean\n",
-				 __func__);
+			 __func__);
 		return;
 	}
 	v_msg = (struct i40e_virtchnl_msg *)&event.desc;
@@ -2412,8 +2411,8 @@ static struct pci_driver i40evf_driver = {
 static int __init i40evf_init_module(void)
 {
 	int ret;
-	pr_info("i40evf: %s - version %s\n", i40evf_driver_string,
-	       i40evf_driver_version);
+	pr_info("i40evf: %s - version %s\n",
+		i40evf_driver_string, i40evf_driver_version);
 
 	pr_info("%s\n", i40evf_copyright);
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index e294f01..f3a47a7 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -391,7 +391,7 @@ void i40evf_add_ether_addrs(struct i40evf_adapter *adapter)
 	      (count * sizeof(struct i40e_virtchnl_ether_addr));
 	if (len > I40EVF_MAX_AQ_BUF_SIZE) {
 		dev_warn(&adapter->pdev->dev, "%s: Too many MAC address changes in one request.\n",
-			__func__);
+			 __func__);
 		count = (I40EVF_MAX_AQ_BUF_SIZE -
 			 sizeof(struct i40e_virtchnl_ether_addr_list)) /
 			sizeof(struct i40e_virtchnl_ether_addr);
@@ -455,7 +455,7 @@ void i40evf_del_ether_addrs(struct i40evf_adapter *adapter)
 	      (count * sizeof(struct i40e_virtchnl_ether_addr));
 	if (len > I40EVF_MAX_AQ_BUF_SIZE) {
 		dev_warn(&adapter->pdev->dev, "%s: Too many MAC address changes in one request.\n",
-			__func__);
+			 __func__);
 		count = (I40EVF_MAX_AQ_BUF_SIZE -
 			 sizeof(struct i40e_virtchnl_ether_addr_list)) /
 			sizeof(struct i40e_virtchnl_ether_addr);
@@ -519,7 +519,7 @@ void i40evf_add_vlans(struct i40evf_adapter *adapter)
 	      (count * sizeof(u16));
 	if (len > I40EVF_MAX_AQ_BUF_SIZE) {
 		dev_warn(&adapter->pdev->dev, "%s: Too many VLAN changes in one request.\n",
-			__func__);
+			 __func__);
 		count = (I40EVF_MAX_AQ_BUF_SIZE -
 			 sizeof(struct i40e_virtchnl_vlan_filter_list)) /
 			sizeof(u16);
@@ -581,7 +581,7 @@ void i40evf_del_vlans(struct i40evf_adapter *adapter)
 	      (count * sizeof(u16));
 	if (len > I40EVF_MAX_AQ_BUF_SIZE) {
 		dev_warn(&adapter->pdev->dev, "%s: Too many VLAN changes in one request.\n",
-			__func__);
+			 __func__);
 		count = (I40EVF_MAX_AQ_BUF_SIZE -
 			 sizeof(struct i40e_virtchnl_vlan_filter_list)) /
 			sizeof(u16);
@@ -782,7 +782,7 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 		break;
 	default:
 		dev_warn(&adapter->pdev->dev, "%s: Received unexpected message %d from PF.\n",
-			__func__, v_opcode);
+			 __func__, v_opcode);
 		break;
 	} /* switch v_opcode */
 	adapter->current_op = I40E_VIRTCHNL_OP_UNKNOWN;
diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index fa36fe1..0bf75650 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -61,7 +61,7 @@ static s32  igb_write_phy_reg_sgmii_82575(struct e1000_hw *, u32, u16);
 static void igb_clear_hw_cntrs_82575(struct e1000_hw *);
 static s32  igb_acquire_swfw_sync_82575(struct e1000_hw *, u16);
 static s32  igb_get_pcs_speed_and_duplex_82575(struct e1000_hw *, u16 *,
-						 u16 *);
+					       u16 *);
 static s32  igb_get_phy_id_82575(struct e1000_hw *);
 static void igb_release_swfw_sync_82575(struct e1000_hw *, u16);
 static bool igb_sgmii_active_82575(struct e1000_hw *);
@@ -480,8 +480,8 @@ static s32 igb_set_sfp_media_type_82575(struct e1000_hw *hw)
 	/* Read SFP module data */
 	while (timeout) {
 		ret_val = igb_read_sfp_data_byte(hw,
-			E1000_I2CCMD_SFP_DATA_ADDR(E1000_SFF_IDENTIFIER_OFFSET),
-			&tranceiver_type);
+						 E1000_I2CCMD_SFP_DATA_ADDR(E1000_SFF_IDENTIFIER_OFFSET),
+						 &tranceiver_type);
 		if (ret_val == 0)
 			break;
 		msleep(100);
@@ -491,8 +491,8 @@ static s32 igb_set_sfp_media_type_82575(struct e1000_hw *hw)
 		goto out;
 
 	ret_val = igb_read_sfp_data_byte(hw,
-			E1000_I2CCMD_SFP_DATA_ADDR(E1000_SFF_ETH_FLAGS_OFFSET),
-			(u8 *)eth_flags);
+					 E1000_I2CCMD_SFP_DATA_ADDR(E1000_SFF_ETH_FLAGS_OFFSET),
+					 (u8 *)eth_flags);
 	if (ret_val != 0)
 		goto out;
 
@@ -737,7 +737,7 @@ static void igb_release_phy_82575(struct e1000_hw *hw)
  *  interface and stores the retrieved information in data.
  **/
 static s32 igb_read_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
-					  u16 *data)
+					u16 *data)
 {
 	s32 ret_val = -E1000_ERR_PARAM;
 
@@ -768,7 +768,7 @@ out:
  *  media independent interface.
  **/
 static s32 igb_write_phy_reg_sgmii_82575(struct e1000_hw *hw, u32 offset,
-					   u16 data)
+					 u16 data)
 {
 	s32 ret_val = -E1000_ERR_PARAM;
 
@@ -1241,16 +1241,16 @@ static s32 igb_get_cfg_done_82575(struct e1000_hw *hw)
  *  Otherwise, use the generic function to get the link speed and duplex info.
  **/
 static s32 igb_get_link_up_info_82575(struct e1000_hw *hw, u16 *speed,
-					u16 *duplex)
+				      u16 *duplex)
 {
 	s32 ret_val;
 
 	if (hw->phy.media_type != e1000_media_type_copper)
 		ret_val = igb_get_pcs_speed_and_duplex_82575(hw, speed,
-							       duplex);
+							     duplex);
 	else
 		ret_val = igb_get_speed_and_duplex_copper(hw, speed,
-								    duplex);
+							  duplex);
 
 	return ret_val;
 }
@@ -1329,7 +1329,7 @@ void igb_power_up_serdes_link_82575(struct e1000_hw *hw)
  *  duplex, then store the values in the pointers provided.
  **/
 static s32 igb_get_pcs_speed_and_duplex_82575(struct e1000_hw *hw, u16 *speed,
-						u16 *duplex)
+					      u16 *duplex)
 {
 	struct e1000_mac_info *mac = &hw->mac;
 	u32 pcs, status;
@@ -2245,11 +2245,11 @@ static s32 igb_reset_hw_82580(struct e1000_hw *hw)
 
 	/* Determine whether or not a global dev reset is requested */
 	if (global_device_reset &&
-		hw->mac.ops.acquire_swfw_sync(hw, swmbsw_mask))
-			global_device_reset = false;
+	    hw->mac.ops.acquire_swfw_sync(hw, swmbsw_mask))
+		global_device_reset = false;
 
 	if (global_device_reset &&
-		!(rd32(E1000_STATUS) & E1000_STAT_DEV_RST_SET))
+	    !(rd32(E1000_STATUS) & E1000_STAT_DEV_RST_SET))
 		ctrl |= E1000_CTRL_DEV_RST;
 	else
 		ctrl |= E1000_CTRL_RST;
@@ -2523,7 +2523,7 @@ out:
  *  @read: boolean flag to indicate read or write
  **/
 static s32 __igb_access_emi_reg(struct e1000_hw *hw, u16 address,
-				  u16 *data, bool read)
+				u16 *data, bool read)
 {
 	s32 ret_val = E1000_SUCCESS;
 
@@ -2645,8 +2645,8 @@ s32 igb_set_eee_i354(struct e1000_hw *hw)
 		phy_data |= E1000_EEE_ADV_100_SUPPORTED |
 			    E1000_EEE_ADV_1000_SUPPORTED;
 		ret_val = igb_write_xmdio_reg(hw, E1000_EEE_ADV_ADDR_I354,
-						E1000_EEE_ADV_DEV_I354,
-						phy_data);
+					      E1000_EEE_ADV_DEV_I354,
+					      phy_data);
 	} else {
 		/* Turn off EEE advertisement. */
 		ret_val = igb_read_xmdio_reg(hw, E1000_EEE_ADV_ADDR_I354,
diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.c b/drivers/net/ethernet/intel/igb/e1000_i210.c
index db96339..fbb458e 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.c
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.c
@@ -222,7 +222,7 @@ static s32 igb_read_nvm_srrd_i210(struct e1000_hw *hw, u16 offset, u16 words,
 			E1000_EERD_EEWR_MAX_COUNT : (words - i);
 		if (hw->nvm.ops.acquire(hw) == E1000_SUCCESS) {
 			status = igb_read_nvm_eerd(hw, offset, count,
-						     data + i);
+						   data + i);
 			hw->nvm.ops.release(hw);
 		} else {
 			status = E1000_ERR_SWFW_SYNC;
@@ -248,7 +248,7 @@ static s32 igb_read_nvm_srrd_i210(struct e1000_hw *hw, u16 offset, u16 words,
  *  Shadow Ram will most likely contain an invalid checksum.
  **/
 static s32 igb_write_nvm_srwr(struct e1000_hw *hw, u16 offset, u16 words,
-				u16 *data)
+			      u16 *data)
 {
 	struct e1000_nvm_info *nvm = &hw->nvm;
 	u32 i, k, eewr = 0;
@@ -322,7 +322,7 @@ static s32 igb_write_nvm_srwr_i210(struct e1000_hw *hw, u16 offset, u16 words,
 			E1000_EERD_EEWR_MAX_COUNT : (words - i);
 		if (hw->nvm.ops.acquire(hw) == E1000_SUCCESS) {
 			status = igb_write_nvm_srwr(hw, offset, count,
-						      data + i);
+						    data + i);
 			hw->nvm.ops.release(hw);
 		} else {
 			status = E1000_ERR_SWFW_SYNC;
@@ -366,7 +366,7 @@ static s32 igb_read_invm_word_i210(struct e1000_hw *hw, u8 address, u16 *data)
 			if (word_address == address) {
 				*data = INVM_DWORD_TO_WORD_DATA(invm_dword);
 				hw_dbg("Read INVM Word 0x%02x = %x",
-					  address, *data);
+				       address, *data);
 				status = E1000_SUCCESS;
 				break;
 			}
@@ -386,7 +386,7 @@ static s32 igb_read_invm_word_i210(struct e1000_hw *hw, u8 address, u16 *data)
  *  Wrapper function to return data formerly found in the NVM.
  **/
 static s32 igb_read_invm_i210(struct e1000_hw *hw, u16 offset,
-				u16 words __always_unused, u16 *data)
+			      u16 words __always_unused, u16 *data)
 {
 	s32 ret_val = E1000_SUCCESS;
 
@@ -502,8 +502,8 @@ s32 igb_read_invm_version(struct e1000_hw *hw,
 		 * used and it is the last one used
 		 */
 		else if ((((*record & E1000_INVM_VER_FIELD_ONE) == 0) &&
-			 ((*record & 0x3) == 0)) || (((*record & 0x3) != 0) &&
-			 (i != 1))) {
+			  ((*record & 0x3) == 0)) || (((*record & 0x3) != 0) &&
+						      (i != 1))) {
 			version = (*next_record & E1000_INVM_VER_FIELD_TWO)
 				  >> 13;
 			status = E1000_SUCCESS;
@@ -538,7 +538,7 @@ s32 igb_read_invm_version(struct e1000_hw *hw,
 		}
 		/* Check if we have image type in first location used */
 		else if ((((*record & 0x3) == 0) &&
-			 ((*record & E1000_INVM_IMGTYPE_FIELD) == 0)) ||
+			  ((*record & E1000_INVM_IMGTYPE_FIELD) == 0)) ||
 			 ((((*record & 0x3) != 0) && (i != 1)))) {
 			invm_ver->invm_img_type =
 				(*next_record & E1000_INVM_IMGTYPE_FIELD) >> 23;
@@ -624,7 +624,7 @@ static s32 igb_update_nvm_checksum_i210(struct e1000_hw *hw)
 		}
 		checksum = (u16) NVM_SUM - checksum;
 		ret_val = igb_write_nvm_srwr(hw, NVM_CHECKSUM_REG, 1,
-						&checksum);
+					     &checksum);
 		if (ret_val != E1000_SUCCESS) {
 			hw->nvm.ops.release(hw);
 			hw_dbg("NVM Write Error while updating checksum.\n");
diff --git a/drivers/net/ethernet/intel/igb/e1000_mac.c b/drivers/net/ethernet/intel/igb/e1000_mac.c
index 5910a93..c817c66 100644
--- a/drivers/net/ethernet/intel/igb/e1000_mac.c
+++ b/drivers/net/ethernet/intel/igb/e1000_mac.c
@@ -944,9 +944,9 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 		 *   0   |    1    |   1   |    1    | e1000_fc_tx_pause
 		 */
 		else if (!(mii_nway_adv_reg & NWAY_AR_PAUSE) &&
-			  (mii_nway_adv_reg & NWAY_AR_ASM_DIR) &&
-			  (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
-			  (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
+			 (mii_nway_adv_reg & NWAY_AR_ASM_DIR) &&
+			 (mii_nway_lp_ability_reg & NWAY_LPAR_PAUSE) &&
+			 (mii_nway_lp_ability_reg & NWAY_LPAR_ASM_DIR)) {
 			hw->fc.current_mode = e1000_fc_tx_pause;
 			hw_dbg("Flow Control = TX PAUSE frames only.\r\n");
 		}
@@ -1099,9 +1099,9 @@ s32 igb_config_fc_after_link_up(struct e1000_hw *hw)
 		 *   0   |    1    |   1   |    1    | e1000_fc_tx_pause
 		 */
 		else if (!(pcs_adv_reg & E1000_TXCW_PAUSE) &&
-			  (pcs_adv_reg & E1000_TXCW_ASM_DIR) &&
-			  (pcs_lp_ability_reg & E1000_TXCW_PAUSE) &&
-			  (pcs_lp_ability_reg & E1000_TXCW_ASM_DIR)) {
+			 (pcs_adv_reg & E1000_TXCW_ASM_DIR) &&
+			 (pcs_lp_ability_reg & E1000_TXCW_PAUSE) &&
+			 (pcs_lp_ability_reg & E1000_TXCW_ASM_DIR)) {
 			hw->fc.current_mode = e1000_fc_tx_pause;
 			hw_dbg("Flow Control = Tx PAUSE frames only.\n");
 		}
@@ -1154,7 +1154,7 @@ out:
  *  speed and duplex for copper connections.
  **/
 s32 igb_get_speed_and_duplex_copper(struct e1000_hw *hw, u16 *speed,
-				      u16 *duplex)
+				    u16 *duplex)
 {
 	u32 status;
 
@@ -1540,8 +1540,7 @@ out:
  *  and they all have the format address << 8 | data and bit 31 is polled for
  *  completion.
  **/
-s32 igb_write_8bit_ctrl_reg(struct e1000_hw *hw, u32 reg,
-			      u32 offset, u8 data)
+s32 igb_write_8bit_ctrl_reg(struct e1000_hw *hw, u32 reg, u32 offset, u8 data)
 {
 	u32 i, regvalue = 0;
 	s32 ret_val = 0;
diff --git a/drivers/net/ethernet/intel/igb/e1000_nvm.c b/drivers/net/ethernet/intel/igb/e1000_nvm.c
index 9abf829..4ab5432 100644
--- a/drivers/net/ethernet/intel/igb/e1000_nvm.c
+++ b/drivers/net/ethernet/intel/igb/e1000_nvm.c
@@ -462,7 +462,7 @@ s32 igb_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 
 		/* Send the WRITE ENABLE command (8 bit opcode) */
 		igb_shift_out_eec_bits(hw, NVM_WREN_OPCODE_SPI,
-					 nvm->opcode_bits);
+				       nvm->opcode_bits);
 
 		igb_standby_nvm(hw);
 
@@ -475,7 +475,7 @@ s32 igb_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
 		/* Send the Write command (8-bit opcode + addr) */
 		igb_shift_out_eec_bits(hw, write_opcode, nvm->opcode_bits);
 		igb_shift_out_eec_bits(hw, (u16)((offset + widx) * 2),
-					 nvm->address_bits);
+				       nvm->address_bits);
 
 		/* Loop to allow for up to whole page write of eeprom */
 		while (widx < words) {
diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.c b/drivers/net/ethernet/intel/igb/e1000_phy.c
index 4009bba..2901f0f2 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.c
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.c
@@ -301,8 +301,7 @@ s32 igb_write_phy_reg_i2c(struct e1000_hw *hw, u32 offset, u16 data)
 
 	/* Prevent overwritting SFP I2C EEPROM which is at A0 address.*/
 	if ((hw->phy.addr == 0) || (hw->phy.addr > 7)) {
-		hw_dbg("PHY I2C Address %d is out of range.\n",
-			  hw->phy.addr);
+		hw_dbg("PHY I2C Address %d is out of range.\n", hw->phy.addr);
 		return -E1000_ERR_CONFIG;
 	}
 
diff --git a/drivers/net/ethernet/intel/igb/e1000_phy.h b/drivers/net/ethernet/intel/igb/e1000_phy.h
index 4c2c36c..8485225 100644
--- a/drivers/net/ethernet/intel/igb/e1000_phy.h
+++ b/drivers/net/ethernet/intel/igb/e1000_phy.h
@@ -60,7 +60,7 @@ s32  igb_set_d3_lplu_state(struct e1000_hw *hw, bool active);
 s32  igb_setup_copper_link(struct e1000_hw *hw);
 s32  igb_write_phy_reg_igp(struct e1000_hw *hw, u32 offset, u16 data);
 s32  igb_phy_has_link(struct e1000_hw *hw, u32 iterations,
-				u32 usec_interval, bool *success);
+		      u32 usec_interval, bool *success);
 void igb_power_up_phy_copper(struct e1000_hw *hw);
 void igb_power_down_phy_copper(struct e1000_hw *hw);
 s32  igb_phy_init_script_igp3(struct e1000_hw *hw);
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index e5570ac..e3ac405 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -753,8 +753,7 @@ static int igb_get_eeprom(struct net_device *netdev,
 	for (i = 0; i < last_word - first_word + 1; i++)
 		le16_to_cpus(&eeprom_buff[i]);
 
-	memcpy(bytes, (u8 *)eeprom_buff + (eeprom->offset & 1),
-			eeprom->len);
+	memcpy(bytes, (u8 *)eeprom_buff + (eeprom->offset & 1), eeprom->len);
 	kfree(eeprom_buff);
 
 	return ret_val;
@@ -1314,23 +1313,20 @@ static int igb_reg_test(struct igb_adapter *adapter, u64 *data)
 				break;
 			case WRITE_NO_TEST:
 				writel(test->write,
-				    (adapter->hw.hw_addr + test->reg)
-					+ (i * test->reg_offset));
+				       (adapter->hw.hw_addr + test->reg) +
+				       (i * test->reg_offset));
 				break;
 			case TABLE32_TEST:
 				REG_PATTERN_TEST(test->reg + (i * 4),
-						test->mask,
-						test->write);
+						 test->mask, test->write);
 				break;
 			case TABLE64_TEST_LO:
 				REG_PATTERN_TEST(test->reg + (i * 8),
-						test->mask,
-						test->write);
+						 test->mask, test->write);
 				break;
 			case TABLE64_TEST_HI:
 				REG_PATTERN_TEST((test->reg + 4) + (i * 8),
-						test->mask,
-						test->write);
+						 test->mask, test->write);
 				break;
 			}
 		}
@@ -1407,7 +1403,7 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 		return -1;
 	}
 	dev_info(&adapter->pdev->dev, "testing %s interrupt\n",
-		(shared_int ? "shared" : "unshared"));
+		 shared_int ? "shared" : "unshared");
 
 	/* Disable all the interrupts */
 	wr32(E1000_IMC, ~0);
@@ -1661,10 +1657,10 @@ static int igb_setup_loopback_test(struct igb_adapter *adapter)
 	/* use CTRL_EXT to identify link type as SGMII can appear as copper */
 	if (reg & E1000_CTRL_EXT_LINK_MODE_MASK) {
 		if ((hw->device_id == E1000_DEV_ID_DH89XXCC_SGMII) ||
-		(hw->device_id == E1000_DEV_ID_DH89XXCC_SERDES) ||
-		(hw->device_id == E1000_DEV_ID_DH89XXCC_BACKPLANE) ||
-		(hw->device_id == E1000_DEV_ID_DH89XXCC_SFP) ||
-		(hw->device_id == E1000_DEV_ID_I354_SGMII)) {
+		    (hw->device_id == E1000_DEV_ID_DH89XXCC_SERDES) ||
+		    (hw->device_id == E1000_DEV_ID_DH89XXCC_BACKPLANE) ||
+		    (hw->device_id == E1000_DEV_ID_DH89XXCC_SFP) ||
+		    (hw->device_id == E1000_DEV_ID_I354_SGMII)) {
 
 			/* Enable DH89xxCC MPHY for near end loopback */
 			reg = rd32(E1000_MPHY_ADDR_CTL);
@@ -1728,10 +1724,10 @@ static void igb_loopback_cleanup(struct igb_adapter *adapter)
 	u16 phy_reg;
 
 	if ((hw->device_id == E1000_DEV_ID_DH89XXCC_SGMII) ||
-	(hw->device_id == E1000_DEV_ID_DH89XXCC_SERDES) ||
-	(hw->device_id == E1000_DEV_ID_DH89XXCC_BACKPLANE) ||
-	(hw->device_id == E1000_DEV_ID_DH89XXCC_SFP) ||
-	(hw->device_id == E1000_DEV_ID_I354_SGMII)) {
+	    (hw->device_id == E1000_DEV_ID_DH89XXCC_SERDES) ||
+	    (hw->device_id == E1000_DEV_ID_DH89XXCC_BACKPLANE) ||
+	    (hw->device_id == E1000_DEV_ID_DH89XXCC_SFP) ||
+	    (hw->device_id == E1000_DEV_ID_I354_SGMII)) {
 		u32 reg;
 
 		/* Disable near end loopback on DH89xxCC */
@@ -1924,7 +1920,7 @@ static int igb_loopback_test(struct igb_adapter *adapter, u64 *data)
 
 	if (adapter->hw.mac.type == e1000_i354) {
 		dev_info(&adapter->pdev->dev,
-			"Loopback test not supported on i354.\n");
+			 "Loopback test not supported on i354.\n");
 		*data = 0;
 		goto out;
 	}
@@ -2309,8 +2305,7 @@ static void igb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 
 	switch (stringset) {
 	case ETH_SS_TEST:
-		memcpy(data, *igb_gstrings_test,
-			IGB_TEST_LEN*ETH_GSTRING_LEN);
+		memcpy(data, *igb_gstrings_test, IGB_TEST_LEN*ETH_GSTRING_LEN);
 		break;
 	case ETH_SS_STATS:
 		for (i = 0; i < IGB_GLOBAL_STATS_LEN; i++) {
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index cd20409..0f2ace1 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -197,7 +197,7 @@ static int igb_runtime_idle(struct device *dev);
 static const struct dev_pm_ops igb_pm_ops = {
 	SET_SYSTEM_SLEEP_PM_OPS(igb_suspend, igb_resume)
 	SET_RUNTIME_PM_OPS(igb_runtime_suspend, igb_runtime_resume,
-			igb_runtime_idle)
+			   igb_runtime_idle)
 };
 #endif
 static void igb_shutdown(struct pci_dev *);
@@ -222,7 +222,7 @@ MODULE_PARM_DESC(max_vfs, "Maximum number of virtual functions to allocate "
 #endif /* CONFIG_PCI_IOV */
 
 static pci_ers_result_t igb_io_error_detected(struct pci_dev *,
-		     pci_channel_state_t);
+					      pci_channel_state_t);
 static pci_ers_result_t igb_io_slot_reset(struct pci_dev *);
 static void igb_io_resume(struct pci_dev *);
 
@@ -470,10 +470,10 @@ static void igb_dump(struct igb_adapter *adapter)
 
 			if (netif_msg_pktdata(adapter) && buffer_info->skb)
 				print_hex_dump(KERN_INFO, "",
-					DUMP_PREFIX_ADDRESS,
-					16, 1, buffer_info->skb->data,
-					dma_unmap_len(buffer_info, len),
-					true);
+					       DUMP_PREFIX_ADDRESS,
+					       16, 1, buffer_info->skb->data,
+					       dma_unmap_len(buffer_info, len),
+					       true);
 		}
 	}
 
@@ -557,11 +557,11 @@ rx_ring_summary:
 				if (netif_msg_pktdata(adapter) &&
 				    buffer_info->dma && buffer_info->page) {
 					print_hex_dump(KERN_INFO, "",
-					  DUMP_PREFIX_ADDRESS,
-					  16, 1,
-					  page_address(buffer_info->page) +
-						      buffer_info->page_offset,
-					  IGB_RX_BUFSZ, true);
+						       DUMP_PREFIX_ADDRESS,
+						       16, 1,
+						       page_address(buffer_info->page) +
+						       buffer_info->page_offset,
+						       IGB_RX_BUFSZ, true);
 				}
 			}
 		}
@@ -682,7 +682,7 @@ static int __init igb_init_module(void)
 {
 	int ret;
 	pr_info("%s - version %s\n",
-	       igb_driver_string, igb_driver_version);
+		igb_driver_string, igb_driver_version);
 
 	pr_info("%s\n", igb_copyright);
 
@@ -1568,7 +1568,7 @@ static void igb_release_hw_control(struct igb_adapter *adapter)
 	/* Let firmware take over control of h/w */
 	ctrl_ext = rd32(E1000_CTRL_EXT);
 	wr32(E1000_CTRL_EXT,
-			ctrl_ext & ~E1000_CTRL_EXT_DRV_LOAD);
+	     ctrl_ext & ~E1000_CTRL_EXT_DRV_LOAD);
 }
 
 /**
@@ -1587,7 +1587,7 @@ static void igb_get_hw_control(struct igb_adapter *adapter)
 	/* Let firmware know the driver has taken over */
 	ctrl_ext = rd32(E1000_CTRL_EXT);
 	wr32(E1000_CTRL_EXT,
-			ctrl_ext | E1000_CTRL_EXT_DRV_LOAD);
+	     ctrl_ext | E1000_CTRL_EXT_DRV_LOAD);
 }
 
 /**
@@ -1693,7 +1693,7 @@ static void igb_check_swap_media(struct igb_adapter *adapter)
 	switch (hw->phy.media_type) {
 	case e1000_media_type_copper:
 		netdev_info(adapter->netdev,
-			"MAS: changing media to fiber/serdes\n");
+			    "MAS: changing media to fiber/serdes\n");
 		ctrl_ext |=
 			E1000_CTRL_EXT_LINK_MODE_PCIE_SERDES;
 		adapter->flags |= IGB_FLAG_MEDIA_RESET;
@@ -1702,7 +1702,7 @@ static void igb_check_swap_media(struct igb_adapter *adapter)
 	case e1000_media_type_internal_serdes:
 	case e1000_media_type_fiber:
 		netdev_info(adapter->netdev,
-			"MAS: changing media to copper\n");
+			    "MAS: changing media to copper\n");
 		ctrl_ext &=
 			~E1000_CTRL_EXT_LINK_MODE_PCIE_SERDES;
 		adapter->flags |= IGB_FLAG_MEDIA_RESET;
@@ -1710,7 +1710,7 @@ static void igb_check_swap_media(struct igb_adapter *adapter)
 	default:
 		/* shouldn't get here during regular operation */
 		netdev_err(adapter->netdev,
-			"AMS: Invalid media type found, returning\n");
+			   "AMS: Invalid media type found, returning\n");
 		break;
 	}
 	wr32(E1000_CTRL_EXT, ctrl_ext);
@@ -1858,7 +1858,7 @@ static s32 igb_enable_mas(struct igb_adapter *adapter)
 		return ret_val;
 	} else {
 		netdev_info(adapter->netdev,
-			"MAS: Unable to configure feature, disabling..\n");
+			    "MAS: Unable to configure feature, disabling..\n");
 		adapter->flags &= ~IGB_FLAG_MAS_ENABLE;
 	}
 	return ret_val;
@@ -1949,7 +1949,7 @@ void igb_reset(struct igb_adapter *adapter)
 	 * - the full Rx FIFO size minus one full frame
 	 */
 	hwm = min(((pba << 10) * 9 / 10),
-			((pba << 10) - 2 * adapter->max_frame_size));
+		  ((pba << 10) - 2 * adapter->max_frame_size));
 
 	fc->high_water = hwm & 0xFFFFFFF0;	/* 16-byte granularity */
 	fc->low_water = fc->high_water - 16;
@@ -2037,7 +2037,7 @@ void igb_reset(struct igb_adapter *adapter)
 }
 
 static netdev_features_t igb_fix_features(struct net_device *netdev,
-	netdev_features_t features)
+					  netdev_features_t features)
 {
 	/* Since there is no support for separate Rx/Tx vlan accel
 	 * enable/disable make sure Tx flag is always in same state as Rx.
@@ -2051,7 +2051,7 @@ static netdev_features_t igb_fix_features(struct net_device *netdev,
 }
 
 static int igb_set_features(struct net_device *netdev,
-	netdev_features_t features)
+			    netdev_features_t features)
 {
 	netdev_features_t changed = netdev->features ^ features;
 	struct igb_adapter *adapter = netdev_priv(netdev);
@@ -2131,14 +2131,14 @@ void igb_set_fw_version(struct igb_adapter *adapter)
 		/* no option rom */
 		} else if (fw.etrack_id != 0X0000) {
 			snprintf(adapter->fw_version,
-			    sizeof(adapter->fw_version),
-			    "%d.%d, 0x%08x",
-			    fw.eep_major, fw.eep_minor, fw.etrack_id);
+				 sizeof(adapter->fw_version),
+				 "%d.%d, 0x%08x",
+				 fw.eep_major, fw.eep_minor, fw.etrack_id);
 		} else {
 		snprintf(adapter->fw_version,
-		    sizeof(adapter->fw_version),
-		    "%d.%d.%d",
-		    fw.eep_major, fw.eep_minor, fw.eep_build);
+			 sizeof(adapter->fw_version),
+			 "%d.%d.%d",
+			 fw.eep_major, fw.eep_minor, fw.eep_build);
 		}
 		break;
 	}
@@ -2161,38 +2161,38 @@ static void igb_init_mas(struct igb_adapter *adapter)
 		if (eeprom_data & IGB_MAS_ENABLE_0) {
 			adapter->flags |= IGB_FLAG_MAS_ENABLE;
 			netdev_info(adapter->netdev,
-				"MAS: Enabling Media Autosense for port %d\n",
-				hw->bus.func);
+				    "MAS: Enabling Media Autosense for port %d\n",
+				    hw->bus.func);
 		}
 		break;
 	case E1000_FUNC_1:
 		if (eeprom_data & IGB_MAS_ENABLE_1) {
 			adapter->flags |= IGB_FLAG_MAS_ENABLE;
 			netdev_info(adapter->netdev,
-				"MAS: Enabling Media Autosense for port %d\n",
-				hw->bus.func);
+				    "MAS: Enabling Media Autosense for port %d\n",
+				    hw->bus.func);
 		}
 		break;
 	case E1000_FUNC_2:
 		if (eeprom_data & IGB_MAS_ENABLE_2) {
 			adapter->flags |= IGB_FLAG_MAS_ENABLE;
 			netdev_info(adapter->netdev,
-				"MAS: Enabling Media Autosense for port %d\n",
-				hw->bus.func);
+				    "MAS: Enabling Media Autosense for port %d\n",
+				    hw->bus.func);
 		}
 		break;
 	case E1000_FUNC_3:
 		if (eeprom_data & IGB_MAS_ENABLE_3) {
 			adapter->flags |= IGB_FLAG_MAS_ENABLE;
 			netdev_info(adapter->netdev,
-				"MAS: Enabling Media Autosense for port %d\n",
-				hw->bus.func);
+				    "MAS: Enabling Media Autosense for port %d\n",
+				    hw->bus.func);
 		}
 		break;
 	default:
 		/* Shouldn't get here */
 		netdev_err(adapter->netdev,
-			"MAS: Invalid port configuration, returning\n");
+			   "MAS: Invalid port configuration, returning\n");
 		break;
 	}
 }
@@ -2252,7 +2252,7 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 */
 	if (pdev->is_virtfn) {
 		WARN(1, KERN_ERR "%s (%hx:%hx) should not be a VF!\n",
-			pci_name(pdev), pdev->vendor, pdev->device);
+		     pci_name(pdev), pdev->vendor, pdev->device);
 		return -EINVAL;
 	}
 
@@ -2273,8 +2273,9 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		}
 	}
 
-	err = pci_request_selected_regions(pdev, pci_select_bars(pdev,
-					   IORESOURCE_MEM),
+	err = pci_request_selected_regions(pdev,
+					   pci_select_bars(pdev,
+							   IORESOURCE_MEM),
 					   igb_driver_name);
 	if (err)
 		goto err_pci_reg;
@@ -2348,7 +2349,7 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	if (igb_check_reset_block(hw))
 		dev_info(&pdev->dev,
-			"PHY reset is blocked due to SOL/IDER session.\n");
+			 "PHY reset is blocked due to SOL/IDER session.\n");
 
 	/* features is initialized to 0 in allocation, it might have bits
 	 * set by igb_sw_init so we should use an or instead of an
@@ -2604,10 +2605,10 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		strcpy(part_str, "Unknown");
 	dev_info(&pdev->dev, "%s: PBA No: %s\n", netdev->name, part_str);
 	dev_info(&pdev->dev,
-		"Using %s interrupts. %d rx queue(s), %d tx queue(s)\n",
-		(adapter->flags & IGB_FLAG_HAS_MSIX) ? "MSI-X" :
-		(adapter->flags & IGB_FLAG_HAS_MSI) ? "MSI" : "legacy",
-		adapter->num_rx_queues, adapter->num_tx_queues);
+		 "Using %s interrupts. %d rx queue(s), %d tx queue(s)\n",
+		 (adapter->flags & IGB_FLAG_HAS_MSIX) ? "MSI-X" :
+		 (adapter->flags & IGB_FLAG_HAS_MSI) ? "MSI" : "legacy",
+		 adapter->num_rx_queues, adapter->num_tx_queues);
 	if (hw->phy.media_type == e1000_media_type_copper) {
 		switch (hw->mac.type) {
 		case e1000_i350:
@@ -2627,7 +2628,7 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			    E1000_CTRL_EXT_LINK_MODE_SGMII)) {
 				err = igb_set_eee_i354(hw);
 				if ((!err) &&
-					(!hw->dev_spec._82575.eee_disable)) {
+				    (!hw->dev_spec._82575.eee_disable)) {
 					adapter->eee_advert =
 					   MDIO_EEE_100TX | MDIO_EEE_1000T;
 					adapter->flags |= IGB_FLAG_EEE;
@@ -4081,7 +4082,7 @@ static void igb_spoof_check(struct igb_adapter *adapter)
 		if (adapter->wvbr & (1 << j) ||
 		    adapter->wvbr & (1 << (j + IGB_STAGGERED_QUEUE_OFFSET))) {
 			dev_warn(&adapter->pdev->dev,
-				"Spoof event(s) detected on VF %d\n", j);
+				 "Spoof event(s) detected on VF %d\n", j);
 			adapter->wvbr &=
 				~((1 << j) |
 				  (1 << (j + IGB_STAGGERED_QUEUE_OFFSET)));
@@ -4228,9 +4229,9 @@ static void igb_watchdog_task(struct work_struct *work)
 
 			/* disable EEE if enabled */
 			if ((adapter->flags & IGB_FLAG_EEE) &&
-				(adapter->link_duplex == HALF_DUPLEX)) {
+			    (adapter->link_duplex == HALF_DUPLEX)) {
 				dev_info(&adapter->pdev->dev,
-				"EEE Disabled: unsupported at half duplex. Re-enable using ethtool when at full duplex.\n");
+					 "EEE Disabled: unsupported at half duplex. Re-enable using ethtool when at full duplex.\n");
 				adapter->hw.dev_spec._82575.eee_disable = true;
 				adapter->flags &= ~IGB_FLAG_EEE;
 			}
@@ -4242,7 +4243,7 @@ static void igb_watchdog_task(struct work_struct *work)
 
 			/* check for thermal sensor event */
 			if (igb_thermal_sensor_event(hw,
-			    E1000_THSTAT_LINK_THROTTLE)) {
+						     E1000_THSTAT_LINK_THROTTLE)) {
 				netdev_info(netdev, "The network adapter link "
 					    "speed was downshifted because it "
 					    "overheated\n");
@@ -4276,7 +4277,7 @@ static void igb_watchdog_task(struct work_struct *work)
 
 			/* check for thermal sensor event */
 			if (igb_thermal_sensor_event(hw,
-			    E1000_THSTAT_PWR_DOWN)) {
+						     E1000_THSTAT_PWR_DOWN)) {
 				netdev_err(netdev, "The network adapter was "
 					   "stopped because it overheated\n");
 			}
@@ -5099,7 +5100,7 @@ static void igb_reset_task(struct work_struct *work)
  *  @stats: rtnl_link_stats64 pointer
  **/
 static struct rtnl_link_stats64 *igb_get_stats64(struct net_device *netdev,
-						struct rtnl_link_stats64 *stats)
+						 struct rtnl_link_stats64 *stats)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 
@@ -5341,7 +5342,7 @@ void igb_update_stats(struct igb_adapter *adapter,
 	/* Phy Stats */
 	if (hw->phy.media_type == e1000_media_type_copper) {
 		if ((adapter->link_speed == SPEED_1000) &&
-		   (!igb_read_phy_reg(hw, PHY_1000T_STATUS, &phy_tmp))) {
+		    (!igb_read_phy_reg(hw, PHY_1000T_STATUS, &phy_tmp))) {
 			phy_tmp &= PHY_IDLE_ERROR_COUNT_MASK;
 			adapter->phy_stats.idle_errors += phy_tmp;
 		}
@@ -5635,7 +5636,7 @@ static int igb_set_vf_promisc(struct igb_adapter *adapter, u32 *msgbuf, u32 vf)
 }
 
 static int igb_set_vf_multicasts(struct igb_adapter *adapter,
-				  u32 *msgbuf, u32 vf)
+				 u32 *msgbuf, u32 vf)
 {
 	int n = (msgbuf[0] & E1000_VT_MSGINFO_MASK) >> E1000_VT_MSGINFO_SHIFT;
 	u16 *hash_list = (u16 *)&msgbuf[1];
@@ -6451,8 +6452,8 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 
 #define TX_WAKE_THRESHOLD (DESC_NEEDED * 2)
 	if (unlikely(total_packets &&
-	    netif_carrier_ok(tx_ring->netdev) &&
-	    igb_desc_unused(tx_ring) >= TX_WAKE_THRESHOLD)) {
+		     netif_carrier_ok(tx_ring->netdev) &&
+		     igb_desc_unused(tx_ring) >= TX_WAKE_THRESHOLD)) {
 		/* Make sure that anybody stopping the queue after this
 		 * sees the new next_to_clean.
 		 */
diff --git a/drivers/net/ethernet/intel/igbvf/ethtool.c b/drivers/net/ethernet/intel/igbvf/ethtool.c
index 90eef07..70391ce 100644
--- a/drivers/net/ethernet/intel/igbvf/ethtool.c
+++ b/drivers/net/ethernet/intel/igbvf/ethtool.c
@@ -358,7 +358,7 @@ static int igbvf_set_coalesce(struct net_device *netdev,
 	struct e1000_hw *hw = &adapter->hw;
 
 	if ((ec->rx_coalesce_usecs >= IGBVF_MIN_ITR_USECS) &&
-	     (ec->rx_coalesce_usecs <= IGBVF_MAX_ITR_USECS)) {
+	    (ec->rx_coalesce_usecs <= IGBVF_MAX_ITR_USECS)) {
 		adapter->current_itr = ec->rx_coalesce_usecs << 2;
 		adapter->requested_itr = 1000000000 /
 					(adapter->current_itr * 256);
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index b7ab03a..8804437 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2383,9 +2383,9 @@ static int igbvf_change_mtu(struct net_device *netdev, int new_mtu)
 
 	/* adjust allocation if LPE protects us, and we aren't using SBP */
 	if ((max_frame == ETH_FRAME_LEN + ETH_FCS_LEN) ||
-	     (max_frame == ETH_FRAME_LEN + VLAN_HLEN + ETH_FCS_LEN))
-		adapter->rx_buffer_len = ETH_FRAME_LEN + VLAN_HLEN +
-		                         ETH_FCS_LEN;
+	    (max_frame == ETH_FRAME_LEN + VLAN_HLEN + ETH_FCS_LEN))
+		adapter->rx_buffer_len = (ETH_FRAME_LEN + VLAN_HLEN +
+					  ETH_FCS_LEN);
 
 	dev_info(&adapter->pdev->dev, "changing MTU from %d to %d\n",
 	         netdev->mtu, new_mtu);
@@ -2581,7 +2581,7 @@ static void igbvf_print_device_info(struct igbvf_adapter *adapter)
 }
 
 static int igbvf_set_features(struct net_device *netdev,
-	netdev_features_t features)
+			      netdev_features_t features)
 {
 	struct igbvf_adapter *adapter = netdev_priv(netdev);
 
@@ -2749,7 +2749,7 @@ static int igbvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_info(&pdev->dev, "Assigning random MAC address.\n");
 		eth_hw_addr_random(netdev);
 		memcpy(adapter->hw.mac.addr, netdev->dev_addr,
-			netdev->addr_len);
+		       netdev->addr_len);
 	}
 
 	setup_timer(&adapter->watchdog_timer, &igbvf_watchdog,
diff --git a/drivers/net/ethernet/intel/igbvf/vf.c b/drivers/net/ethernet/intel/igbvf/vf.c
index 955ad8c..ec0fb8b 100644
--- a/drivers/net/ethernet/intel/igbvf/vf.c
+++ b/drivers/net/ethernet/intel/igbvf/vf.c
@@ -221,8 +221,8 @@ static u32 e1000_hash_mc_addr_vf(struct e1000_hw *hw, u8 *mc_addr)
  *  unless there are workarounds that change this.
  **/
 static void e1000_update_mc_addr_list_vf(struct e1000_hw *hw,
-                                  u8 *mc_addr_list, u32 mc_addr_count,
-                                  u32 rar_used_count, u32 rar_count)
+					 u8 *mc_addr_list, u32 mc_addr_count,
+					 u32 rar_used_count, u32 rar_count)
 {
 	struct e1000_mbx_info *mbx = &hw->mbx;
 	u32 msgbuf[E1000_VFMAILBOX_SIZE];
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_ee.c b/drivers/net/ethernet/intel/ixgb/ixgb_ee.c
index eca216b..254b097 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_ee.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_ee.c
@@ -49,8 +49,7 @@ static void ixgb_cleanup_eeprom(struct ixgb_hw *hw);
  * eecd_reg - EECD's current value
  *****************************************************************************/
 static void
-ixgb_raise_clock(struct ixgb_hw *hw,
-		  u32 *eecd_reg)
+ixgb_raise_clock(struct ixgb_hw *hw, u32 *eecd_reg)
 {
 	/* Raise the clock input to the EEPROM (by setting the SK bit), and then
 	 *  wait 50 microseconds.
@@ -68,8 +67,7 @@ ixgb_raise_clock(struct ixgb_hw *hw,
  * eecd_reg - EECD's current value
  *****************************************************************************/
 static void
-ixgb_lower_clock(struct ixgb_hw *hw,
-		  u32 *eecd_reg)
+ixgb_lower_clock(struct ixgb_hw *hw, u32 *eecd_reg)
 {
 	/* Lower the clock input to the EEPROM (by clearing the SK bit), and then
 	 * wait 50 microseconds.
@@ -88,9 +86,7 @@ ixgb_lower_clock(struct ixgb_hw *hw,
  * count - number of bits to shift out
  *****************************************************************************/
 static void
-ixgb_shift_out_bits(struct ixgb_hw *hw,
-					 u16 data,
-					 u16 count)
+ixgb_shift_out_bits(struct ixgb_hw *hw, u16 data, u16 count)
 {
 	u32 eecd_reg;
 	u32 mask;
@@ -427,8 +423,7 @@ ixgb_write_eeprom(struct ixgb_hw *hw, u16 offset, u16 data)
  *  The 16-bit value read from the eeprom
  *****************************************************************************/
 u16
-ixgb_read_eeprom(struct ixgb_hw *hw,
-		  u16 offset)
+ixgb_read_eeprom(struct ixgb_hw *hw, u16 offset)
 {
 	u16 data;
 
@@ -548,8 +543,7 @@ ixgb_get_eeprom_word(struct ixgb_hw *hw, u16 index)
  * Returns: None.
  ******************************************************************************/
 void
-ixgb_get_ee_mac_addr(struct ixgb_hw *hw,
-			u8 *mac_addr)
+ixgb_get_ee_mac_addr(struct ixgb_hw *hw, u8 *mac_addr)
 {
 	int i;
 	struct ixgb_ee_map_type *ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
index dbb7dd2..f0aa3c1 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
@@ -147,8 +147,7 @@ ixgb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 }
 
 static void
-ixgb_get_pauseparam(struct net_device *netdev,
-			 struct ethtool_pauseparam *pause)
+ixgb_get_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *pause)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
@@ -166,8 +165,7 @@ ixgb_get_pauseparam(struct net_device *netdev,
 }
 
 static int
-ixgb_set_pauseparam(struct net_device *netdev,
-			 struct ethtool_pauseparam *pause)
+ixgb_set_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *pause)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
@@ -217,8 +215,7 @@ ixgb_get_regs_len(struct net_device *netdev)
 }
 
 static void
-ixgb_get_regs(struct net_device *netdev,
-		   struct ethtool_regs *regs, void *p)
+ixgb_get_regs(struct net_device *netdev, struct ethtool_regs *regs, void *p)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
@@ -365,7 +362,7 @@ ixgb_get_eeprom_len(struct net_device *netdev)
 
 static int
 ixgb_get_eeprom(struct net_device *netdev,
-		  struct ethtool_eeprom *eeprom, u8 *bytes)
+		struct ethtool_eeprom *eeprom, u8 *bytes)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
@@ -411,7 +408,7 @@ geeprom_error:
 
 static int
 ixgb_set_eeprom(struct net_device *netdev,
-		  struct ethtool_eeprom *eeprom, u8 *bytes)
+		struct ethtool_eeprom *eeprom, u8 *bytes)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
@@ -469,7 +466,7 @@ ixgb_set_eeprom(struct net_device *netdev,
 
 static void
 ixgb_get_drvinfo(struct net_device *netdev,
-		   struct ethtool_drvinfo *drvinfo)
+		 struct ethtool_drvinfo *drvinfo)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 
@@ -485,8 +482,7 @@ ixgb_get_drvinfo(struct net_device *netdev,
 }
 
 static void
-ixgb_get_ringparam(struct net_device *netdev,
-		struct ethtool_ringparam *ring)
+ixgb_get_ringparam(struct net_device *netdev, struct ethtool_ringparam *ring)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_desc_ring *txdr = &adapter->tx_ring;
@@ -499,8 +495,7 @@ ixgb_get_ringparam(struct net_device *netdev,
 }
 
 static int
-ixgb_set_ringparam(struct net_device *netdev,
-		struct ethtool_ringparam *ring)
+ixgb_set_ringparam(struct net_device *netdev, struct ethtool_ringparam *ring)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_desc_ring *txdr = &adapter->tx_ring;
@@ -592,7 +587,7 @@ ixgb_get_sset_count(struct net_device *netdev, int sset)
 
 static void
 ixgb_get_ethtool_stats(struct net_device *netdev,
-		struct ethtool_stats *stats, u64 *data)
+		       struct ethtool_stats *stats, u64 *data)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	int i;
@@ -625,8 +620,8 @@ ixgb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 	case ETH_SS_STATS:
 		for (i = 0; i < IXGB_STATS_LEN; i++) {
 			memcpy(data + i * ETH_GSTRING_LEN,
-			ixgb_gstrings_stats[i].stat_string,
-			ETH_GSTRING_LEN);
+			       ixgb_gstrings_stats[i].stat_string,
+			       ETH_GSTRING_LEN);
 		}
 		break;
 	}
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_hw.c b/drivers/net/ethernet/intel/ixgb/ixgb_hw.c
index bf9a220..c6f8e69 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_hw.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_hw.c
@@ -61,9 +61,7 @@ static void ixgb_clear_vfta(struct ixgb_hw *hw);
 static void ixgb_init_rx_addrs(struct ixgb_hw *hw);
 
 static u16 ixgb_read_phy_reg(struct ixgb_hw *hw,
-				  u32 reg_address,
-				  u32 phy_address,
-				  u32 device_type);
+			     u32 reg_address, u32 phy_address, u32 device_type);
 
 static bool ixgb_setup_fc(struct ixgb_hw *hw);
 
@@ -432,9 +430,7 @@ ixgb_init_rx_addrs(struct ixgb_hw *hw)
  *****************************************************************************/
 void
 ixgb_mc_addr_list_update(struct ixgb_hw *hw,
-			  u8 *mc_addr_list,
-			  u32 mc_addr_count,
-			  u32 pad)
+			 u8 *mc_addr_list, u32 mc_addr_count, u32 pad)
 {
 	u32 hash_value;
 	u32 i;
@@ -495,8 +491,7 @@ ixgb_mc_addr_list_update(struct ixgb_hw *hw,
  *      The hash value
  *****************************************************************************/
 static u32
-ixgb_hash_mc_addr(struct ixgb_hw *hw,
-		   u8 *mc_addr)
+ixgb_hash_mc_addr(struct ixgb_hw *hw, u8 *mc_addr)
 {
 	u32 hash_value = 0;
 
@@ -543,8 +538,7 @@ ixgb_hash_mc_addr(struct ixgb_hw *hw,
  * hash_value - Multicast address hash value
  *****************************************************************************/
 static void
-ixgb_mta_set(struct ixgb_hw *hw,
-		  u32 hash_value)
+ixgb_mta_set(struct ixgb_hw *hw, u32 hash_value)
 {
 	u32 hash_bit, hash_reg;
 	u32 mta_reg;
@@ -575,9 +569,7 @@ ixgb_mta_set(struct ixgb_hw *hw,
  * index - Receive address register to write
  *****************************************************************************/
 void
-ixgb_rar_set(struct ixgb_hw *hw,
-		  u8 *addr,
-		  u32 index)
+ixgb_rar_set(struct ixgb_hw *hw, u8 *addr, u32 index)
 {
 	u32 rar_low, rar_high;
 
@@ -607,9 +599,7 @@ ixgb_rar_set(struct ixgb_hw *hw,
  * value - Value to write into VLAN filter table
  *****************************************************************************/
 void
-ixgb_write_vfta(struct ixgb_hw *hw,
-		 u32 offset,
-		 u32 value)
+ixgb_write_vfta(struct ixgb_hw *hw, u32 offset, u32 value)
 {
 	IXGB_WRITE_REG_ARRAY(hw, VFTA, offset, value);
 }
@@ -711,7 +701,7 @@ ixgb_setup_fc(struct ixgb_hw *hw)
 	    * frames. */
 		if (hw->fc.send_xon) {
 			IXGB_WRITE_REG(hw, FCRTL,
-				(hw->fc.low_water | IXGB_FCRTL_XONE));
+				       hw->fc.low_water | IXGB_FCRTL_XONE);
 		} else {
 			IXGB_WRITE_REG(hw, FCRTL, hw->fc.low_water);
 		}
@@ -736,10 +726,8 @@ ixgb_setup_fc(struct ixgb_hw *hw)
  * read command.
  *****************************************************************************/
 static u16
-ixgb_read_phy_reg(struct ixgb_hw *hw,
-		u32 reg_address,
-		u32 phy_address,
-		u32 device_type)
+ixgb_read_phy_reg(struct ixgb_hw *hw, u32 reg_address, u32 phy_address,
+		  u32 device_type)
 {
 	u32 i;
 	u32 data;
@@ -829,11 +817,8 @@ ixgb_read_phy_reg(struct ixgb_hw *hw,
  * write command.
  *****************************************************************************/
 static void
-ixgb_write_phy_reg(struct ixgb_hw *hw,
-			u32 reg_address,
-			u32 phy_address,
-			u32 device_type,
-			u16 data)
+ixgb_write_phy_reg(struct ixgb_hw *hw, u32 reg_address, u32 phy_address,
+		   u32 device_type, u16 data)
 {
 	u32 i;
 	u32 command = 0;
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_hw.h b/drivers/net/ethernet/intel/ixgb/ixgb_hw.h
index 0bd5d72..52012ee 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_hw.h
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_hw.h
@@ -784,9 +784,7 @@ __le16 ixgb_get_eeprom_word(struct ixgb_hw *hw, u16 index);
 /* Everything else */
 void ixgb_led_on(struct ixgb_hw *hw);
 void ixgb_led_off(struct ixgb_hw *hw);
-void ixgb_write_pci_cfg(struct ixgb_hw *hw,
-			 u32 reg,
-			 u16 * value);
+void ixgb_write_pci_cfg(struct ixgb_hw *hw, u32 reg, u16 *value);
 
 
 #endif /* _IXGB_HW_H_ */
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index f42c201..75ffe60 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -43,7 +43,7 @@ static const char ixgb_copyright[] = "Copyright (c) 1999-2008 Intel Corporation.
 static unsigned int copybreak __read_mostly = IXGB_CB_LENGTH;
 module_param(copybreak, uint, 0644);
 MODULE_PARM_DESC(copybreak,
-	"Maximum size of packet that is copied to a new buffer on receive");
+		 "Maximum size of packet that is copied to a new buffer on receive");
 
 /* ixgb_pci_tbl - PCI Device ID Table
  *
@@ -112,9 +112,9 @@ static void ixgb_restore_vlan(struct ixgb_adapter *adapter);
 static void ixgb_netpoll(struct net_device *dev);
 #endif
 
-static pci_ers_result_t ixgb_io_error_detected (struct pci_dev *pdev,
-                             enum pci_channel_state state);
-static pci_ers_result_t ixgb_io_slot_reset (struct pci_dev *pdev);
+static pci_ers_result_t ixgb_io_error_detected(struct pci_dev *pdev,
+					       enum pci_channel_state state);
+static pci_ers_result_t ixgb_io_slot_reset(struct pci_dev *pdev);
 static void ixgb_io_resume (struct pci_dev *pdev);
 
 static const struct pci_error_handlers ixgb_err_handler = {
@@ -247,8 +247,8 @@ ixgb_up(struct ixgb_adapter *adapter)
 	}
 
 	if ((hw->max_frame_size != max_frame) ||
-		(hw->max_frame_size !=
-		(IXGB_READ_REG(hw, MFS) >> IXGB_MFS_SHIFT))) {
+	    (hw->max_frame_size !=
+	     (IXGB_READ_REG(hw, MFS) >> IXGB_MFS_SHIFT))) {
 
 		hw->max_frame_size = max_frame;
 
@@ -1531,7 +1531,7 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	if (unlikely(ixgb_maybe_stop_tx(netdev, &adapter->tx_ring,
-                     DESC_NEEDED)))
+					DESC_NEEDED)))
 		return NETDEV_TX_BUSY;
 
 	if (vlan_tx_tag_present(skb)) {
@@ -1662,7 +1662,7 @@ ixgb_update_stats(struct ixgb_adapter *adapter)
 		return;
 
 	if ((netdev->flags & IFF_PROMISC) || (netdev->flags & IFF_ALLMULTI) ||
-	   (netdev_mc_count(netdev) > IXGB_MAX_NUM_MULTICAST_ADDRESSES)) {
+	    (netdev_mc_count(netdev) > IXGB_MAX_NUM_MULTICAST_ADDRESSES)) {
 		u64 multi = IXGB_READ_REG(&adapter->hw, MPRCL);
 		u32 bcast_l = IXGB_READ_REG(&adapter->hw, BPRCL);
 		u32 bcast_h = IXGB_READ_REG(&adapter->hw, BPRCH);
@@ -1897,9 +1897,8 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 		 * check with the clearing of time_stamp and movement of i */
 		adapter->detect_tx_hung = false;
 		if (tx_ring->buffer_info[eop].time_stamp &&
-		   time_after(jiffies, tx_ring->buffer_info[eop].time_stamp + HZ)
-		   && !(IXGB_READ_REG(&adapter->hw, STATUS) &
-		        IXGB_STATUS_TXOFF)) {
+		    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp + HZ) &&
+		    !(IXGB_READ_REG(&adapter->hw, STATUS) & IXGB_STATUS_TXOFF)) {
 			/* detected Tx unit hang */
 			netif_err(adapter, drv, adapter->netdev,
 				  "Detected Tx Unit Hang\n"
@@ -1943,7 +1942,7 @@ ixgb_rx_checksum(struct ixgb_adapter *adapter,
 	 * TCP Checksum has not been calculated
 	 */
 	if ((rx_desc->status & IXGB_RX_DESC_STATUS_IXSM) ||
-	   (!(rx_desc->status & IXGB_RX_DESC_STATUS_TCPCS))) {
+	    (!(rx_desc->status & IXGB_RX_DESC_STATUS_TCPCS))) {
 		skb_checksum_none_assert(skb);
 		return;
 	}
@@ -2077,7 +2076,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter, int *work_done, int work_to_do)
 		skb->protocol = eth_type_trans(skb, netdev);
 		if (status & IXGB_RX_DESC_STATUS_VP)
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
-				       le16_to_cpu(rx_desc->special));
+					       le16_to_cpu(rx_desc->special));
 
 		netif_receive_skb(skb);
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 2fff0fc..0ce3a73 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -859,7 +859,7 @@ void ixgbe_disable_rx_queue(struct ixgbe_adapter *adapter, struct ixgbe_ring *);
 void ixgbe_update_stats(struct ixgbe_adapter *adapter);
 int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter);
 int ixgbe_wol_supported(struct ixgbe_adapter *adapter, u16 device_id,
-			       u16 subdevice_id);
+			u16 subdevice_id);
 void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter);
 netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *, struct ixgbe_adapter *,
 				  struct ixgbe_ring *);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index 4c78ea8..924bb35 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -156,8 +156,8 @@ static s32 ixgbe_init_phy_ops_82598(struct ixgbe_hw *hw)
 
 		/* Check to see if SFP+ module is supported */
 		ret_val = ixgbe_get_sfp_init_sequence_offsets(hw,
-		                                            &list_offset,
-		                                            &data_offset);
+							      &list_offset,
+							      &data_offset);
 		if (ret_val != 0) {
 			ret_val = IXGBE_ERR_SFP_NOT_SUPPORTED;
 			goto out;
@@ -188,15 +188,17 @@ static s32 ixgbe_start_hw_82598(struct ixgbe_hw *hw)
 	ret_val = ixgbe_start_hw_generic(hw);
 
 	/* Disable relaxed ordering */
-	for (i = 0; ((i < hw->mac.max_tx_queues) &&
-	     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
+	for (i = 0;
+	     (i < hw->mac.max_tx_queues) && (i < IXGBE_DCA_MAX_QUEUES_82598);
+	     i++) {
 		regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(i));
 		regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
 		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(i), regval);
 	}
 
-	for (i = 0; ((i < hw->mac.max_rx_queues) &&
-	     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
+	for (i = 0;
+	     (i < hw->mac.max_rx_queues) && (i < IXGBE_DCA_MAX_QUEUES_82598);
+	     i++) {
 		regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
 		regval &= ~(IXGBE_DCA_RXCTRL_DATA_WRO_EN |
 			    IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
@@ -689,8 +691,8 @@ static s32 ixgbe_setup_mac_link_82598(struct ixgbe_hw *hw,
  *  Sets the link speed in the AUTOC register in the MAC and restarts link.
  **/
 static s32 ixgbe_setup_copper_link_82598(struct ixgbe_hw *hw,
-                                               ixgbe_link_speed speed,
-                                               bool autoneg_wait_to_complete)
+					 ixgbe_link_speed speed,
+					 bool autoneg_wait_to_complete)
 {
 	s32 status;
 
@@ -1098,7 +1100,7 @@ static s32 ixgbe_read_i2c_eeprom_82598(struct ixgbe_hw *hw, u8 byte_offset,
  *  Performs 8 byte read operation to SFP module's SFF-8472 data over I2C
  **/
 static s32 ixgbe_read_i2c_sff8472_82598(struct ixgbe_hw *hw, u8 byte_offset,
-				       u8 *sff8472_data)
+					u8 *sff8472_data)
 {
 	return ixgbe_read_i2c_phy_82598(hw, IXGBE_I2C_EEPROM_DEV_ADDR2,
 					byte_offset, sff8472_data);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index f32b3dd..c8e77f0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -54,8 +54,8 @@ static void ixgbe_stop_mac_link_on_d3_82599(struct ixgbe_hw *hw);
 static s32 ixgbe_start_mac_link_82599(struct ixgbe_hw *hw,
 				      bool autoneg_wait_to_complete);
 static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
-                               ixgbe_link_speed speed,
-                               bool autoneg_wait_to_complete);
+				      ixgbe_link_speed speed,
+				      bool autoneg_wait_to_complete);
 static s32 ixgbe_setup_copper_link_82599(struct ixgbe_hw *hw,
                                          ixgbe_link_speed speed,
                                          bool autoneg_wait_to_complete);
@@ -543,7 +543,7 @@ static void ixgbe_stop_mac_link_on_d3_82599(struct ixgbe_hw *hw)
  *  Restarts the link.  Performs autonegotiation if needed.
  **/
 static s32 ixgbe_start_mac_link_82599(struct ixgbe_hw *hw,
-                               bool autoneg_wait_to_complete)
+				      bool autoneg_wait_to_complete)
 {
 	u32 autoc_reg;
 	u32 links_reg;
@@ -672,8 +672,8 @@ static void ixgbe_flap_tx_laser_multispeed_fiber(struct ixgbe_hw *hw)
  *  Set the link speed in the AUTOC register and restarts link.
  **/
 static s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
-                                          ixgbe_link_speed speed,
-                                          bool autoneg_wait_to_complete)
+						 ixgbe_link_speed speed,
+						 bool autoneg_wait_to_complete)
 {
 	s32 status = 0;
 	ixgbe_link_speed link_speed = IXGBE_LINK_SPEED_UNKNOWN;
@@ -845,8 +845,8 @@ out:
  *  Implements the Intel SmartSpeed algorithm.
  **/
 static s32 ixgbe_setup_mac_link_smartspeed(struct ixgbe_hw *hw,
-				     ixgbe_link_speed speed,
-				     bool autoneg_wait_to_complete)
+					   ixgbe_link_speed speed,
+					   bool autoneg_wait_to_complete)
 {
 	s32 status = 0;
 	ixgbe_link_speed link_speed = IXGBE_LINK_SPEED_UNKNOWN;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 24fba39..9c445a0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -52,7 +52,7 @@ static s32 ixgbe_poll_eerd_eewr_done(struct ixgbe_hw *hw, u32 ee_reg);
 static s32 ixgbe_read_eeprom_buffer_bit_bang(struct ixgbe_hw *hw, u16 offset,
 					     u16 words, u16 *data);
 static s32 ixgbe_write_eeprom_buffer_bit_bang(struct ixgbe_hw *hw, u16 offset,
-					     u16 words, u16 *data);
+					      u16 words, u16 *data);
 static s32 ixgbe_detect_eeprom_page_size_generic(struct ixgbe_hw *hw,
 						 u16 offset);
 static s32 ixgbe_disable_pcie_master(struct ixgbe_hw *hw);
@@ -911,8 +911,8 @@ static s32 ixgbe_write_eeprom_buffer_bit_bang(struct ixgbe_hw *hw, u16 offset,
 
 			/*  Send the WRITE ENABLE command (8 bit opcode )  */
 			ixgbe_shift_out_eeprom_bits(hw,
-						  IXGBE_EEPROM_WREN_OPCODE_SPI,
-						  IXGBE_EEPROM_OPCODE_BITS);
+						    IXGBE_EEPROM_WREN_OPCODE_SPI,
+						    IXGBE_EEPROM_OPCODE_BITS);
 
 			ixgbe_standby_eeprom(hw);
 
@@ -1180,7 +1180,8 @@ static s32 ixgbe_detect_eeprom_page_size_generic(struct ixgbe_hw *hw,
 
 	hw->eeprom.word_page_size = IXGBE_EEPROM_PAGE_SIZE_MAX;
 	status = ixgbe_write_eeprom_buffer_bit_bang(hw, offset,
-					     IXGBE_EEPROM_PAGE_SIZE_MAX, data);
+						    IXGBE_EEPROM_PAGE_SIZE_MAX,
+						    data);
 	hw->eeprom.word_page_size = 0;
 	if (status != 0)
 		goto out;
@@ -2289,10 +2290,10 @@ static s32 ixgbe_fc_autoneg_fiber(struct ixgbe_hw *hw)
 	pcs_lpab_reg = IXGBE_READ_REG(hw, IXGBE_PCS1GANLP);
 
 	ret_val =  ixgbe_negotiate_fc(hw, pcs_anadv_reg,
-			       pcs_lpab_reg, IXGBE_PCS1GANA_SYM_PAUSE,
-			       IXGBE_PCS1GANA_ASM_PAUSE,
-			       IXGBE_PCS1GANA_SYM_PAUSE,
-			       IXGBE_PCS1GANA_ASM_PAUSE);
+				      pcs_lpab_reg, IXGBE_PCS1GANA_SYM_PAUSE,
+				      IXGBE_PCS1GANA_ASM_PAUSE,
+				      IXGBE_PCS1GANA_SYM_PAUSE,
+				      IXGBE_PCS1GANA_ASM_PAUSE);
 
 out:
 	return ret_val;
@@ -2331,8 +2332,10 @@ static s32 ixgbe_fc_autoneg_backplane(struct ixgbe_hw *hw)
 	anlp1_reg = IXGBE_READ_REG(hw, IXGBE_ANLP1);
 
 	ret_val = ixgbe_negotiate_fc(hw, autoc_reg,
-		anlp1_reg, IXGBE_AUTOC_SYM_PAUSE, IXGBE_AUTOC_ASM_PAUSE,
-		IXGBE_ANLP1_SYM_PAUSE, IXGBE_ANLP1_ASM_PAUSE);
+				     anlp1_reg, IXGBE_AUTOC_SYM_PAUSE,
+				     IXGBE_AUTOC_ASM_PAUSE,
+				     IXGBE_ANLP1_SYM_PAUSE,
+				     IXGBE_ANLP1_ASM_PAUSE);
 
 out:
 	return ret_val;
@@ -2782,7 +2785,7 @@ out:
  *  get and set mac_addr routines.
  **/
 static s32 ixgbe_get_san_mac_addr_offset(struct ixgbe_hw *hw,
-                                        u16 *san_mac_offset)
+					 u16 *san_mac_offset)
 {
 	s32 ret_val;
 
@@ -3130,14 +3133,14 @@ s32 ixgbe_set_vfta_generic(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 			/* set the pool bit */
 			if (vind < 32) {
 				bits = IXGBE_READ_REG(hw,
-						IXGBE_VLVFB(vlvf_index*2));
+						      IXGBE_VLVFB(vlvf_index*2));
 				bits |= (1 << vind);
 				IXGBE_WRITE_REG(hw,
 						IXGBE_VLVFB(vlvf_index*2),
 						bits);
 			} else {
 				bits = IXGBE_READ_REG(hw,
-						IXGBE_VLVFB((vlvf_index*2)+1));
+						      IXGBE_VLVFB((vlvf_index*2)+1));
 				bits |= (1 << (vind-32));
 				IXGBE_WRITE_REG(hw,
 						IXGBE_VLVFB((vlvf_index*2)+1),
@@ -3147,7 +3150,7 @@ s32 ixgbe_set_vfta_generic(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 			/* clear the pool bit */
 			if (vind < 32) {
 				bits = IXGBE_READ_REG(hw,
-						IXGBE_VLVFB(vlvf_index*2));
+						      IXGBE_VLVFB(vlvf_index*2));
 				bits &= ~(1 << vind);
 				IXGBE_WRITE_REG(hw,
 						IXGBE_VLVFB(vlvf_index*2),
@@ -3156,7 +3159,7 @@ s32 ixgbe_set_vfta_generic(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 						IXGBE_VLVFB((vlvf_index*2)+1));
 			} else {
 				bits = IXGBE_READ_REG(hw,
-						IXGBE_VLVFB((vlvf_index*2)+1));
+						      IXGBE_VLVFB((vlvf_index*2)+1));
 				bits &= ~(1 << (vind-32));
 				IXGBE_WRITE_REG(hw,
 						IXGBE_VLVFB((vlvf_index*2)+1),
@@ -3292,7 +3295,7 @@ s32 ixgbe_check_mac_link_generic(struct ixgbe_hw *hw, ixgbe_link_speed *speed,
  *  block to check the support for the alternative WWNN/WWPN prefix support.
  **/
 s32 ixgbe_get_wwn_prefix_generic(struct ixgbe_hw *hw, u16 *wwnn_prefix,
-                                        u16 *wwpn_prefix)
+				 u16 *wwpn_prefix)
 {
 	u16 offset, caps;
 	u16 alt_san_mac_blk_offset;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
index e055e00..12ca108 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb.c
@@ -219,7 +219,7 @@ void ixgbe_dcb_unpack_bwgid(struct ixgbe_dcb_config *cfg, int direction,
 }
 
 void ixgbe_dcb_unpack_prio(struct ixgbe_dcb_config *cfg, int direction,
-			    u8 *ptype)
+			   u8 *ptype)
 {
 	struct tc_configuration *tc_config = &cfg->tc_config[0];
 	int tc;
@@ -360,11 +360,11 @@ s32 ixgbe_dcb_hw_ets_config(struct ixgbe_hw *hw,
 	switch (hw->mac.type) {
 	case ixgbe_mac_82598EB:
 		ixgbe_dcb_config_rx_arbiter_82598(hw, refill, max,
-							prio_type);
+						  prio_type);
 		ixgbe_dcb_config_tx_desc_arbiter_82598(hw, refill, max,
-							     bwg_id, prio_type);
+						       bwg_id, prio_type);
 		ixgbe_dcb_config_tx_data_arbiter_82598(hw, refill, max,
-							     bwg_id, prio_type);
+						       bwg_id, prio_type);
 		break;
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c
index 7a77f37..9952596 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.c
@@ -39,9 +39,9 @@
  * Configure Rx Data Arbiter and credits for each traffic class.
  */
 s32 ixgbe_dcb_config_rx_arbiter_82598(struct ixgbe_hw *hw,
-					u16 *refill,
-					u16 *max,
-					u8 *prio_type)
+				      u16 *refill,
+				      u16 *max,
+				      u8 *prio_type)
 {
 	u32    reg           = 0;
 	u32    credit_refill = 0;
@@ -96,10 +96,10 @@ s32 ixgbe_dcb_config_rx_arbiter_82598(struct ixgbe_hw *hw,
  * Configure Tx Descriptor Arbiter and credits for each traffic class.
  */
 s32 ixgbe_dcb_config_tx_desc_arbiter_82598(struct ixgbe_hw *hw,
-						u16 *refill,
-						u16 *max,
-						u8 *bwg_id,
-						u8 *prio_type)
+					   u16 *refill,
+					   u16 *max,
+					   u8 *bwg_id,
+					   u8 *prio_type)
 {
 	u32    reg, max_credits;
 	u8     i;
@@ -142,10 +142,10 @@ s32 ixgbe_dcb_config_tx_desc_arbiter_82598(struct ixgbe_hw *hw,
  * Configure Tx Data Arbiter and credits for each traffic class.
  */
 s32 ixgbe_dcb_config_tx_data_arbiter_82598(struct ixgbe_hw *hw,
-						u16 *refill,
-						u16 *max,
-						u8 *bwg_id,
-						u8 *prio_type)
+					   u16 *refill,
+					   u16 *max,
+					   u8 *bwg_id,
+					   u8 *prio_type)
 {
 	u32 reg;
 	u8 i;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.h
index 3164f54..8346c7c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82598.h
@@ -75,21 +75,21 @@ s32 ixgbe_dcb_config_pfc_82598(struct ixgbe_hw *, u8 pfc_en);
 
 /* DCB hw initialization */
 s32 ixgbe_dcb_config_rx_arbiter_82598(struct ixgbe_hw *hw,
-					u16 *refill,
-					u16 *max,
-					u8 *prio_type);
+				      u16 *refill,
+				      u16 *max,
+				      u8 *prio_type);
 
 s32 ixgbe_dcb_config_tx_desc_arbiter_82598(struct ixgbe_hw *hw,
-						u16 *refill,
-						u16 *max,
-						u8 *bwg_id,
-						u8 *prio_type);
+					   u16 *refill,
+					   u16 *max,
+					   u8 *bwg_id,
+					   u8 *prio_type);
 
 s32 ixgbe_dcb_config_tx_data_arbiter_82598(struct ixgbe_hw *hw,
-						u16 *refill,
-						u16 *max,
-						u8 *bwg_id,
-						u8 *prio_type);
+					   u16 *refill,
+					   u16 *max,
+					   u8 *bwg_id,
+					   u8 *prio_type);
 
 s32 ixgbe_dcb_hw_config_82598(struct ixgbe_hw *hw, u8 pfc_en, u16 *refill,
 			      u16 *max, u8 *bwg_id, u8 *prio_type);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h
index d5a1e3d..f4fab47 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_82599.h
@@ -99,24 +99,24 @@ s32 ixgbe_dcb_config_pfc_82599(struct ixgbe_hw *hw, u8 pfc_en, u8 *prio_tc);
 
 /* DCB hw initialization */
 s32 ixgbe_dcb_config_rx_arbiter_82599(struct ixgbe_hw *hw,
-					u16 *refill,
-					u16 *max,
-					u8 *bwg_id,
-					u8 *prio_type,
-					u8 *prio_tc);
+				      u16 *refill,
+				      u16 *max,
+				      u8 *bwg_id,
+				      u8 *prio_type,
+				      u8 *prio_tc);
 
 s32 ixgbe_dcb_config_tx_desc_arbiter_82599(struct ixgbe_hw *hw,
-						u16 *refill,
-						u16 *max,
-						u8 *bwg_id,
-						u8 *prio_type);
+					   u16 *refill,
+					   u16 *max,
+					   u8 *bwg_id,
+					   u8 *prio_type);
 
 s32 ixgbe_dcb_config_tx_data_arbiter_82599(struct ixgbe_hw *hw,
-						u16 *refill,
-						u16 *max,
-						u8 *bwg_id,
-						u8 *prio_type,
-						u8 *prio_tc);
+					   u16 *refill,
+					   u16 *max,
+					   u8 *bwg_id,
+					   u8 *prio_type,
+					   u8 *prio_tc);
 
 s32 ixgbe_dcb_hw_config_82599(struct ixgbe_hw *hw, u8 pfc_en, u16 *refill,
 			      u16 *max, u8 *bwg_id, u8 *prio_type,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
index 472b0f4..02cd488 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
@@ -42,7 +42,7 @@ static char ixgbe_dbg_reg_ops_buf[256] = "";
  * @ppos: file position offset
  **/
 static ssize_t ixgbe_dbg_reg_ops_read(struct file *filp, char __user *buffer,
-				    size_t count, loff_t *ppos)
+				      size_t count, loff_t *ppos)
 {
 	struct ixgbe_adapter *adapter = filp->private_data;
 	char *buf;
@@ -77,8 +77,8 @@ static ssize_t ixgbe_dbg_reg_ops_read(struct file *filp, char __user *buffer,
  * @ppos: file position offset
  **/
 static ssize_t ixgbe_dbg_reg_ops_write(struct file *filp,
-				     const char __user *buffer,
-				     size_t count, loff_t *ppos)
+				       const char __user *buffer,
+				       size_t count, loff_t *ppos)
 {
 	struct ixgbe_adapter *adapter = filp->private_data;
 	int len;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 6c55c14..8dd869a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2506,8 +2506,8 @@ static int ixgbe_update_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
 		if (!input || (rule->filter.formatted.bkt_hash !=
 			       input->filter.formatted.bkt_hash)) {
 			err = ixgbe_fdir_erase_perfect_filter_82599(hw,
-								&rule->filter,
-								sw_idx);
+								    &rule->filter,
+								    sw_idx);
 		}
 
 		hlist_del(&rule->fdir_node);
@@ -2675,10 +2675,10 @@ static int ixgbe_add_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
 
 	/* program filters to filter memory */
 	err = ixgbe_fdir_write_perfect_filter_82599(hw,
-				&input->filter, input->sw_idx,
-				(input->action == IXGBE_FDIR_DROP_QUEUE) ?
-				IXGBE_FDIR_DROP_QUEUE :
-				adapter->rx_ring[input->action]->reg_idx);
+						    &input->filter, input->sw_idx,
+						    (input->action == IXGBE_FDIR_DROP_QUEUE) ?
+						    IXGBE_FDIR_DROP_QUEUE :
+						    adapter->rx_ring[input->action]->reg_idx);
 	if (err)
 		goto err_out_w_lock;
 
@@ -2990,7 +2990,7 @@ static int ixgbe_set_channels(struct net_device *dev,
 }
 
 static int ixgbe_get_module_info(struct net_device *dev,
-				       struct ethtool_modinfo *modinfo)
+				 struct ethtool_modinfo *modinfo)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -3031,8 +3031,8 @@ static int ixgbe_get_module_info(struct net_device *dev,
 }
 
 static int ixgbe_get_module_eeprom(struct net_device *dev,
-					 struct ethtool_eeprom *ee,
-					 u8 *data)
+				   struct ethtool_eeprom *ee,
+				   u8 *data)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	struct ixgbe_hw *hw = &adapter->hw;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index 25a3dfe..3501557 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -344,7 +344,7 @@ int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
  * Returns : 1 for success and 0 for no ddp
  */
 int ixgbe_fcoe_ddp_target(struct net_device *netdev, u16 xid,
-			    struct scatterlist *sgl, unsigned int sgc)
+			  struct scatterlist *sgl, unsigned int sgc)
 {
 	return ixgbe_fcoe_ddp_setup(netdev, xid, sgl, sgc, 1);
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9e5a366..03bbb77 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -276,7 +276,7 @@ static void ixgbe_check_minimum_link(struct ixgbe_adapter *adapter,
 	if (max_gts < expected_gts) {
 		e_dev_warn("This is not sufficient for optimal performance of this card.\n");
 		e_dev_warn("For optimal performance, at least %dGT/s of bandwidth is required.\n",
-			expected_gts);
+			   expected_gts);
 		e_dev_warn("A slot with more lanes and/or higher speed is suggested.\n");
 	}
 }
@@ -553,11 +553,11 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 		tx_ring = adapter->tx_ring[n];
 		tx_buffer = &tx_ring->tx_buffer_info[tx_ring->next_to_clean];
 		pr_info(" %5d %5X %5X %016llX %08X %p %016llX\n",
-			   n, tx_ring->next_to_use, tx_ring->next_to_clean,
-			   (u64)dma_unmap_addr(tx_buffer, dma),
-			   dma_unmap_len(tx_buffer, len),
-			   tx_buffer->next_to_watch,
-			   (u64)tx_buffer->time_stamp);
+			n, tx_ring->next_to_use, tx_ring->next_to_clean,
+			(u64)dma_unmap_addr(tx_buffer, dma),
+			dma_unmap_len(tx_buffer, len),
+			tx_buffer->next_to_watch,
+			(u64)tx_buffer->time_stamp);
 	}
 
 	/* Print TX Rings */
@@ -626,7 +626,7 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 					(u64)tx_buffer->time_stamp,
 					tx_buffer->skb);
 				if (i == tx_ring->next_to_use &&
-					i == tx_ring->next_to_clean)
+				    i == tx_ring->next_to_clean)
 					pr_cont(" NTC/U\n");
 				else if (i == tx_ring->next_to_use)
 					pr_cont(" NTU\n");
@@ -638,10 +638,12 @@ static void ixgbe_dump(struct ixgbe_adapter *adapter)
 				if (netif_msg_pktdata(adapter) &&
 				    tx_buffer->skb)
 					print_hex_dump(KERN_INFO, "",
-						DUMP_PREFIX_ADDRESS, 16, 1,
-						tx_buffer->skb->data,
-						dma_unmap_len(tx_buffer, len),
-						true);
+						       DUMP_PREFIX_ADDRESS,
+						       16, 1,
+						       tx_buffer->skb->data,
+						       dma_unmap_len(tx_buffer,
+								     len),
+						       true);
 			}
 		}
 	}
@@ -744,10 +746,12 @@ rx_ring_summary:
 				if (netif_msg_pktdata(adapter) &&
 				    rx_buffer_info->dma) {
 					print_hex_dump(KERN_INFO, "",
-					   DUMP_PREFIX_ADDRESS, 16, 1,
-					   page_address(rx_buffer_info->page) +
-						    rx_buffer_info->page_offset,
-					   ixgbe_rx_bufsz(rx_ring), true);
+						       DUMP_PREFIX_ADDRESS,
+						       16, 1,
+						       page_address(rx_buffer_info->page) +
+						       rx_buffer_info->page_offset,
+						       ixgbe_rx_bufsz(rx_ring),
+						       true);
 				}
 			}
 
@@ -2074,8 +2078,8 @@ dma_sync:
  * Returns amount of work completed
  **/
 static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
-			       struct ixgbe_ring *rx_ring,
-			       const int budget)
+			      struct ixgbe_ring *rx_ring,
+			      const int budget)
 {
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 #ifdef IXGBE_FCOE
@@ -3250,8 +3254,10 @@ static void ixgbe_set_rx_drop_en(struct ixgbe_adapter *adapter)
 	 *  This allows us to avoid head of line blocking for security
 	 *  and performance reasons.
 	 */
-	if (adapter->num_vfs || (adapter->num_rx_queues > 1 &&
-	    !(adapter->hw.fc.current_mode & ixgbe_fc_tx_pause) && !pfc_en)) {
+	if (adapter->num_vfs ||
+	    (adapter->num_rx_queues > 1 &&
+	     !(adapter->hw.fc.current_mode & ixgbe_fc_tx_pause) &&
+	     !pfc_en)) {
 		for (i = 0; i < adapter->num_rx_queues; i++)
 			ixgbe_enable_rx_drop(adapter, adapter->rx_ring[i]);
 	} else {
@@ -3652,7 +3658,8 @@ static void ixgbe_setup_rdrxctl(struct ixgbe_adapter *adapter)
 	case ixgbe_mac_X540:
 		/* Disable RSC for ACK packets */
 		IXGBE_WRITE_REG(hw, IXGBE_RSCDBU,
-		   (IXGBE_RSCDBU_RSCACKDIS | IXGBE_READ_REG(hw, IXGBE_RSCDBU)));
+				(IXGBE_RSCDBU_RSCACKDIS |
+				 IXGBE_READ_REG(hw, IXGBE_RSCDBU)));
 		rdrxctl &= ~IXGBE_RDRXCTL_RSCFRSTSIZE;
 		/* hardware requires some bits to be set by default */
 		rdrxctl |= (IXGBE_RDRXCTL_RSCACKC | IXGBE_RDRXCTL_FCOE_WRFIX);
@@ -4045,9 +4052,9 @@ static void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
 	/* reconfigure the hardware */
 	if (adapter->dcbx_cap & DCB_CAP_DCBX_VER_CEE) {
 		ixgbe_dcb_calculate_tc_credits(hw, &adapter->dcb_cfg, max_frame,
-						DCB_TX_CONFIG);
+					       DCB_TX_CONFIG);
 		ixgbe_dcb_calculate_tc_credits(hw, &adapter->dcb_cfg, max_frame,
-						DCB_RX_CONFIG);
+					       DCB_RX_CONFIG);
 		ixgbe_dcb_hw_config(hw, &adapter->dcb_cfg);
 	} else if (adapter->ixgbe_ieee_ets && adapter->ixgbe_ieee_pfc) {
 		ixgbe_dcb_hw_ets(&adapter->hw,
@@ -4218,11 +4225,11 @@ static void ixgbe_fdir_filter_restore(struct ixgbe_adapter *adapter)
 	hlist_for_each_entry_safe(filter, node2,
 				  &adapter->fdir_filter_list, fdir_node) {
 		ixgbe_fdir_write_perfect_filter_82599(hw,
-				&filter->filter,
-				filter->sw_idx,
-				(filter->action == IXGBE_FDIR_DROP_QUEUE) ?
-				IXGBE_FDIR_DROP_QUEUE :
-				adapter->rx_ring[filter->action]->reg_idx);
+						      &filter->filter,
+						      filter->sw_idx,
+						      (filter->action == IXGBE_FDIR_DROP_QUEUE) ?
+						      IXGBE_FDIR_DROP_QUEUE :
+						      adapter->rx_ring[filter->action]->reg_idx);
 	}
 
 	spin_unlock(&adapter->fdir_perfect_lock);
@@ -5983,7 +5990,7 @@ static void ixgbe_check_hang_subtask(struct ixgbe_adapter *adapter)
 		 * would set *both* EIMS and EICS for any bit in EIAM
 		 */
 		IXGBE_WRITE_REG(hw, IXGBE_EICS,
-			(IXGBE_EICS_TCP_TIMER | IXGBE_EICS_OTHER));
+				(IXGBE_EICS_TCP_TIMER | IXGBE_EICS_OTHER));
 	} else {
 		/* get one bit for every active tx/rx interrupt vector */
 		for (i = 0; i < adapter->num_q_vectors; i++) {
@@ -6594,8 +6601,8 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
 		default:
 			if (unlikely(net_ratelimit())) {
 				dev_warn(tx_ring->dev,
-				 "partial checksum but proto=%x!\n",
-				 first->protocol);
+					 "partial checksum but proto=%x!\n",
+					 first->protocol);
 			}
 			break;
 		}
@@ -6618,8 +6625,8 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
 		default:
 			if (unlikely(net_ratelimit())) {
 				dev_warn(tx_ring->dev,
-				 "partial checksum but l4 proto=%x!\n",
-				 l4_hdr);
+					 "partial checksum but l4 proto=%x!\n",
+					 l4_hdr);
 			}
 			break;
 		}
@@ -6993,8 +7000,8 @@ static u16 ixgbe_select_queue(struct net_device *dev, struct sk_buff *skb,
 }
 
 netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
-			  struct ixgbe_adapter *adapter,
-			  struct ixgbe_ring *tx_ring)
+				  struct ixgbe_adapter *adapter,
+				  struct ixgbe_ring *tx_ring)
 {
 	struct ixgbe_tx_buffer *first;
 	int tso;
@@ -7654,7 +7661,7 @@ static int ixgbe_ndo_bridge_setlink(struct net_device *dev,
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_PFDTXGSWC, reg);
 
 		e_info(drv, "enabling bridge mode: %s\n",
-			mode == BRIDGE_MODE_VEPA ? "VEPA" : "VEB");
+		       mode == BRIDGE_MODE_VEPA ? "VEPA" : "VEB");
 	}
 
 	return 0;
@@ -7702,7 +7709,7 @@ static void *ixgbe_fwd_add(struct net_device *pdev, struct net_device *vdev)
 	}
 
 	if (((adapter->flags & IXGBE_FLAG_DCB_ENABLED) &&
-	      adapter->num_rx_pools > IXGBE_MAX_DCBMACVLANS - 1) ||
+	     adapter->num_rx_pools > IXGBE_MAX_DCBMACVLANS - 1) ||
 	    (adapter->num_rx_pools > IXGBE_MAX_MACVLANS))
 		return ERR_PTR(-EBUSY);
 
@@ -7957,8 +7964,10 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		pci_using_dac = 0;
 	}
 
-	err = pci_request_selected_regions(pdev, pci_select_bars(pdev,
-					   IORESOURCE_MEM), ixgbe_driver_name);
+	err = pci_request_selected_regions(pdev,
+					   pci_select_bars(pdev,
+							   IORESOURCE_MEM),
+					   ixgbe_driver_name);
 	if (err) {
 		dev_err(&pdev->dev,
 			"pci_request_selected_regions failed 0x%x\n", err);
@@ -8371,8 +8380,8 @@ static void ixgbe_remove(struct pci_dev *pdev)
 
 #endif
 	iounmap(adapter->io_addr);
-	pci_release_selected_regions(pdev, pci_select_bars(pdev,
-				     IORESOURCE_MEM));
+	pci_release_selected_regions(pdev,
+				     pci_select_bars(pdev, IORESOURCE_MEM));
 
 	e_dev_info("complete\n");
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c
index f5c6af2..12f8076 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c
@@ -223,7 +223,7 @@ out:
  *  received an ack to that message within delay * timeout period
  **/
 static s32 ixgbe_write_posted_mbx(struct ixgbe_hw *hw, u32 *msg, u16 size,
-                           u16 mbx_id)
+				  u16 mbx_id)
 {
 	struct ixgbe_mbx_info *mbx = &hw->mbx;
 	s32 ret_val = IXGBE_ERR_MBX;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
index ad51c12..6a3d832 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
@@ -243,7 +243,7 @@ out:
  *  @phy_data: Pointer to read data from PHY register
  **/
 s32 ixgbe_read_phy_reg_mdi(struct ixgbe_hw *hw, u32 reg_addr, u32 device_type,
-		       u16 *phy_data)
+			   u16 *phy_data)
 {
 	u32 i, data, command;
 
@@ -348,7 +348,7 @@ s32 ixgbe_read_phy_reg_generic(struct ixgbe_hw *hw, u32 reg_addr,
  *  @phy_data: Data to write to the PHY register
  **/
 s32 ixgbe_write_phy_reg_mdi(struct ixgbe_hw *hw, u32 reg_addr,
-				u32 device_type, u16 phy_data)
+			    u32 device_type, u16 phy_data)
 {
 	u32 i, command;
 
@@ -1071,9 +1071,9 @@ s32 ixgbe_identify_sfp_module_generic(struct ixgbe_hw *hw)
 		/* Determine if the SFP+ PHY is dual speed or not. */
 		hw->phy.multispeed_fiber = false;
 		if (((comp_codes_1g & IXGBE_SFF_1GBASESX_CAPABLE) &&
-		   (comp_codes_10g & IXGBE_SFF_10GBASESR_CAPABLE)) ||
-		   ((comp_codes_1g & IXGBE_SFF_1GBASELX_CAPABLE) &&
-		   (comp_codes_10g & IXGBE_SFF_10GBASELR_CAPABLE)))
+		     (comp_codes_10g & IXGBE_SFF_10GBASESR_CAPABLE)) ||
+		    ((comp_codes_1g & IXGBE_SFF_1GBASELX_CAPABLE) &&
+		     (comp_codes_10g & IXGBE_SFF_10GBASELR_CAPABLE)))
 			hw->phy.multispeed_fiber = true;
 
 		/* Determine PHY vendor */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
index 139eadd..6594c66 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h
@@ -41,7 +41,7 @@ void ixgbe_disable_tx_rx(struct ixgbe_adapter *adapter);
 void ixgbe_ping_all_vfs(struct ixgbe_adapter *adapter);
 int ixgbe_ndo_set_vf_mac(struct net_device *netdev, int queue, u8 *mac);
 int ixgbe_ndo_set_vf_vlan(struct net_device *netdev, int queue, u16 vlan,
-			   u8 qos);
+			  u8 qos);
 int ixgbe_ndo_set_vf_bw(struct net_device *netdev, int vf, int tx_rate);
 int ixgbe_ndo_set_vf_spoofchk(struct net_device *netdev, int vf, bool setting);
 int ixgbe_ndo_get_vf_config(struct net_device *netdev,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
index ef6df3d..baba9ad 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
@@ -69,8 +69,8 @@ static ssize_t ixgbe_hwmon_show_temp(struct device *dev,
 }
 
 static ssize_t ixgbe_hwmon_show_cautionthresh(struct device *dev,
-				     struct device_attribute *attr,
-				     char *buf)
+					      struct device_attribute *attr,
+					      char *buf)
 {
 	struct hwmon_attr *ixgbe_attr = container_of(attr, struct hwmon_attr,
 						     dev_attr);
@@ -83,8 +83,8 @@ static ssize_t ixgbe_hwmon_show_cautionthresh(struct device *dev,
 }
 
 static ssize_t ixgbe_hwmon_show_maxopthresh(struct device *dev,
-				     struct device_attribute *attr,
-				     char *buf)
+					    struct device_attribute *attr,
+					    char *buf)
 {
 	struct hwmon_attr *ixgbe_attr = container_of(attr, struct hwmon_attr,
 						     dev_attr);
diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index b2d0023..c53eed5 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -617,8 +617,8 @@ static int ixgbevf_reg_test(struct ixgbevf_adapter *adapter, u64 *data)
 				break;
 			case WRITE_NO_TEST:
 				ixgbe_write_reg(&adapter->hw,
-						  test->reg + (i * 0x40),
-						  test->write);
+						test->reg + (i * 0x40),
+						test->write);
 				break;
 			case TABLE32_TEST:
 				b = reg_pattern_test(adapter, data,
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index a50e892..04cfbe4 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -188,7 +188,7 @@ static void ixgbevf_set_ivar(struct ixgbevf_adapter *adapter, s8 direction,
 }
 
 static void ixgbevf_unmap_and_free_tx_resource(struct ixgbevf_ring *tx_ring,
-					struct ixgbevf_tx_buffer *tx_buffer)
+					       struct ixgbevf_tx_buffer *tx_buffer)
 {
 	if (tx_buffer->skb) {
 		dev_kfree_skb_any(tx_buffer->skb);
@@ -560,7 +560,7 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		 * source pruning.
 		 */
 		if ((skb->pkt_type == PACKET_BROADCAST ||
-		    skb->pkt_type == PACKET_MULTICAST) &&
+		     skb->pkt_type == PACKET_MULTICAST) &&
 		    ether_addr_equal(rx_ring->netdev->dev_addr,
 				     eth_hdr(skb)->h_source)) {
 			dev_kfree_skb_irq(skb);
@@ -2454,8 +2454,8 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 				link_speed_string = "unknown speed";
 				break;
 			}
-			dev_info(&adapter->pdev->dev,
-				"NIC Link is Up, %s\n", link_speed_string);
+			dev_info(&adapter->pdev->dev, "NIC Link is Up, %s\n",
+				 link_speed_string);
 			netif_carrier_on(netdev);
 			netif_tx_wake_all_queues(netdev);
 		}
@@ -2924,8 +2924,8 @@ static void ixgbevf_tx_csum(struct ixgbevf_ring *tx_ring,
 		default:
 			if (unlikely(net_ratelimit())) {
 				dev_warn(tx_ring->dev,
-				 "partial checksum but proto=%x!\n",
-				 first->protocol);
+					 "partial checksum but proto=%x!\n",
+					 first->protocol);
 			}
 			break;
 		}
@@ -2948,8 +2948,8 @@ static void ixgbevf_tx_csum(struct ixgbevf_ring *tx_ring,
 		default:
 			if (unlikely(net_ratelimit())) {
 				dev_warn(tx_ring->dev,
-				 "partial checksum but l4 proto=%x!\n",
-				 l4_hdr);
+					 "partial checksum but l4 proto=%x!\n",
+					 l4_hdr);
 			}
 			break;
 		}
@@ -3383,7 +3383,7 @@ static void ixgbevf_shutdown(struct pci_dev *pdev)
 }
 
 static struct rtnl_link_stats64 *ixgbevf_get_stats(struct net_device *netdev,
-						struct rtnl_link_stats64 *stats)
+						   struct rtnl_link_stats64 *stats)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	unsigned int start;
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 4d44d64..0551536 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -291,8 +291,7 @@ static s32 ixgbevf_set_rar_vf(struct ixgbe_hw *hw, u32 index, u8 *addr,
 	return ret_val;
 }
 
-static void ixgbevf_write_msg_read_ack(struct ixgbe_hw *hw,
-					u32 *msg, u16 size)
+static void ixgbevf_write_msg_read_ack(struct ixgbe_hw *hw, u32 *msg, u16 size)
 {
 	struct ixgbe_mbx_info *mbx = &hw->mbx;
 	u32 retmsg[IXGBE_VFMAILBOX_SIZE];
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index 096d33a..2895139 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -190,14 +190,14 @@ u32 ixgbe_read_reg(struct ixgbe_hw *hw, u32 reg);
 #define IXGBE_READ_REG(h, r) ixgbe_read_reg(h, r)
 
 static inline void ixgbe_write_reg_array(struct ixgbe_hw *hw, u32 reg,
-					  u32 offset, u32 value)
+					 u32 offset, u32 value)
 {
 	ixgbe_write_reg(hw, reg + (offset << 2), value);
 }
 #define IXGBE_WRITE_REG_ARRAY(h, r, o, v) ixgbe_write_reg_array(h, r, o, v)
 
 static inline u32 ixgbe_read_reg_array(struct ixgbe_hw *hw, u32 reg,
-					u32 offset)
+				       u32 offset)
 {
 	return ixgbe_read_reg(hw, reg + (offset << 2));
 }
