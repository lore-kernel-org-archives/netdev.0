From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] e1000e: cleanup (add/remove) blank lines where appropriate
Date: Fri,  8 Mar 2013 02:07:11 -0800
Message-ID: <1362737237-13363-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51324 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933982Ab3CHKHc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 05:07:32 -0500
In-Reply-To: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/80003es2lan.c | 2 +-
 drivers/net/ethernet/intel/e1000e/82571.c       | 2 +-
 drivers/net/ethernet/intel/e1000e/defines.h     | 1 -
 drivers/net/ethernet/intel/e1000e/e1000.h       | 1 -
 drivers/net/ethernet/intel/e1000e/ethtool.c     | 2 ++
 drivers/net/ethernet/intel/e1000e/ich8lan.c     | 2 +-
 drivers/net/ethernet/intel/e1000e/netdev.c      | 3 +--
 drivers/net/ethernet/intel/e1000e/phy.c         | 2 ++
 8 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.c b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
index 6c0d96b..d75ace9 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -38,6 +38,7 @@
  */
 static const u16 e1000_gg82563_cable_length_table[] = {
 	 0, 60, 115, 150, 150, 60, 115, 150, 180, 180, 0xFF };
+
 #define GG82563_CABLE_LENGTH_TABLE_SIZE \
 		ARRAY_SIZE(e1000_gg82563_cable_length_table)
 
@@ -1417,4 +1418,3 @@ const struct e1000_info e1000_es2_info = {
 	.phy_ops		= &es2_phy_ops,
 	.nvm_ops		= &es2_nvm_ops,
 };
-
diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 64fc15b..49341c0 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -526,6 +526,7 @@ static void e1000_put_hw_semaphore_82571(struct e1000_hw *hw)
 	swsm &= ~(E1000_SWSM_SMBI | E1000_SWSM_SWESMBI);
 	ew32(SWSM, swsm);
 }
+
 /**
  *  e1000_get_hw_semaphore_82573 - Acquire hardware semaphore
  *  @hw: pointer to the HW structure
@@ -2066,4 +2067,3 @@ const struct e1000_info e1000_82583_info = {
 	.phy_ops		= &e82_phy_ops_bm,
 	.nvm_ops		= &e82571_nvm_ops,
 };
-
diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
index 5af602a..e6fe090 100644
--- a/drivers/net/ethernet/intel/e1000e/defines.h
+++ b/drivers/net/ethernet/intel/e1000e/defines.h
@@ -244,7 +244,6 @@
 #define HALF_DUPLEX 1
 #define FULL_DUPLEX 2
 
-
 #define ADVERTISE_10_HALF                 0x0001
 #define ADVERTISE_10_FULL                 0x0002
 #define ADVERTISE_100_HALF                0x0004
diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 6ce64ae..3ecc988 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -61,7 +61,6 @@ struct e1000_info;
 #define e_notice(format, arg...) \
 	netdev_notice(adapter->netdev, format, ## arg)
 
-
 /* Interrupt modes, as used by the IntMode parameter */
 #define E1000E_INT_MODE_LEGACY		0
 #define E1000E_INT_MODE_MSI		1
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 07ef74e..c47dee6 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -120,6 +120,7 @@ static const char e1000_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Interrupt test (offline)", "Loopback test  (offline)",
 	"Link test   (on/offline)"
 };
+
 #define E1000_TEST_LEN ARRAY_SIZE(e1000_gstrings_test)
 
 static int e1000_get_settings(struct net_device *netdev,
@@ -783,6 +784,7 @@ static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data,
 	}
 	return 0;
 }
+
 #define REG_PATTERN_TEST_ARRAY(reg, offset, mask, write)                       \
 	do {                                                                   \
 		if (reg_pattern_test(adapter, data, reg, offset, mask, write)) \
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index dd67cb6..6ff7ff5 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1606,7 +1606,6 @@ release:
 	return ret_val;
 }
 
-
 /**
  *  e1000_set_mdio_slow_mode_hv - Set slow MDIO access mode
  *  @hw:   pointer to the HW structure
@@ -3517,6 +3516,7 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 
 	return ret_val;
 }
+
 /**
  *  e1000_initialize_hw_bits_ich8lan - Initialize required hardware bits
  *  @hw: pointer to the HW structure
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index ca1c10e..172d2e3 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1542,7 +1542,6 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_ring *rx_ring, int *work_done,
 			rx_ring->rx_skb_top = NULL;
 			goto next_desc;
 		}
-
 #define rxtop (rx_ring->rx_skb_top)
 		if (!(staterr & E1000_RXD_STAT_EOP)) {
 			/* this descriptor is only the beginning (or middle) */
@@ -1916,7 +1915,6 @@ static irqreturn_t e1000_intr_msix_tx(int __always_unused irq, void *data)
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_ring *tx_ring = adapter->tx_ring;
 
-
 	adapter->total_tx_bytes = 0;
 	adapter->total_tx_packets = 0;
 
@@ -4384,6 +4382,7 @@ static int e1000_close(struct net_device *netdev)
 
 	return 0;
 }
+
 /**
  * e1000_set_mac - Change the Ethernet Address of the NIC
  * @netdev: network interface device structure
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index 50e84ed..0a81d14 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -38,6 +38,7 @@ static s32 e1000_access_phy_debug_regs_hv(struct e1000_hw *hw, u32 offset,
 /* Cable length tables */
 static const u16 e1000_m88_cable_length_table[] = {
 	0, 50, 80, 110, 140, 140, E1000_CABLE_LENGTH_UNDEFINED };
+
 #define M88E1000_CABLE_LENGTH_TABLE_SIZE \
 		ARRAY_SIZE(e1000_m88_cable_length_table)
 
@@ -50,6 +51,7 @@ static const u16 e1000_igp_2_cable_length_table[] = {
 	87, 92, 96, 100, 104, 108, 111, 114, 117, 119, 121, 83, 89, 95,
 	100, 105, 109, 113, 116, 119, 122, 124, 104, 109, 114, 118, 121,
 	124};
+
 #define IGP02E1000_CABLE_LENGTH_TABLE_SIZE \
 		ARRAY_SIZE(e1000_igp_2_cable_length_table)
 
-- 
1.7.11.7
