From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/6] drivers/net/e1000 - Convert u_int32_t to
	u32
Date: Tue, 18 Mar 2008 09:13:46 -0700
Message-ID: <d676af35dec3f20916505c18edea9ee1ae87a744.1205779102.git.joe@perches.com>
References: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
	<41caf0b437b073665972eae10027d13c4ccb5097.1205779102.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>, Jeb Cramer <cramerj@intel.com>
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <41caf0b437b073665972eae10027d13c4ccb5097.1205779102.git.joe@perches.com>
In-Reply-To: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
References: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/e1000/e1000.h         |   42 ++--
 drivers/net/e1000/e1000_ethtool.c |   82 ++++----
 drivers/net/e1000/e1000_hw.c      |  428 ++++++++++++++++++------------------
 drivers/net/e1000/e1000_hw.h      |  110 +++++-----
 drivers/net/e1000/e1000_main.c    |   90 ++++----
 5 files changed, 376 insertions(+), 376 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 4a0ce08..c92bc65 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -238,11 +238,11 @@ struct e1000_adapter {
 	struct timer_list phy_info_timer;
 	struct vlan_group *vlgrp;
 	u16 mng_vlan_id;
-	uint32_t bd_number;
-	uint32_t rx_buffer_len;
-	uint32_t wol;
-	uint32_t smartspeed;
-	uint32_t en_mng_pt;
+	u32 bd_number;
+	u32 rx_buffer_len;
+	u32 wol;
+	u32 smartspeed;
+	u32 en_mng_pt;
 	u16 link_speed;
 	u16 link_duplex;
 	spinlock_t stats_lock;
@@ -254,8 +254,8 @@ struct e1000_adapter {
 	unsigned int total_rx_bytes;
 	unsigned int total_rx_packets;
 	/* Interrupt Throttle Rate */
-	uint32_t itr;
-	uint32_t itr_setting;
+	u32 itr;
+	u32 itr_setting;
 	u16 tx_itr;
 	u16 rx_itr;
 
@@ -269,17 +269,17 @@ struct e1000_adapter {
 	struct e1000_tx_ring *tx_ring;      /* One per active queue */
 	unsigned int restart_queue;
 	unsigned long tx_queue_len;
-	uint32_t txd_cmd;
-	uint32_t tx_int_delay;
-	uint32_t tx_abs_int_delay;
-	uint32_t gotcl;
+	u32 txd_cmd;
+	u32 tx_int_delay;
+	u32 tx_abs_int_delay;
+	u32 gotcl;
 	uint64_t gotcl_old;
 	uint64_t tpt_old;
 	uint64_t colc_old;
-	uint32_t tx_timeout_count;
-	uint32_t tx_fifo_head;
-	uint32_t tx_head_addr;
-	uint32_t tx_fifo_size;
+	u32 tx_timeout_count;
+	u32 tx_fifo_head;
+	u32 tx_head_addr;
+	u32 tx_fifo_size;
 	u8  tx_timeout_factor;
 	atomic_t tx_fifo_stall;
 	bool pcix_82544;
@@ -308,12 +308,12 @@ struct e1000_adapter {
 	uint64_t hw_csum_err;
 	uint64_t hw_csum_good;
 	uint64_t rx_hdr_split;
-	uint32_t alloc_rx_buff_failed;
-	uint32_t rx_int_delay;
-	uint32_t rx_abs_int_delay;
+	u32 alloc_rx_buff_failed;
+	u32 rx_int_delay;
+	u32 rx_abs_int_delay;
 	bool rx_csum;
 	unsigned int rx_ps_pages;
-	uint32_t gorcl;
+	u32 gorcl;
 	uint64_t gorcl_old;
 	u16 rx_ps_bsize0;
 
@@ -329,7 +329,7 @@ struct e1000_adapter {
 	struct e1000_phy_info phy_info;
 	struct e1000_phy_stats phy_stats;
 
-	uint32_t test_icr;
+	u32 test_icr;
 	struct e1000_tx_ring test_tx_ring;
 	struct e1000_rx_ring test_rx_ring;
 
@@ -341,7 +341,7 @@ struct e1000_adapter {
 	bool smart_power_down;	/* phy smart power down */
 	bool quad_port_a;
 	unsigned long flags;
-	uint32_t eeprom_wol;
+	u32 eeprom_wol;
 };
 
 enum e1000_state_t {
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 92d4a45..11bbd50 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -289,7 +289,7 @@ e1000_set_pauseparam(struct net_device *netdev,
 	return retval;
 }
 
-static uint32_t
+static u32
 e1000_get_rx_csum(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -297,7 +297,7 @@ e1000_get_rx_csum(struct net_device *netdev)
 }
 
 static int
-e1000_set_rx_csum(struct net_device *netdev, uint32_t data)
+e1000_set_rx_csum(struct net_device *netdev, u32 data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	adapter->rx_csum = data;
@@ -309,14 +309,14 @@ e1000_set_rx_csum(struct net_device *netdev, uint32_t data)
 	return 0;
 }
 
-static uint32_t
+static u32
 e1000_get_tx_csum(struct net_device *netdev)
 {
 	return (netdev->features & NETIF_F_HW_CSUM) != 0;
 }
 
 static int
-e1000_set_tx_csum(struct net_device *netdev, uint32_t data)
+e1000_set_tx_csum(struct net_device *netdev, u32 data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
@@ -335,7 +335,7 @@ e1000_set_tx_csum(struct net_device *netdev, uint32_t data)
 }
 
 static int
-e1000_set_tso(struct net_device *netdev, uint32_t data)
+e1000_set_tso(struct net_device *netdev, u32 data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	if ((adapter->hw.mac_type < e1000_82544) ||
@@ -357,7 +357,7 @@ e1000_set_tso(struct net_device *netdev, uint32_t data)
 	return 0;
 }
 
-static uint32_t
+static u32
 e1000_get_msglevel(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
@@ -365,7 +365,7 @@ e1000_get_msglevel(struct net_device *netdev)
 }
 
 static void
-e1000_set_msglevel(struct net_device *netdev, uint32_t data)
+e1000_set_msglevel(struct net_device *netdev, u32 data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	adapter->msg_enable = data;
@@ -375,7 +375,7 @@ static int
 e1000_get_regs_len(struct net_device *netdev)
 {
 #define E1000_REGS_LEN 32
-	return E1000_REGS_LEN * sizeof(uint32_t);
+	return E1000_REGS_LEN * sizeof(u32);
 }
 
 static void
@@ -384,10 +384,10 @@ e1000_get_regs(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	uint32_t *regs_buff = p;
+	u32 *regs_buff = p;
 	u16 phy_data;
 
-	memset(p, 0, E1000_REGS_LEN * sizeof(uint32_t));
+	memset(p, 0, E1000_REGS_LEN * sizeof(u32));
 
 	regs->version = (1 << 24) | (hw->revision_id << 16) | hw->device_id;
 
@@ -412,44 +412,44 @@ e1000_get_regs(struct net_device *netdev,
 				    IGP01E1000_PHY_AGC_A);
 		e1000_read_phy_reg(hw, IGP01E1000_PHY_AGC_A &
 				   IGP01E1000_PHY_PAGE_SELECT, &phy_data);
-		regs_buff[13] = (uint32_t)phy_data; /* cable length */
+		regs_buff[13] = (u32)phy_data; /* cable length */
 		e1000_write_phy_reg(hw, IGP01E1000_PHY_PAGE_SELECT,
 				    IGP01E1000_PHY_AGC_B);
 		e1000_read_phy_reg(hw, IGP01E1000_PHY_AGC_B &
 				   IGP01E1000_PHY_PAGE_SELECT, &phy_data);
-		regs_buff[14] = (uint32_t)phy_data; /* cable length */
+		regs_buff[14] = (u32)phy_data; /* cable length */
 		e1000_write_phy_reg(hw, IGP01E1000_PHY_PAGE_SELECT,
 				    IGP01E1000_PHY_AGC_C);
 		e1000_read_phy_reg(hw, IGP01E1000_PHY_AGC_C &
 				   IGP01E1000_PHY_PAGE_SELECT, &phy_data);
-		regs_buff[15] = (uint32_t)phy_data; /* cable length */
+		regs_buff[15] = (u32)phy_data; /* cable length */
 		e1000_write_phy_reg(hw, IGP01E1000_PHY_PAGE_SELECT,
 				    IGP01E1000_PHY_AGC_D);
 		e1000_read_phy_reg(hw, IGP01E1000_PHY_AGC_D &
 				   IGP01E1000_PHY_PAGE_SELECT, &phy_data);
-		regs_buff[16] = (uint32_t)phy_data; /* cable length */
+		regs_buff[16] = (u32)phy_data; /* cable length */
 		regs_buff[17] = 0; /* extended 10bt distance (not needed) */
 		e1000_write_phy_reg(hw, IGP01E1000_PHY_PAGE_SELECT, 0x0);
 		e1000_read_phy_reg(hw, IGP01E1000_PHY_PORT_STATUS &
 				   IGP01E1000_PHY_PAGE_SELECT, &phy_data);
-		regs_buff[18] = (uint32_t)phy_data; /* cable polarity */
+		regs_buff[18] = (u32)phy_data; /* cable polarity */
 		e1000_write_phy_reg(hw, IGP01E1000_PHY_PAGE_SELECT,
 				    IGP01E1000_PHY_PCS_INIT_REG);
 		e1000_read_phy_reg(hw, IGP01E1000_PHY_PCS_INIT_REG &
 				   IGP01E1000_PHY_PAGE_SELECT, &phy_data);
-		regs_buff[19] = (uint32_t)phy_data; /* cable polarity */
+		regs_buff[19] = (u32)phy_data; /* cable polarity */
 		regs_buff[20] = 0; /* polarity correction enabled (always) */
 		regs_buff[22] = 0; /* phy receive errors (unavailable) */
 		regs_buff[23] = regs_buff[18]; /* mdix mode */
 		e1000_write_phy_reg(hw, IGP01E1000_PHY_PAGE_SELECT, 0x0);
 	} else {
 		e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_STATUS, &phy_data);
-		regs_buff[13] = (uint32_t)phy_data; /* cable length */
+		regs_buff[13] = (u32)phy_data; /* cable length */
 		regs_buff[14] = 0;  /* Dummy (to align w/ IGP phy reg dump) */
 		regs_buff[15] = 0;  /* Dummy (to align w/ IGP phy reg dump) */
 		regs_buff[16] = 0;  /* Dummy (to align w/ IGP phy reg dump) */
 		e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_data);
-		regs_buff[17] = (uint32_t)phy_data; /* extended 10bt distance */
+		regs_buff[17] = (u32)phy_data; /* extended 10bt distance */
 		regs_buff[18] = regs_buff[13]; /* cable polarity */
 		regs_buff[19] = 0;  /* Dummy (to align w/ IGP phy reg dump) */
 		regs_buff[20] = regs_buff[17]; /* polarity correction */
@@ -459,7 +459,7 @@ e1000_get_regs(struct net_device *netdev,
 	}
 	regs_buff[21] = adapter->phy_stats.idle_errors;  /* phy idle errors */
 	e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_data);
-	regs_buff[24] = (uint32_t)phy_data;  /* phy local receiver status */
+	regs_buff[24] = (u32)phy_data;  /* phy local receiver status */
 	regs_buff[25] = regs_buff[24];  /* phy remote receiver status */
 	if (hw->mac_type >= e1000_82540 &&
 	    hw->mac_type < e1000_82571 &&
@@ -674,13 +674,13 @@ e1000_set_ringparam(struct net_device *netdev,
 	adapter->tx_ring = txdr;
 	adapter->rx_ring = rxdr;
 
-	rxdr->count = max(ring->rx_pending,(uint32_t)E1000_MIN_RXD);
-	rxdr->count = min(rxdr->count,(uint32_t)(mac_type < e1000_82544 ?
+	rxdr->count = max(ring->rx_pending,(u32)E1000_MIN_RXD);
+	rxdr->count = min(rxdr->count,(u32)(mac_type < e1000_82544 ?
 		E1000_MAX_RXD : E1000_MAX_82544_RXD));
 	rxdr->count = ALIGN(rxdr->count, REQ_RX_DESCRIPTOR_MULTIPLE);
 
-	txdr->count = max(ring->tx_pending,(uint32_t)E1000_MIN_TXD);
-	txdr->count = min(txdr->count,(uint32_t)(mac_type < e1000_82544 ?
+	txdr->count = max(ring->tx_pending,(u32)E1000_MIN_TXD);
+	txdr->count = min(txdr->count,(u32)(mac_type < e1000_82544 ?
 		E1000_MAX_TXD : E1000_MAX_82544_TXD));
 	txdr->count = ALIGN(txdr->count, REQ_TX_DESCRIPTOR_MULTIPLE);
 
@@ -729,12 +729,12 @@ err_setup:
 }
 
 static bool reg_pattern_test(struct e1000_adapter *adapter, uint64_t *data,
-			     int reg, uint32_t mask, uint32_t write)
+			     int reg, u32 mask, u32 write)
 {
-	static const uint32_t test[] =
+	static const u32 test[] =
 		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
 	u8 __iomem *address = adapter->hw.hw_addr + reg;
-	uint32_t read;
+	u32 read;
 	int i;
 
 	for (i = 0; i < ARRAY_SIZE(test); i++) {
@@ -752,10 +752,10 @@ static bool reg_pattern_test(struct e1000_adapter *adapter, uint64_t *data,
 }
 
 static bool reg_set_and_check(struct e1000_adapter *adapter, uint64_t *data,
-			      int reg, uint32_t mask, uint32_t write)
+			      int reg, u32 mask, u32 write)
 {
 	u8 __iomem *address = adapter->hw.hw_addr + reg;
-	uint32_t read;
+	u32 read;
 
 	writel(write & mask, address);
 	read = readl(address);
@@ -790,8 +790,8 @@ static bool reg_set_and_check(struct e1000_adapter *adapter, uint64_t *data,
 static int
 e1000_reg_test(struct e1000_adapter *adapter, uint64_t *data)
 {
-	uint32_t value, before, after;
-	uint32_t i, toggle;
+	u32 value, before, after;
+	u32 i, toggle;
 
 	/* The status register is Read Only, so a write should fail.
 	 * Some bits that get toggled are ignored.
@@ -922,9 +922,9 @@ static int
 e1000_intr_test(struct e1000_adapter *adapter, uint64_t *data)
 {
 	struct net_device *netdev = adapter->netdev;
-	uint32_t mask, i = 0;
+	u32 mask, i = 0;
 	bool shared_int = true;
-	uint32_t irq = adapter->pdev->irq;
+	u32 irq = adapter->pdev->irq;
 
 	*data = 0;
 
@@ -1070,7 +1070,7 @@ e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	struct e1000_tx_ring *txdr = &adapter->test_tx_ring;
 	struct e1000_rx_ring *rxdr = &adapter->test_rx_ring;
 	struct pci_dev *pdev = adapter->pdev;
-	uint32_t rctl;
+	u32 rctl;
 	int i, ret_val;
 
 	/* Setup Tx descriptor ring and Tx buffers */
@@ -1226,7 +1226,7 @@ e1000_phy_reset_clk_and_crs(struct e1000_adapter *adapter)
 static int
 e1000_nonintegrated_phy_loopback(struct e1000_adapter *adapter)
 {
-	uint32_t ctrl_reg;
+	u32 ctrl_reg;
 	u16 phy_reg;
 
 	/* Setup the Device Control Register for PHY loopback test. */
@@ -1293,8 +1293,8 @@ e1000_nonintegrated_phy_loopback(struct e1000_adapter *adapter)
 static int
 e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 {
-	uint32_t ctrl_reg = 0;
-	uint32_t stat_reg = 0;
+	u32 ctrl_reg = 0;
+	u32 stat_reg = 0;
 
 	adapter->hw.autoneg = false;
 
@@ -1416,7 +1416,7 @@ static int
 e1000_setup_loopback_test(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	uint32_t rctl;
+	u32 rctl;
 
 	if (hw->media_type == e1000_media_type_fiber ||
 	    hw->media_type == e1000_media_type_internal_serdes) {
@@ -1451,7 +1451,7 @@ static void
 e1000_loopback_cleanup(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	uint32_t rctl;
+	u32 rctl;
 	u16 phy_reg;
 
 	rctl = E1000_READ_REG(hw, RCTL);
@@ -1877,7 +1877,7 @@ e1000_led_blink_callback(unsigned long data)
 }
 
 static int
-e1000_phys_id(struct net_device *netdev, uint32_t data)
+e1000_phys_id(struct net_device *netdev, u32 data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
@@ -1936,13 +1936,13 @@ e1000_get_ethtool_stats(struct net_device *netdev,
 	for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
 		char *p = (char *)adapter+e1000_gstrings_stats[i].stat_offset;
 		data[i] = (e1000_gstrings_stats[i].sizeof_stat ==
-			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
+			sizeof(uint64_t)) ? *(uint64_t *)p : *(u32 *)p;
 	}
 /*	BUG_ON(i != E1000_STATS_LEN); */
 }
 
 static void
-e1000_get_strings(struct net_device *netdev, uint32_t stringset, u8 *data)
+e1000_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 {
 	u8 *p = data;
 	int i;
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 6f6d79f..33bdd62 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -35,8 +35,8 @@
 
 static int32_t e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask);
 static void e1000_swfw_sync_release(struct e1000_hw *hw, u16 mask);
-static int32_t e1000_read_kmrn_reg(struct e1000_hw *hw, uint32_t reg_addr, u16 *data);
-static int32_t e1000_write_kmrn_reg(struct e1000_hw *hw, uint32_t reg_addr, u16 data);
+static int32_t e1000_read_kmrn_reg(struct e1000_hw *hw, u32 reg_addr, u16 *data);
+static int32_t e1000_write_kmrn_reg(struct e1000_hw *hw, u32 reg_addr, u16 data);
 static int32_t e1000_get_software_semaphore(struct e1000_hw *hw);
 static void e1000_release_software_semaphore(struct e1000_hw *hw);
 
@@ -50,16 +50,16 @@ static int32_t e1000_config_dsp_after_link_change(struct e1000_hw *hw,
 						  bool link_up);
 static int32_t e1000_config_fc_after_link_up(struct e1000_hw *hw);
 static int32_t e1000_detect_gig_phy(struct e1000_hw *hw);
-static int32_t e1000_erase_ich8_4k_segment(struct e1000_hw *hw, uint32_t bank);
+static int32_t e1000_erase_ich8_4k_segment(struct e1000_hw *hw, u32 bank);
 static int32_t e1000_get_auto_rd_done(struct e1000_hw *hw);
 static int32_t e1000_get_cable_length(struct e1000_hw *hw, u16 *min_length, u16 *max_length);
 static int32_t e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw);
 static int32_t e1000_get_phy_cfg_done(struct e1000_hw *hw);
 static int32_t e1000_get_software_flag(struct e1000_hw *hw);
 static int32_t e1000_ich8_cycle_init(struct e1000_hw *hw);
-static int32_t e1000_ich8_flash_cycle(struct e1000_hw *hw, uint32_t timeout);
+static int32_t e1000_ich8_flash_cycle(struct e1000_hw *hw, u32 timeout);
 static int32_t e1000_id_led_init(struct e1000_hw *hw);
-static int32_t e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw, uint32_t cnf_base_addr, uint32_t cnf_size);
+static int32_t e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw, u32 cnf_base_addr, u32 cnf_size);
 static int32_t e1000_init_lcd_from_nvm(struct e1000_hw *hw);
 static void e1000_init_rx_addrs(struct e1000_hw *hw);
 static void e1000_initialize_hardware_bits(struct e1000_hw *hw);
@@ -76,21 +76,21 @@ static int32_t e1000_write_eeprom_eewr(struct e1000_hw *hw, u16 offset, u16 word
 static int32_t e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd);
 static int32_t e1000_phy_m88_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
 static void e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw);
-static int32_t e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index, u8 *data);
-static int32_t e1000_verify_write_ich8_byte(struct e1000_hw *hw, uint32_t index, u8 byte);
-static int32_t e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index, u8 byte);
-static int32_t e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index, u16 *data);
-static int32_t e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size, u16 *data);
-static int32_t e1000_write_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size, u16 data);
+static int32_t e1000_read_ich8_byte(struct e1000_hw *hw, u32 index, u8 *data);
+static int32_t e1000_verify_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte);
+static int32_t e1000_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte);
+static int32_t e1000_read_ich8_word(struct e1000_hw *hw, u32 index, u16 *data);
+static int32_t e1000_read_ich8_data(struct e1000_hw *hw, u32 index, u32 size, u16 *data);
+static int32_t e1000_write_ich8_data(struct e1000_hw *hw, u32 index, u32 size, u16 data);
 static int32_t e1000_read_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 static int32_t e1000_write_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 static void e1000_release_software_flag(struct e1000_hw *hw);
 static int32_t e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active);
 static int32_t e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active);
-static int32_t e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, uint32_t no_snoop);
+static int32_t e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, u32 no_snoop);
 static void e1000_set_pci_express_master_disable(struct e1000_hw *hw);
 static int32_t e1000_wait_autoneg(struct e1000_hw *hw);
-static void e1000_write_reg_io(struct e1000_hw *hw, uint32_t offset, uint32_t value);
+static void e1000_write_reg_io(struct e1000_hw *hw, u32 offset, u32 value);
 static int32_t e1000_set_phy_type(struct e1000_hw *hw);
 static void e1000_phy_init_script(struct e1000_hw *hw);
 static int32_t e1000_setup_copper_link(struct e1000_hw *hw);
@@ -98,9 +98,9 @@ static int32_t e1000_setup_fiber_serdes_link(struct e1000_hw *hw);
 static int32_t e1000_adjust_serdes_amplitude(struct e1000_hw *hw);
 static int32_t e1000_phy_force_speed_duplex(struct e1000_hw *hw);
 static int32_t e1000_config_mac_to_phy(struct e1000_hw *hw);
-static void e1000_raise_mdi_clk(struct e1000_hw *hw, uint32_t *ctrl);
-static void e1000_lower_mdi_clk(struct e1000_hw *hw, uint32_t *ctrl);
-static void e1000_shift_out_mdi_bits(struct e1000_hw *hw, uint32_t data,
+static void e1000_raise_mdi_clk(struct e1000_hw *hw, u32 *ctrl);
+static void e1000_lower_mdi_clk(struct e1000_hw *hw, u32 *ctrl);
+static void e1000_shift_out_mdi_bits(struct e1000_hw *hw, u32 data,
                                      u16 count);
 static u16 e1000_shift_in_mdi_bits(struct e1000_hw *hw);
 static int32_t e1000_phy_reset_dsp(struct e1000_hw *hw);
@@ -110,13 +110,13 @@ static int32_t e1000_write_eeprom_microwire(struct e1000_hw *hw,
                                             u16 offset, u16 words,
                                             u16 *data);
 static int32_t e1000_spi_eeprom_ready(struct e1000_hw *hw);
-static void e1000_raise_ee_clk(struct e1000_hw *hw, uint32_t *eecd);
-static void e1000_lower_ee_clk(struct e1000_hw *hw, uint32_t *eecd);
+static void e1000_raise_ee_clk(struct e1000_hw *hw, u32 *eecd);
+static void e1000_lower_ee_clk(struct e1000_hw *hw, u32 *eecd);
 static void e1000_shift_out_ee_bits(struct e1000_hw *hw, u16 data,
                                     u16 count);
-static int32_t e1000_write_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
+static int32_t e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
                                       u16 phy_data);
-static int32_t e1000_read_phy_reg_ex(struct e1000_hw *hw,uint32_t reg_addr,
+static int32_t e1000_read_phy_reg_ex(struct e1000_hw *hw,u32 reg_addr,
                                      u16 *phy_data);
 static u16 e1000_shift_in_ee_bits(struct e1000_hw *hw, u16 count);
 static int32_t e1000_acquire_eeprom(struct e1000_hw *hw);
@@ -126,7 +126,7 @@ static int32_t e1000_set_vco_speed(struct e1000_hw *hw);
 static int32_t e1000_polarity_reversal_workaround(struct e1000_hw *hw);
 static int32_t e1000_set_phy_mode(struct e1000_hw *hw);
 static int32_t e1000_host_if_read_cookie(struct e1000_hw *hw, u8 *buffer);
-static u8 e1000_calculate_mng_checksum(char *buffer, uint32_t length);
+static u8 e1000_calculate_mng_checksum(char *buffer, u32 length);
 static int32_t e1000_configure_kmrn_for_10_100(struct e1000_hw *hw,
                                                u16 duplex);
 static int32_t e1000_configure_kmrn_for_1000(struct e1000_hw *hw);
@@ -213,7 +213,7 @@ e1000_set_phy_type(struct e1000_hw *hw)
 static void
 e1000_phy_init_script(struct e1000_hw *hw)
 {
-    uint32_t ret_val;
+    u32 ret_val;
     u16 phy_saved_data;
 
     DEBUGFUNC("e1000_phy_init_script");
@@ -477,7 +477,7 @@ e1000_set_mac_type(struct e1000_hw *hw)
 void
 e1000_set_media_type(struct e1000_hw *hw)
 {
-    uint32_t status;
+    u32 status;
 
     DEBUGFUNC("e1000_set_media_type");
 
@@ -531,13 +531,13 @@ e1000_set_media_type(struct e1000_hw *hw)
 int32_t
 e1000_reset_hw(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
-    uint32_t ctrl_ext;
-    uint32_t icr;
-    uint32_t manc;
-    uint32_t led_ctrl;
-    uint32_t timeout;
-    uint32_t extcnf_ctrl;
+    u32 ctrl;
+    u32 ctrl_ext;
+    u32 icr;
+    u32 manc;
+    u32 led_ctrl;
+    u32 timeout;
+    u32 extcnf_ctrl;
     int32_t ret_val;
 
     DEBUGFUNC("e1000_reset_hw");
@@ -730,7 +730,7 @@ e1000_reset_hw(struct e1000_hw *hw)
     }
 
     if (hw->mac_type == e1000_ich8lan) {
-        uint32_t kab = E1000_READ_REG(hw, KABGTXD);
+        u32 kab = E1000_READ_REG(hw, KABGTXD);
         kab |= E1000_KABGTXD_BGSQLBIAS;
         E1000_WRITE_REG(hw, KABGTXD, kab);
     }
@@ -752,10 +752,10 @@ e1000_initialize_hardware_bits(struct e1000_hw *hw)
 {
     if ((hw->mac_type >= e1000_82571) && (!hw->initialize_hw_bits_disable)) {
         /* Settings common to all PCI-express silicon */
-        uint32_t reg_ctrl, reg_ctrl_ext;
-        uint32_t reg_tarc0, reg_tarc1;
-        uint32_t reg_tctl;
-        uint32_t reg_txdctl, reg_txdctl1;
+        u32 reg_ctrl, reg_ctrl_ext;
+        u32 reg_tarc0, reg_tarc1;
+        u32 reg_tctl;
+        u32 reg_txdctl, reg_txdctl1;
 
         /* link autonegotiation/sync workarounds */
         reg_tarc0 = E1000_READ_REG(hw, TARC0);
@@ -869,12 +869,12 @@ e1000_initialize_hardware_bits(struct e1000_hw *hw)
 int32_t
 e1000_init_hw(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
-    uint32_t i;
+    u32 ctrl;
+    u32 i;
     int32_t ret_val;
-    uint32_t mta_size;
-    uint32_t reg_data;
-    uint32_t ctrl_ext;
+    u32 mta_size;
+    u32 reg_data;
+    u32 ctrl_ext;
 
     DEBUGFUNC("e1000_init_hw");
 
@@ -1020,7 +1020,7 @@ e1000_init_hw(struct e1000_hw *hw)
 
 
     if (hw->mac_type == e1000_82573) {
-        uint32_t gcr = E1000_READ_REG(hw, GCR);
+        u32 gcr = E1000_READ_REG(hw, GCR);
         gcr |= E1000_GCR_L1_ACT_WITHOUT_L0S_RX;
         E1000_WRITE_REG(hw, GCR, gcr);
     }
@@ -1103,7 +1103,7 @@ e1000_adjust_serdes_amplitude(struct e1000_hw *hw)
 int32_t
 e1000_setup_link(struct e1000_hw *hw)
 {
-    uint32_t ctrl_ext;
+    u32 ctrl_ext;
     int32_t ret_val;
     u16 eeprom_data;
 
@@ -1236,11 +1236,11 @@ e1000_setup_link(struct e1000_hw *hw)
 static int32_t
 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
-    uint32_t status;
-    uint32_t txcw = 0;
-    uint32_t i;
-    uint32_t signal = 0;
+    u32 ctrl;
+    u32 status;
+    u32 txcw = 0;
+    u32 i;
+    u32 signal = 0;
     int32_t ret_val;
 
     DEBUGFUNC("e1000_setup_fiber_serdes_link");
@@ -1383,7 +1383,7 @@ e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 static int32_t
 e1000_copper_link_preconfig(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
+    u32 ctrl;
     int32_t ret_val;
     u16 phy_data;
 
@@ -1443,7 +1443,7 @@ e1000_copper_link_preconfig(struct e1000_hw *hw)
 static int32_t
 e1000_copper_link_igp_setup(struct e1000_hw *hw)
 {
-    uint32_t led_ctrl;
+    u32 led_ctrl;
     int32_t ret_val;
     u16 phy_data;
 
@@ -1592,7 +1592,7 @@ e1000_copper_link_ggp_setup(struct e1000_hw *hw)
 {
     int32_t ret_val;
     u16 phy_data;
-    uint32_t reg_data;
+    u32 reg_data;
 
     DEBUGFUNC("e1000_copper_link_ggp_setup");
 
@@ -2066,7 +2066,7 @@ static int32_t
 e1000_configure_kmrn_for_10_100(struct e1000_hw *hw, u16 duplex)
 {
     int32_t ret_val = E1000_SUCCESS;
-    uint32_t tipg;
+    u32 tipg;
     u16 reg_data;
 
     DEBUGFUNC("e1000_configure_kmrn_for_10_100");
@@ -2103,7 +2103,7 @@ e1000_configure_kmrn_for_1000(struct e1000_hw *hw)
 {
     int32_t ret_val = E1000_SUCCESS;
     u16 reg_data;
-    uint32_t tipg;
+    u32 tipg;
 
     DEBUGFUNC("e1000_configure_kmrn_for_1000");
 
@@ -2287,7 +2287,7 @@ e1000_phy_setup_autoneg(struct e1000_hw *hw)
 static int32_t
 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
+    u32 ctrl;
     int32_t ret_val;
     u16 mii_ctrl_reg;
     u16 mii_status_reg;
@@ -2538,7 +2538,7 @@ e1000_phy_force_speed_duplex(struct e1000_hw *hw)
 void
 e1000_config_collision_dist(struct e1000_hw *hw)
 {
-    uint32_t tctl, coll_dist;
+    u32 tctl, coll_dist;
 
     DEBUGFUNC("e1000_config_collision_dist");
 
@@ -2568,7 +2568,7 @@ e1000_config_collision_dist(struct e1000_hw *hw)
 static int32_t
 e1000_config_mac_to_phy(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
+    u32 ctrl;
     int32_t ret_val;
     u16 phy_data;
 
@@ -2627,7 +2627,7 @@ e1000_config_mac_to_phy(struct e1000_hw *hw)
 int32_t
 e1000_force_mac_fc(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
+    u32 ctrl;
 
     DEBUGFUNC("e1000_force_mac_fc");
 
@@ -2899,12 +2899,12 @@ e1000_config_fc_after_link_up(struct e1000_hw *hw)
 int32_t
 e1000_check_for_link(struct e1000_hw *hw)
 {
-    uint32_t rxcw = 0;
-    uint32_t ctrl;
-    uint32_t status;
-    uint32_t rctl;
-    uint32_t icr;
-    uint32_t signal = 0;
+    u32 rxcw = 0;
+    u32 ctrl;
+    u32 status;
+    u32 rctl;
+    u32 icr;
+    u32 signal = 0;
     int32_t ret_val;
     u16 phy_data;
 
@@ -3137,7 +3137,7 @@ e1000_get_speed_and_duplex(struct e1000_hw *hw,
                            u16 *speed,
                            u16 *duplex)
 {
-    uint32_t status;
+    u32 status;
     int32_t ret_val;
     u16 phy_data;
 
@@ -3251,7 +3251,7 @@ e1000_wait_autoneg(struct e1000_hw *hw)
 ******************************************************************************/
 static void
 e1000_raise_mdi_clk(struct e1000_hw *hw,
-                    uint32_t *ctrl)
+                    u32 *ctrl)
 {
     /* Raise the clock input to the Management Data Clock (by setting the MDC
      * bit), and then delay 10 microseconds.
@@ -3269,7 +3269,7 @@ e1000_raise_mdi_clk(struct e1000_hw *hw,
 ******************************************************************************/
 static void
 e1000_lower_mdi_clk(struct e1000_hw *hw,
-                    uint32_t *ctrl)
+                    u32 *ctrl)
 {
     /* Lower the clock input to the Management Data Clock (by clearing the MDC
      * bit), and then delay 10 microseconds.
@@ -3290,11 +3290,11 @@ e1000_lower_mdi_clk(struct e1000_hw *hw,
 ******************************************************************************/
 static void
 e1000_shift_out_mdi_bits(struct e1000_hw *hw,
-                         uint32_t data,
+                         u32 data,
                          u16 count)
 {
-    uint32_t ctrl;
-    uint32_t mask;
+    u32 ctrl;
+    u32 mask;
 
     /* We need to shift "count" number of bits out to the PHY. So, the value
      * in the "data" parameter will be shifted out to the PHY one bit at a
@@ -3341,7 +3341,7 @@ e1000_shift_out_mdi_bits(struct e1000_hw *hw,
 static u16
 e1000_shift_in_mdi_bits(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
+    u32 ctrl;
     u16 data = 0;
     u8 i;
 
@@ -3387,9 +3387,9 @@ e1000_shift_in_mdi_bits(struct e1000_hw *hw)
 static int32_t
 e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask)
 {
-    uint32_t swfw_sync = 0;
-    uint32_t swmask = mask;
-    uint32_t fwmask = mask << 16;
+    u32 swfw_sync = 0;
+    u32 swmask = mask;
+    u32 fwmask = mask << 16;
     int32_t timeout = 200;
 
     DEBUGFUNC("e1000_swfw_sync_acquire");
@@ -3431,8 +3431,8 @@ e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask)
 static void
 e1000_swfw_sync_release(struct e1000_hw *hw, u16 mask)
 {
-    uint32_t swfw_sync;
-    uint32_t swmask = mask;
+    u32 swfw_sync;
+    u32 swmask = mask;
 
     DEBUGFUNC("e1000_swfw_sync_release");
 
@@ -3466,10 +3466,10 @@ e1000_swfw_sync_release(struct e1000_hw *hw, u16 mask)
 ******************************************************************************/
 int32_t
 e1000_read_phy_reg(struct e1000_hw *hw,
-                   uint32_t reg_addr,
+                   u32 reg_addr,
                    u16 *phy_data)
 {
-    uint32_t ret_val;
+    u32 ret_val;
     u16 swfw;
 
     DEBUGFUNC("e1000_read_phy_reg");
@@ -3524,12 +3524,12 @@ e1000_read_phy_reg(struct e1000_hw *hw,
 }
 
 static int32_t
-e1000_read_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
+e1000_read_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
                       u16 *phy_data)
 {
-    uint32_t i;
-    uint32_t mdic = 0;
-    const uint32_t phy_addr = 1;
+    u32 i;
+    u32 mdic = 0;
+    const u32 phy_addr = 1;
 
     DEBUGFUNC("e1000_read_phy_reg_ex");
 
@@ -3604,10 +3604,10 @@ e1000_read_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
 * data - data to write to the PHY
 ******************************************************************************/
 int32_t
-e1000_write_phy_reg(struct e1000_hw *hw, uint32_t reg_addr,
+e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr,
                     u16 phy_data)
 {
-    uint32_t ret_val;
+    u32 ret_val;
     u16 swfw;
 
     DEBUGFUNC("e1000_write_phy_reg");
@@ -3662,12 +3662,12 @@ e1000_write_phy_reg(struct e1000_hw *hw, uint32_t reg_addr,
 }
 
 static int32_t
-e1000_write_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
+e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
                        u16 phy_data)
 {
-    uint32_t i;
-    uint32_t mdic = 0;
-    const uint32_t phy_addr = 1;
+    u32 i;
+    u32 mdic = 0;
+    const u32 phy_addr = 1;
 
     DEBUGFUNC("e1000_write_phy_reg_ex");
 
@@ -3681,7 +3681,7 @@ e1000_write_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
          * for the PHY register in the MDI Control register.  The MAC will take
          * care of interfacing with the PHY to send the desired data.
          */
-        mdic = (((uint32_t) phy_data) |
+        mdic = (((u32) phy_data) |
                 (reg_addr << E1000_MDIC_REG_SHIFT) |
                 (phy_addr << E1000_MDIC_PHY_SHIFT) |
                 (E1000_MDIC_OP_WRITE));
@@ -3715,7 +3715,7 @@ e1000_write_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
         mdic = ((PHY_TURNAROUND) | (reg_addr << 2) | (phy_addr << 7) |
                 (PHY_OP_WRITE << 12) | (PHY_SOF << 14));
         mdic <<= 16;
-        mdic |= (uint32_t) phy_data;
+        mdic |= (u32) phy_data;
 
         e1000_shift_out_mdi_bits(hw, mdic, 32);
     }
@@ -3725,10 +3725,10 @@ e1000_write_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
 
 static int32_t
 e1000_read_kmrn_reg(struct e1000_hw *hw,
-                    uint32_t reg_addr,
+                    u32 reg_addr,
                     u16 *data)
 {
-    uint32_t reg_val;
+    u32 reg_val;
     u16 swfw;
     DEBUGFUNC("e1000_read_kmrn_reg");
 
@@ -3758,10 +3758,10 @@ e1000_read_kmrn_reg(struct e1000_hw *hw,
 
 static int32_t
 e1000_write_kmrn_reg(struct e1000_hw *hw,
-                     uint32_t reg_addr,
+                     u32 reg_addr,
                      u16 data)
 {
-    uint32_t reg_val;
+    u32 reg_val;
     u16 swfw;
     DEBUGFUNC("e1000_write_kmrn_reg");
 
@@ -3791,8 +3791,8 @@ e1000_write_kmrn_reg(struct e1000_hw *hw,
 int32_t
 e1000_phy_hw_reset(struct e1000_hw *hw)
 {
-    uint32_t ctrl, ctrl_ext;
-    uint32_t led_ctrl;
+    u32 ctrl, ctrl_ext;
+    u32 led_ctrl;
     int32_t ret_val;
     u16 swfw;
 
@@ -4076,14 +4076,14 @@ e1000_detect_gig_phy(struct e1000_hw *hw)
     if (ret_val)
         return ret_val;
 
-    hw->phy_id = (uint32_t) (phy_id_high << 16);
+    hw->phy_id = (u32) (phy_id_high << 16);
     udelay(20);
     ret_val = e1000_read_phy_reg(hw, PHY_ID2, &phy_id_low);
     if (ret_val)
         return ret_val;
 
-    hw->phy_id |= (uint32_t) (phy_id_low & PHY_REVISION_MASK);
-    hw->phy_revision = (uint32_t) phy_id_low & ~PHY_REVISION_MASK;
+    hw->phy_id |= (u32) (phy_id_low & PHY_REVISION_MASK);
+    hw->phy_revision = (u32) phy_id_low & ~PHY_REVISION_MASK;
 
     switch (hw->mac_type) {
     case e1000_82543:
@@ -4440,7 +4440,7 @@ int32_t
 e1000_init_eeprom_params(struct e1000_hw *hw)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
-    uint32_t eecd = E1000_READ_REG(hw, EECD);
+    u32 eecd = E1000_READ_REG(hw, EECD);
     int32_t ret_val = E1000_SUCCESS;
     u16 eeprom_size;
 
@@ -4562,7 +4562,7 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
     case e1000_ich8lan:
         {
         int32_t  i = 0;
-        uint32_t flash_size = E1000_READ_ICH_FLASH_REG(hw, ICH_FLASH_GFPREG);
+        u32 flash_size = E1000_READ_ICH_FLASH_REG(hw, ICH_FLASH_GFPREG);
 
         eeprom->type = e1000_eeprom_ich8;
         eeprom->use_eerd = false;
@@ -4628,7 +4628,7 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
  *****************************************************************************/
 static void
 e1000_raise_ee_clk(struct e1000_hw *hw,
-                   uint32_t *eecd)
+                   u32 *eecd)
 {
     /* Raise the clock input to the EEPROM (by setting the SK bit), and then
      * wait <delay> microseconds.
@@ -4647,7 +4647,7 @@ e1000_raise_ee_clk(struct e1000_hw *hw,
  *****************************************************************************/
 static void
 e1000_lower_ee_clk(struct e1000_hw *hw,
-                   uint32_t *eecd)
+                   u32 *eecd)
 {
     /* Lower the clock input to the EEPROM (by clearing the SK bit), and then
      * wait 50 microseconds.
@@ -4671,8 +4671,8 @@ e1000_shift_out_ee_bits(struct e1000_hw *hw,
                         u16 count)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
-    uint32_t eecd;
-    uint32_t mask;
+    u32 eecd;
+    u32 mask;
 
     /* We need to shift "count" bits out to the EEPROM. So, value in the
      * "data" parameter will be shifted out to the EEPROM one bit at a time.
@@ -4722,8 +4722,8 @@ static u16
 e1000_shift_in_ee_bits(struct e1000_hw *hw,
                        u16 count)
 {
-    uint32_t eecd;
-    uint32_t i;
+    u32 eecd;
+    u32 i;
     u16 data;
 
     /* In order to read a register from the EEPROM, we need to shift 'count'
@@ -4766,7 +4766,7 @@ static int32_t
 e1000_acquire_eeprom(struct e1000_hw *hw)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
-    uint32_t eecd, i=0;
+    u32 eecd, i=0;
 
     DEBUGFUNC("e1000_acquire_eeprom");
 
@@ -4825,7 +4825,7 @@ static void
 e1000_standby_eeprom(struct e1000_hw *hw)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
-    uint32_t eecd;
+    u32 eecd;
 
     eecd = E1000_READ_REG(hw, EECD);
 
@@ -4873,7 +4873,7 @@ e1000_standby_eeprom(struct e1000_hw *hw)
 static void
 e1000_release_eeprom(struct e1000_hw *hw)
 {
-    uint32_t eecd;
+    u32 eecd;
 
     DEBUGFUNC("e1000_release_eeprom");
 
@@ -4974,7 +4974,7 @@ e1000_read_eeprom(struct e1000_hw *hw,
                   u16 *data)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
-    uint32_t i = 0;
+    u32 i = 0;
 
     DEBUGFUNC("e1000_read_eeprom");
 
@@ -5074,7 +5074,7 @@ e1000_read_eeprom_eerd(struct e1000_hw *hw,
                   u16 words,
                   u16 *data)
 {
-    uint32_t i, eerd = 0;
+    u32 i, eerd = 0;
     int32_t error = 0;
 
     for (i = 0; i < words; i++) {
@@ -5108,8 +5108,8 @@ e1000_write_eeprom_eewr(struct e1000_hw *hw,
                    u16 words,
                    u16 *data)
 {
-    uint32_t    register_value = 0;
-    uint32_t    i              = 0;
+    u32    register_value = 0;
+    u32    i              = 0;
     int32_t     error          = 0;
 
     if (e1000_swfw_sync_acquire(hw, E1000_SWFW_EEP_SM))
@@ -5146,8 +5146,8 @@ e1000_write_eeprom_eewr(struct e1000_hw *hw,
 static int32_t
 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd)
 {
-    uint32_t attempts = 100000;
-    uint32_t i, reg = 0;
+    u32 attempts = 100000;
+    u32 i, reg = 0;
     int32_t done = E1000_ERR_EEPROM;
 
     for (i = 0; i < attempts; i++) {
@@ -5174,7 +5174,7 @@ e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd)
 static bool
 e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw)
 {
-    uint32_t eecd = 0;
+    u32 eecd = 0;
 
     DEBUGFUNC("e1000_is_onboard_nvm_eeprom");
 
@@ -5271,7 +5271,7 @@ e1000_validate_eeprom_checksum(struct e1000_hw *hw)
 int32_t
 e1000_update_eeprom_checksum(struct e1000_hw *hw)
 {
-    uint32_t ctrl_ext;
+    u32 ctrl_ext;
     u16 checksum = 0;
     u16 i, eeprom_data;
 
@@ -5443,7 +5443,7 @@ e1000_write_eeprom_microwire(struct e1000_hw *hw,
                              u16 *data)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
-    uint32_t eecd;
+    u32 eecd;
     u16 words_written = 0;
     u16 i = 0;
 
@@ -5526,13 +5526,13 @@ e1000_write_eeprom_microwire(struct e1000_hw *hw,
 static int32_t
 e1000_commit_shadow_ram(struct e1000_hw *hw)
 {
-    uint32_t attempts = 100000;
-    uint32_t eecd = 0;
-    uint32_t flop = 0;
-    uint32_t i = 0;
+    u32 attempts = 100000;
+    u32 eecd = 0;
+    u32 flop = 0;
+    u32 i = 0;
     int32_t error = E1000_SUCCESS;
-    uint32_t old_bank_offset = 0;
-    uint32_t new_bank_offset = 0;
+    u32 old_bank_offset = 0;
+    u32 new_bank_offset = 0;
     u8 low_byte = 0;
     u8 high_byte = 0;
     bool sector_write_failed = false;
@@ -5734,8 +5734,8 @@ e1000_read_mac_addr(struct e1000_hw * hw)
 static void
 e1000_init_rx_addrs(struct e1000_hw *hw)
 {
-    uint32_t i;
-    uint32_t rar_num;
+    u32 i;
+    u32 rar_num;
 
     DEBUGFUNC("e1000_init_rx_addrs");
 
@@ -5770,11 +5770,11 @@ e1000_init_rx_addrs(struct e1000_hw *hw)
  * hw - Struct containing variables accessed by shared code
  * mc_addr - the multicast address to hash
  *****************************************************************************/
-uint32_t
+u32
 e1000_hash_mc_addr(struct e1000_hw *hw,
                    u8 *mc_addr)
 {
-    uint32_t hash_value = 0;
+    u32 hash_value = 0;
 
     /* The portion of the address that is used for the hash table is
      * determined by the mc_filter_type setting.
@@ -5837,11 +5837,11 @@ e1000_hash_mc_addr(struct e1000_hw *hw,
  *****************************************************************************/
 void
 e1000_mta_set(struct e1000_hw *hw,
-              uint32_t hash_value)
+              u32 hash_value)
 {
-    uint32_t hash_bit, hash_reg;
-    uint32_t mta;
-    uint32_t temp;
+    u32 hash_bit, hash_reg;
+    u32 mta;
+    u32 temp;
 
     /* The MTA is a register array of 128 32-bit registers.
      * It is treated like an array of 4096 bits.  We want to set
@@ -5887,17 +5887,17 @@ e1000_mta_set(struct e1000_hw *hw,
 void
 e1000_rar_set(struct e1000_hw *hw,
               u8 *addr,
-              uint32_t index)
+              u32 index)
 {
-    uint32_t rar_low, rar_high;
+    u32 rar_low, rar_high;
 
     /* HW expects these in little endian so we reverse the byte order
      * from network order (big endian) to little endian
      */
-    rar_low = ((uint32_t) addr[0] |
-               ((uint32_t) addr[1] << 8) |
-               ((uint32_t) addr[2] << 16) | ((uint32_t) addr[3] << 24));
-    rar_high = ((uint32_t) addr[4] | ((uint32_t) addr[5] << 8));
+    rar_low = ((u32) addr[0] |
+               ((u32) addr[1] << 8) |
+               ((u32) addr[2] << 16) | ((u32) addr[3] << 24));
+    rar_high = ((u32) addr[4] | ((u32) addr[5] << 8));
 
     /* Disable Rx and flush all Rx frames before enabling RSS to avoid Rx
      * unit hang.
@@ -5944,10 +5944,10 @@ e1000_rar_set(struct e1000_hw *hw,
  *****************************************************************************/
 void
 e1000_write_vfta(struct e1000_hw *hw,
-                 uint32_t offset,
-                 uint32_t value)
+                 u32 offset,
+                 u32 value)
 {
-    uint32_t temp;
+    u32 temp;
 
     if (hw->mac_type == e1000_ich8lan)
         return;
@@ -5972,10 +5972,10 @@ e1000_write_vfta(struct e1000_hw *hw,
 static void
 e1000_clear_vfta(struct e1000_hw *hw)
 {
-    uint32_t offset;
-    uint32_t vfta_value = 0;
-    uint32_t vfta_offset = 0;
-    uint32_t vfta_bit_in_reg = 0;
+    u32 offset;
+    u32 vfta_value = 0;
+    u32 vfta_offset = 0;
+    u32 vfta_bit_in_reg = 0;
 
     if (hw->mac_type == e1000_ich8lan)
         return;
@@ -6006,10 +6006,10 @@ e1000_clear_vfta(struct e1000_hw *hw)
 static int32_t
 e1000_id_led_init(struct e1000_hw * hw)
 {
-    uint32_t ledctl;
-    const uint32_t ledctl_mask = 0x000000FF;
-    const uint32_t ledctl_on = E1000_LEDCTL_MODE_LED_ON;
-    const uint32_t ledctl_off = E1000_LEDCTL_MODE_LED_OFF;
+    u32 ledctl;
+    const u32 ledctl_mask = 0x000000FF;
+    const u32 ledctl_on = E1000_LEDCTL_MODE_LED_ON;
+    const u32 ledctl_off = E1000_LEDCTL_MODE_LED_OFF;
     u16 eeprom_data, i, temp;
     const u16 led_mask = 0x0F;
 
@@ -6089,7 +6089,7 @@ e1000_id_led_init(struct e1000_hw * hw)
 int32_t
 e1000_setup_led(struct e1000_hw *hw)
 {
-    uint32_t ledctl;
+    u32 ledctl;
     int32_t ret_val = E1000_SUCCESS;
 
     DEBUGFUNC("e1000_setup_led");
@@ -6149,7 +6149,7 @@ int32_t
 e1000_blink_led_start(struct e1000_hw *hw)
 {
     int16_t  i;
-    uint32_t ledctl_blink = 0;
+    u32 ledctl_blink = 0;
 
     DEBUGFUNC("e1000_id_led_blink_on");
 
@@ -6225,7 +6225,7 @@ e1000_cleanup_led(struct e1000_hw *hw)
 int32_t
 e1000_led_on(struct e1000_hw *hw)
 {
-    uint32_t ctrl = E1000_READ_REG(hw, CTRL);
+    u32 ctrl = E1000_READ_REG(hw, CTRL);
 
     DEBUGFUNC("e1000_led_on");
 
@@ -6276,7 +6276,7 @@ e1000_led_on(struct e1000_hw *hw)
 int32_t
 e1000_led_off(struct e1000_hw *hw)
 {
-    uint32_t ctrl = E1000_READ_REG(hw, CTRL);
+    u32 ctrl = E1000_READ_REG(hw, CTRL);
 
     DEBUGFUNC("e1000_led_off");
 
@@ -6327,7 +6327,7 @@ e1000_led_off(struct e1000_hw *hw)
 static void
 e1000_clear_hw_cntrs(struct e1000_hw *hw)
 {
-    volatile uint32_t temp;
+    volatile u32 temp;
 
     temp = E1000_READ_REG(hw, CRCERRS);
     temp = E1000_READ_REG(hw, SYMERRS);
@@ -6495,7 +6495,7 @@ e1000_update_adaptive(struct e1000_hw *hw)
 void
 e1000_tbi_adjust_stats(struct e1000_hw *hw,
                        struct e1000_hw_stats *stats,
-                       uint32_t frame_len,
+                       u32 frame_len,
                        u8 *mac_addr)
 {
     uint64_t carry_bit;
@@ -6575,7 +6575,7 @@ e1000_get_bus_info(struct e1000_hw *hw)
 {
     int32_t ret_val;
     u16 pci_ex_link_status;
-    uint32_t status;
+    u32 status;
 
     switch (hw->mac_type) {
     case e1000_82542_rev2_0:
@@ -6647,8 +6647,8 @@ e1000_get_bus_info(struct e1000_hw *hw)
  *****************************************************************************/
 static void
 e1000_write_reg_io(struct e1000_hw *hw,
-                   uint32_t offset,
-                   uint32_t value)
+                   u32 offset,
+                   u32 value)
 {
     unsigned long io_addr = hw->io_base;
     unsigned long io_data = hw->io_base + 4;
@@ -7039,7 +7039,7 @@ e1000_config_dsp_after_link_change(struct e1000_hw *hw,
                (min_length < e1000_igp_cable_length_50)) {
 
                 u16 ffe_idle_err_timeout = FFE_IDLE_ERR_COUNT_TIMEOUT_20;
-                uint32_t idle_errs = 0;
+                u32 idle_errs = 0;
 
                 /* clear previous idle error counts */
                 ret_val = e1000_read_phy_reg(hw, PHY_1000T_STATUS,
@@ -7222,7 +7222,7 @@ static int32_t
 e1000_set_d3_lplu_state(struct e1000_hw *hw,
                         bool active)
 {
-    uint32_t phy_ctrl = 0;
+    u32 phy_ctrl = 0;
     int32_t ret_val;
     u16 phy_data;
     DEBUGFUNC("e1000_set_d3_lplu_state");
@@ -7352,7 +7352,7 @@ static int32_t
 e1000_set_d0_lplu_state(struct e1000_hw *hw,
                         bool active)
 {
-    uint32_t phy_ctrl = 0;
+    u32 phy_ctrl = 0;
     int32_t ret_val;
     u16 phy_data;
     DEBUGFUNC("e1000_set_d0_lplu_state");
@@ -7507,14 +7507,14 @@ static int32_t
 e1000_host_if_read_cookie(struct e1000_hw * hw, u8 *buffer)
 {
     u8 i;
-    uint32_t offset = E1000_MNG_DHCP_COOKIE_OFFSET;
+    u32 offset = E1000_MNG_DHCP_COOKIE_OFFSET;
     u8 length = E1000_MNG_DHCP_COOKIE_LENGTH;
 
     length = (length >> 2);
     offset = (offset >> 2);
 
     for (i = 0; i < length; i++) {
-        *((uint32_t *) buffer + i) =
+        *((u32 *) buffer + i) =
             E1000_READ_REG_ARRAY_DWORD(hw, HOST_IF, offset + i);
     }
     return E1000_SUCCESS;
@@ -7533,7 +7533,7 @@ e1000_host_if_read_cookie(struct e1000_hw * hw, u8 *buffer)
 static int32_t
 e1000_mng_enable_host_if(struct e1000_hw * hw)
 {
-    uint32_t hicr;
+    u32 hicr;
     u8 i;
 
     /* Check that the host interface is enabled. */
@@ -7570,7 +7570,7 @@ e1000_mng_host_if_write(struct e1000_hw * hw, u8 *buffer,
 {
     u8 *tmp;
     u8 *bufptr = buffer;
-    uint32_t data = 0;
+    u32 data = 0;
     u16 remaining, i, j, prev_bytes;
 
     /* sum = only sum of the data and it is not checksum */
@@ -7586,7 +7586,7 @@ e1000_mng_host_if_write(struct e1000_hw * hw, u8 *buffer,
 
     if (prev_bytes) {
         data = E1000_READ_REG_ARRAY_DWORD(hw, HOST_IF, offset);
-        for (j = prev_bytes; j < sizeof(uint32_t); j++) {
+        for (j = prev_bytes; j < sizeof(u32); j++) {
             *(tmp + j) = *bufptr++;
             *sum += *(tmp + j);
         }
@@ -7604,7 +7604,7 @@ e1000_mng_host_if_write(struct e1000_hw * hw, u8 *buffer,
     /* The device driver writes the relevant command block into the
      * ram area. */
     for (i = 0; i < length; i++) {
-        for (j = 0; j < sizeof(uint32_t); j++) {
+        for (j = 0; j < sizeof(u32); j++) {
             *(tmp + j) = *bufptr++;
             *sum += *(tmp + j);
         }
@@ -7612,7 +7612,7 @@ e1000_mng_host_if_write(struct e1000_hw * hw, u8 *buffer,
         E1000_WRITE_REG_ARRAY_DWORD(hw, HOST_IF, offset + i, data);
     }
     if (remaining) {
-        for (j = 0; j < sizeof(uint32_t); j++) {
+        for (j = 0; j < sizeof(u32); j++) {
             if (j < remaining)
                 *(tmp + j) = *bufptr++;
             else
@@ -7658,7 +7658,7 @@ e1000_mng_write_cmd_header(struct e1000_hw * hw,
     length >>= 2;
     /* The device driver writes the relevant command block into the ram area. */
     for (i = 0; i < length; i++) {
-        E1000_WRITE_REG_ARRAY_DWORD(hw, HOST_IF, i, *((uint32_t *) hdr + i));
+        E1000_WRITE_REG_ARRAY_DWORD(hw, HOST_IF, i, *((u32 *) hdr + i));
         E1000_WRITE_FLUSH(hw);
     }
 
@@ -7675,7 +7675,7 @@ e1000_mng_write_cmd_header(struct e1000_hw * hw,
 static int32_t
 e1000_mng_write_commit(struct e1000_hw * hw)
 {
-    uint32_t hicr;
+    u32 hicr;
 
     hicr = E1000_READ_REG(hw, HICR);
     /* Setting this bit tells the ARC that a new command is pending. */
@@ -7693,7 +7693,7 @@ e1000_mng_write_commit(struct e1000_hw * hw)
 bool
 e1000_check_mng_mode(struct e1000_hw *hw)
 {
-    uint32_t fwsm;
+    u32 fwsm;
 
     fwsm = E1000_READ_REG(hw, FWSM);
 
@@ -7745,10 +7745,10 @@ e1000_mng_write_dhcp_info(struct e1000_hw * hw, u8 *buffer,
  * returns  - checksum of buffer contents.
  ****************************************************************************/
 static u8
-e1000_calculate_mng_checksum(char *buffer, uint32_t length)
+e1000_calculate_mng_checksum(char *buffer, u32 length)
 {
     u8 sum = 0;
-    uint32_t i;
+    u32 i;
 
     if (!buffer)
         return 0;
@@ -7806,11 +7806,11 @@ e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
  * returns: - true/false
  *
  *****************************************************************************/
-uint32_t
+u32
 e1000_enable_mng_pass_thru(struct e1000_hw *hw)
 {
-    uint32_t manc;
-    uint32_t fwsm, factps;
+    u32 manc;
+    u32 fwsm, factps;
 
     if (hw->asf_firmware_present) {
         manc = E1000_READ_REG(hw, MANC);
@@ -7929,7 +7929,7 @@ e1000_polarity_reversal_workaround(struct e1000_hw *hw)
 static void
 e1000_set_pci_express_master_disable(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
+    u32 ctrl;
 
     DEBUGFUNC("e1000_set_pci_express_master_disable");
 
@@ -8042,7 +8042,7 @@ static int32_t
 e1000_get_phy_cfg_done(struct e1000_hw *hw)
 {
     int32_t timeout = PHY_CFG_TIMEOUT;
-    uint32_t cfg_mask = E1000_EEPROM_CFG_DONE;
+    u32 cfg_mask = E1000_EEPROM_CFG_DONE;
 
     DEBUGFUNC("e1000_get_phy_cfg_done");
 
@@ -8089,7 +8089,7 @@ static int32_t
 e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw)
 {
     int32_t timeout;
-    uint32_t swsm;
+    u32 swsm;
 
     DEBUGFUNC("e1000_get_hw_eeprom_semaphore");
 
@@ -8138,7 +8138,7 @@ e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw)
 static void
 e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw)
 {
-    uint32_t swsm;
+    u32 swsm;
 
     DEBUGFUNC("e1000_put_hw_eeprom_semaphore");
 
@@ -8168,7 +8168,7 @@ static int32_t
 e1000_get_software_semaphore(struct e1000_hw *hw)
 {
     int32_t timeout = hw->eeprom.word_size + 1;
-    uint32_t swsm;
+    u32 swsm;
 
     DEBUGFUNC("e1000_get_software_semaphore");
 
@@ -8203,7 +8203,7 @@ e1000_get_software_semaphore(struct e1000_hw *hw)
 static void
 e1000_release_software_semaphore(struct e1000_hw *hw)
 {
-    uint32_t swsm;
+    u32 swsm;
 
     DEBUGFUNC("e1000_release_software_semaphore");
 
@@ -8231,8 +8231,8 @@ e1000_release_software_semaphore(struct e1000_hw *hw)
 int32_t
 e1000_check_phy_reset_block(struct e1000_hw *hw)
 {
-    uint32_t manc = 0;
-    uint32_t fwsm = 0;
+    u32 manc = 0;
+    u32 fwsm = 0;
 
     if (hw->mac_type == e1000_ich8lan) {
         fwsm = E1000_READ_REG(hw, FWSM);
@@ -8249,7 +8249,7 @@ e1000_check_phy_reset_block(struct e1000_hw *hw)
 static u8
 e1000_arc_subsystem_valid(struct e1000_hw *hw)
 {
-    uint32_t fwsm;
+    u32 fwsm;
 
     /* On 8257x silicon, registers in the range of 0x8800 - 0x8FFC
      * may not be provided a DMA clock when no manageability features are
@@ -8284,9 +8284,9 @@ e1000_arc_subsystem_valid(struct e1000_hw *hw)
  *
  *****************************************************************************/
 static int32_t
-e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, uint32_t no_snoop)
+e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, u32 no_snoop)
 {
-    uint32_t gcr_reg = 0;
+    u32 gcr_reg = 0;
 
     DEBUGFUNC("e1000_set_pci_ex_no_snoop");
 
@@ -8303,7 +8303,7 @@ e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, uint32_t no_snoop)
         E1000_WRITE_REG(hw, GCR, gcr_reg);
     }
     if (hw->mac_type == e1000_ich8lan) {
-        uint32_t ctrl_ext;
+        u32 ctrl_ext;
 
         E1000_WRITE_REG(hw, GCR, PCI_EX_82566_SNOOP_ALL);
 
@@ -8328,7 +8328,7 @@ static int32_t
 e1000_get_software_flag(struct e1000_hw *hw)
 {
     int32_t timeout = PHY_CFG_TIMEOUT;
-    uint32_t extcnf_ctrl;
+    u32 extcnf_ctrl;
 
     DEBUGFUNC("e1000_get_software_flag");
 
@@ -8366,7 +8366,7 @@ e1000_get_software_flag(struct e1000_hw *hw)
 static void
 e1000_release_software_flag(struct e1000_hw *hw)
 {
-    uint32_t extcnf_ctrl;
+    u32 extcnf_ctrl;
 
     DEBUGFUNC("e1000_release_software_flag");
 
@@ -8393,9 +8393,9 @@ e1000_read_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
                        u16 *data)
 {
     int32_t  error = E1000_SUCCESS;
-    uint32_t flash_bank = 0;
-    uint32_t act_offset = 0;
-    uint32_t bank_offset = 0;
+    u32 flash_bank = 0;
+    u32 act_offset = 0;
+    u32 bank_offset = 0;
     u16 word = 0;
     u16 i = 0;
 
@@ -8448,7 +8448,7 @@ static int32_t
 e1000_write_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
                         u16 *data)
 {
-    uint32_t i = 0;
+    u32 i = 0;
     int32_t error = E1000_SUCCESS;
 
     error = e1000_get_software_flag(hw);
@@ -8559,12 +8559,12 @@ e1000_ich8_cycle_init(struct e1000_hw *hw)
  * hw - The pointer to the hw structure
  ****************************************************************************/
 static int32_t
-e1000_ich8_flash_cycle(struct e1000_hw *hw, uint32_t timeout)
+e1000_ich8_flash_cycle(struct e1000_hw *hw, u32 timeout)
 {
     union ich8_hws_flash_ctrl hsflctl;
     union ich8_hws_flash_status hsfsts;
     int32_t error = E1000_ERR_EEPROM;
-    uint32_t i = 0;
+    u32 i = 0;
 
     /* Start a cycle by writing 1 in Flash Cycle Go in Hw Flash Control */
     hsflctl.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFCTL);
@@ -8594,13 +8594,13 @@ e1000_ich8_flash_cycle(struct e1000_hw *hw, uint32_t timeout)
  * data - Pointer to the word to store the value read.
  *****************************************************************************/
 static int32_t
-e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index,
-                     uint32_t size, u16* data)
+e1000_read_ich8_data(struct e1000_hw *hw, u32 index,
+                     u32 size, u16* data)
 {
     union ich8_hws_flash_status hsfsts;
     union ich8_hws_flash_ctrl hsflctl;
-    uint32_t flash_linear_address;
-    uint32_t flash_data = 0;
+    u32 flash_linear_address;
+    u32 flash_data = 0;
     int32_t error = -E1000_ERR_EEPROM;
     int32_t count = 0;
 
@@ -8673,13 +8673,13 @@ e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index,
  * data - The byte(s) to write to the NVM.
  *****************************************************************************/
 static int32_t
-e1000_write_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size,
+e1000_write_ich8_data(struct e1000_hw *hw, u32 index, u32 size,
                       u16 data)
 {
     union ich8_hws_flash_status hsfsts;
     union ich8_hws_flash_ctrl hsflctl;
-    uint32_t flash_linear_address;
-    uint32_t flash_data = 0;
+    u32 flash_linear_address;
+    u32 flash_data = 0;
     int32_t error = -E1000_ERR_EEPROM;
     int32_t count = 0;
 
@@ -8710,9 +8710,9 @@ e1000_write_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size,
         E1000_WRITE_ICH_FLASH_REG(hw, ICH_FLASH_FADDR, flash_linear_address);
 
         if (size == 1)
-            flash_data = (uint32_t)data & 0x00FF;
+            flash_data = (u32)data & 0x00FF;
         else
-            flash_data = (uint32_t)data;
+            flash_data = (u32)data;
 
         E1000_WRITE_ICH_FLASH_REG(hw, ICH_FLASH_FDATA0, flash_data);
 
@@ -8748,7 +8748,7 @@ e1000_write_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size,
  * data - Pointer to a byte to store the value read.
  *****************************************************************************/
 static int32_t
-e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index, u8* data)
+e1000_read_ich8_byte(struct e1000_hw *hw, u32 index, u8* data)
 {
     int32_t status = E1000_SUCCESS;
     u16 word = 0;
@@ -8771,7 +8771,7 @@ e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index, u8* data)
  * byte - The byte to write to the NVM.
  *****************************************************************************/
 static int32_t
-e1000_verify_write_ich8_byte(struct e1000_hw *hw, uint32_t index, u8 byte)
+e1000_verify_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte)
 {
     int32_t error = E1000_SUCCESS;
     int32_t program_retries = 0;
@@ -8804,7 +8804,7 @@ e1000_verify_write_ich8_byte(struct e1000_hw *hw, uint32_t index, u8 byte)
  * data - The byte to write to the NVM.
  *****************************************************************************/
 static int32_t
-e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index, u8 data)
+e1000_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 data)
 {
     int32_t status = E1000_SUCCESS;
     u16 word = (u16)data;
@@ -8822,7 +8822,7 @@ e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index, u8 data)
  * data - Pointer to a word to store the value read.
  *****************************************************************************/
 static int32_t
-e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index, u16 *data)
+e1000_read_ich8_word(struct e1000_hw *hw, u32 index, u16 *data)
 {
     int32_t status = E1000_SUCCESS;
     status = e1000_read_ich8_data(hw, index, 2, data);
@@ -8841,11 +8841,11 @@ e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index, u16 *data)
  * bank size may be 4, 8 or 64 KBytes
  *****************************************************************************/
 static int32_t
-e1000_erase_ich8_4k_segment(struct e1000_hw *hw, uint32_t bank)
+e1000_erase_ich8_4k_segment(struct e1000_hw *hw, u32 bank)
 {
     union ich8_hws_flash_status hsfsts;
     union ich8_hws_flash_ctrl hsflctl;
-    uint32_t flash_linear_address;
+    u32 flash_linear_address;
     int32_t  count = 0;
     int32_t  error = E1000_ERR_EEPROM;
     int32_t  iteration;
@@ -8932,9 +8932,9 @@ e1000_erase_ich8_4k_segment(struct e1000_hw *hw, uint32_t bank)
 
 static int32_t
 e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw,
-                                      uint32_t cnf_base_addr, uint32_t cnf_size)
+                                      u32 cnf_base_addr, u32 cnf_size)
 {
-    uint32_t ret_val = E1000_SUCCESS;
+    u32 ret_val = E1000_SUCCESS;
     u16 word_addr, reg_data, reg_addr;
     u16 i;
 
@@ -8955,7 +8955,7 @@ e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw,
         if (ret_val != E1000_SUCCESS)
             return ret_val;
 
-        ret_val = e1000_write_phy_reg_ex(hw, (uint32_t)reg_addr, reg_data);
+        ret_val = e1000_write_phy_reg_ex(hw, (u32)reg_addr, reg_data);
 
         e1000_release_software_flag(hw);
     }
@@ -8975,7 +8975,7 @@ e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw,
 static int32_t
 e1000_init_lcd_from_nvm(struct e1000_hw *hw)
 {
-    uint32_t reg_data, cnf_base_addr, cnf_size, ret_val, loop;
+    u32 reg_data, cnf_base_addr, cnf_size, ret_val, loop;
 
     if (hw->phy_type != e1000_phy_igp_3)
           return E1000_SUCCESS;
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 98d14d9..2cf3d99 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -263,8 +263,8 @@ struct e1000_phy_info {
 };
 
 struct e1000_phy_stats {
-    uint32_t idle_errors;
-    uint32_t receive_errors;
+    u32 idle_errors;
+    u32 receive_errors;
 };
 
 struct e1000_eeprom_info {
@@ -322,8 +322,8 @@ int32_t e1000_get_speed_and_duplex(struct e1000_hw *hw, u16 *speed, u16 *duplex)
 int32_t e1000_force_mac_fc(struct e1000_hw *hw);
 
 /* PHY */
-int32_t e1000_read_phy_reg(struct e1000_hw *hw, uint32_t reg_addr, u16 *phy_data);
-int32_t e1000_write_phy_reg(struct e1000_hw *hw, uint32_t reg_addr, u16 data);
+int32_t e1000_read_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 *phy_data);
+int32_t e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 data);
 int32_t e1000_phy_hw_reset(struct e1000_hw *hw);
 int32_t e1000_phy_reset(struct e1000_hw *hw);
 int32_t e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
@@ -335,7 +335,7 @@ void e1000_phy_powerdown_workaround(struct e1000_hw *hw);
 int32_t e1000_init_eeprom_params(struct e1000_hw *hw);
 
 /* MNG HOST IF functions */
-uint32_t e1000_enable_mng_pass_thru(struct e1000_hw *hw);
+u32 e1000_enable_mng_pass_thru(struct e1000_hw *hw);
 
 #define E1000_MNG_DHCP_TX_PAYLOAD_CMD   64
 #define E1000_HI_MAX_MNG_DATA_LENGTH    0x6F8   /* Host Interface data length */
@@ -367,22 +367,22 @@ struct e1000_host_mng_command_info {
 };
 #ifdef __BIG_ENDIAN
 struct e1000_host_mng_dhcp_cookie{
-    uint32_t signature;
+    u32 signature;
     u16 vlan_id;
     u8 reserved0;
     u8 status;
-    uint32_t reserved1;
+    u32 reserved1;
     u8 checksum;
     u8 reserved3;
     u16 reserved2;
 };
 #else
 struct e1000_host_mng_dhcp_cookie{
-    uint32_t signature;
+    u32 signature;
     u8 status;
     u8 reserved0;
     u16 vlan_id;
-    uint32_t reserved1;
+    u32 reserved1;
     u16 reserved2;
     u8 reserved3;
     u8 checksum;
@@ -400,10 +400,10 @@ int32_t e1000_write_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 *data);
 int32_t e1000_read_mac_addr(struct e1000_hw * hw);
 
 /* Filters (multicast, vlan, receive) */
-uint32_t e1000_hash_mc_addr(struct e1000_hw *hw, u8 * mc_addr);
-void e1000_mta_set(struct e1000_hw *hw, uint32_t hash_value);
-void e1000_rar_set(struct e1000_hw *hw, u8 * mc_addr, uint32_t rar_index);
-void e1000_write_vfta(struct e1000_hw *hw, uint32_t offset, uint32_t value);
+u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 * mc_addr);
+void e1000_mta_set(struct e1000_hw *hw, u32 hash_value);
+void e1000_rar_set(struct e1000_hw *hw, u8 * mc_addr, u32 rar_index);
+void e1000_write_vfta(struct e1000_hw *hw, u32 offset, u32 value);
 
 /* LED functions */
 int32_t e1000_setup_led(struct e1000_hw *hw);
@@ -417,15 +417,15 @@ int32_t e1000_blink_led_start(struct e1000_hw *hw);
 /* Everything else */
 void e1000_reset_adaptive(struct e1000_hw *hw);
 void e1000_update_adaptive(struct e1000_hw *hw);
-void e1000_tbi_adjust_stats(struct e1000_hw *hw, struct e1000_hw_stats *stats, uint32_t frame_len, u8 * mac_addr);
+void e1000_tbi_adjust_stats(struct e1000_hw *hw, struct e1000_hw_stats *stats, u32 frame_len, u8 * mac_addr);
 void e1000_get_bus_info(struct e1000_hw *hw);
 void e1000_pci_set_mwi(struct e1000_hw *hw);
 void e1000_pci_clear_mwi(struct e1000_hw *hw);
-int32_t e1000_read_pcie_cap_reg(struct e1000_hw *hw, uint32_t reg, u16 *value);
+int32_t e1000_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value);
 void e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc);
 int e1000_pcix_get_mmrbc(struct e1000_hw *hw);
 /* Port I/O is only supported on 82544 and newer */
-void e1000_io_write(struct e1000_hw *hw, unsigned long port, uint32_t value);
+void e1000_io_write(struct e1000_hw *hw, unsigned long port, u32 value);
 int32_t e1000_disable_pciex_master(struct e1000_hw *hw);
 int32_t e1000_check_phy_reset_block(struct e1000_hw *hw);
 
@@ -825,8 +825,8 @@ struct e1000_rar {
 
 /* IPv4 Address Table Entry */
 struct e1000_ipv4_at_entry {
-    volatile uint32_t ipv4_addr;        /* IP Address (RW) */
-    volatile uint32_t reserved;
+    volatile u32 ipv4_addr;        /* IP Address (RW) */
+    volatile u32 reserved;
 };
 
 /* Four wakeup IP addresses are supported */
@@ -842,20 +842,20 @@ struct e1000_ipv6_at_entry {
 
 /* Flexible Filter Length Table Entry */
 struct e1000_fflt_entry {
-    volatile uint32_t length;   /* Flexible Filter Length (RW) */
-    volatile uint32_t reserved;
+    volatile u32 length;   /* Flexible Filter Length (RW) */
+    volatile u32 reserved;
 };
 
 /* Flexible Filter Mask Table Entry */
 struct e1000_ffmt_entry {
-    volatile uint32_t mask;     /* Flexible Filter Mask (RW) */
-    volatile uint32_t reserved;
+    volatile u32 mask;     /* Flexible Filter Mask (RW) */
+    volatile u32 reserved;
 };
 
 /* Flexible Filter Value Table Entry */
 struct e1000_ffvt_entry {
-    volatile uint32_t value;    /* Flexible Filter Value (RW) */
-    volatile uint32_t reserved;
+    volatile u32 value;    /* Flexible Filter Value (RW) */
+    volatile u32 reserved;
 };
 
 /* Four Flexible Filters are supported */
@@ -1386,12 +1386,12 @@ struct e1000_hw {
 	u8 __iomem		*flash_address;
 	e1000_mac_type		mac_type;
 	e1000_phy_type		phy_type;
-	uint32_t		phy_init_script;
+	u32		phy_init_script;
 	e1000_media_type	media_type;
 	void			*back;
 	struct e1000_shadow_ram	*eeprom_shadow_ram;
-	uint32_t		flash_bank_size;
-	uint32_t		flash_base_addr;
+	u32		flash_bank_size;
+	u32		flash_base_addr;
 	e1000_fc_type		fc;
 	e1000_bus_speed		bus_speed;
 	e1000_bus_width		bus_width;
@@ -1400,26 +1400,26 @@ struct e1000_hw {
 	e1000_ms_type		master_slave;
 	e1000_ms_type		original_master_slave;
 	e1000_ffe_config	ffe_config_state;
-	uint32_t		asf_firmware_present;
-	uint32_t		eeprom_semaphore_present;
-	uint32_t		swfw_sync_present;
-	uint32_t		swfwhw_semaphore_present;
+	u32		asf_firmware_present;
+	u32		eeprom_semaphore_present;
+	u32		swfw_sync_present;
+	u32		swfwhw_semaphore_present;
 	unsigned long		io_base;
-	uint32_t		phy_id;
-	uint32_t		phy_revision;
-	uint32_t		phy_addr;
-	uint32_t		original_fc;
-	uint32_t		txcw;
-	uint32_t		autoneg_failed;
-	uint32_t		max_frame_size;
-	uint32_t		min_frame_size;
-	uint32_t		mc_filter_type;
-	uint32_t		num_mc_addrs;
-	uint32_t		collision_delta;
-	uint32_t		tx_packet_delta;
-	uint32_t		ledctl_default;
-	uint32_t		ledctl_mode1;
-	uint32_t		ledctl_mode2;
+	u32		phy_id;
+	u32		phy_revision;
+	u32		phy_addr;
+	u32		original_fc;
+	u32		txcw;
+	u32		autoneg_failed;
+	u32		max_frame_size;
+	u32		min_frame_size;
+	u32		mc_filter_type;
+	u32		num_mc_addrs;
+	u32		collision_delta;
+	u32		tx_packet_delta;
+	u32		ledctl_default;
+	u32		ledctl_mode1;
+	u32		ledctl_mode2;
 	bool			tx_pkt_filtering;
 	struct e1000_host_mng_dhcp_cookie mng_cookie;
 	u16		phy_spd_default;
@@ -2495,7 +2495,7 @@ struct e1000_host_command_info {
 /* Number of milliseconds we wait for PHY configuration done after MAC reset */
 #define PHY_CFG_TIMEOUT             100
 
-#define E1000_TX_BUFFER_SIZE ((uint32_t)1514)
+#define E1000_TX_BUFFER_SIZE ((u32)1514)
 
 /* The carrier extension symbol, as received by the NIC. */
 #define CARRIER_EXTENSION   0x0F
@@ -3362,15 +3362,15 @@ union ich8_hws_flash_ctrl {
 union ich8_hws_flash_regacc {
     struct ich8_flracc {
 #ifdef E1000_BIG_ENDIAN
-        uint32_t gmwag          :8;
-        uint32_t gmrag          :8;
-        uint32_t grwa           :8;
-        uint32_t grra           :8;
+        u32 gmwag          :8;
+        u32 gmrag          :8;
+        u32 grwa           :8;
+        u32 grra           :8;
 #else
-        uint32_t grra           :8;   /* 0:7 GbE region Read Access */
-        uint32_t grwa           :8;   /* 8:15 GbE region Write Access */
-        uint32_t gmrag          :8;   /* 23:16 GbE Master Read Access Grant  */
-        uint32_t gmwag          :8;   /* 31:24 GbE Master Write Access Grant */
+        u32 grra           :8;   /* 0:7 GbE region Read Access */
+        u32 grwa           :8;   /* 8:15 GbE region Write Access */
+        u32 gmrag          :8;   /* 23:16 GbE Master Read Access Grant  */
+        u32 gmwag          :8;   /* 31:24 GbE Master Write Access Grant */
 #endif
     } hsf_flregacc;
     u16 regval;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 62f1430..93e0700 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -402,8 +402,8 @@ e1000_update_mng_vlan(struct e1000_adapter *adapter)
 static void
 e1000_release_hw_control(struct e1000_adapter *adapter)
 {
-	uint32_t ctrl_ext;
-	uint32_t swsm;
+	u32 ctrl_ext;
+	u32 swsm;
 
 	/* Let firmware taken over control of h/w */
 	switch (adapter->hw.mac_type) {
@@ -439,8 +439,8 @@ e1000_release_hw_control(struct e1000_adapter *adapter)
 static void
 e1000_get_hw_control(struct e1000_adapter *adapter)
 {
-	uint32_t ctrl_ext;
-	uint32_t swsm;
+	u32 ctrl_ext;
+	u32 swsm;
 
 	/* Let firmware know the driver has taken over */
 	switch (adapter->hw.mac_type) {
@@ -466,7 +466,7 @@ static void
 e1000_init_manageability(struct e1000_adapter *adapter)
 {
 	if (adapter->en_mng_pt) {
-		uint32_t manc = E1000_READ_REG(&adapter->hw, MANC);
+		u32 manc = E1000_READ_REG(&adapter->hw, MANC);
 
 		/* disable hardware interception of ARP */
 		manc &= ~(E1000_MANC_ARP_EN);
@@ -475,7 +475,7 @@ e1000_init_manageability(struct e1000_adapter *adapter)
 		/* this will probably generate destination unreachable messages
 		 * from the host OS, but the packets will be handled on SMBUS */
 		if (adapter->hw.has_manc2h) {
-			uint32_t manc2h = E1000_READ_REG(&adapter->hw, MANC2H);
+			u32 manc2h = E1000_READ_REG(&adapter->hw, MANC2H);
 
 			manc |= E1000_MANC_EN_MNG2HOST;
 #define E1000_MNG2HOST_PORT_623 (1 << 5)
@@ -493,7 +493,7 @@ static void
 e1000_release_manageability(struct e1000_adapter *adapter)
 {
 	if (adapter->en_mng_pt) {
-		uint32_t manc = E1000_READ_REG(&adapter->hw, MANC);
+		u32 manc = E1000_READ_REG(&adapter->hw, MANC);
 
 		/* re-enable hardware interception of ARP */
 		manc |= E1000_MANC_ARP_EN;
@@ -667,7 +667,7 @@ e1000_reinit_locked(struct e1000_adapter *adapter)
 void
 e1000_reset(struct e1000_adapter *adapter)
 {
-	uint32_t pba = 0, tx_space, min_tx_space, min_rx_space;
+	u32 pba = 0, tx_space, min_tx_space, min_rx_space;
 	u16 fc_high_water_mark = E1000_FC_HIGH_DIFF;
 	bool legacy_pba_adjust = false;
 
@@ -815,7 +815,7 @@ e1000_reset(struct e1000_adapter *adapter)
 	    adapter->hw.mac_type <= e1000_82547_rev_2 &&
 	    adapter->hw.autoneg == 1 &&
 	    adapter->hw.autoneg_advertised == ADVERTISE_1000_FULL) {
-		uint32_t ctrl = E1000_READ_REG(&adapter->hw, CTRL);
+		u32 ctrl = E1000_READ_REG(&adapter->hw, CTRL);
 		/* clear phy power management bit if we are in gig only mode,
 		 * which if enabled will attempt negotiation to 100Mb, which
 		 * can cause a loss of link at power off or driver unload */
@@ -1704,8 +1704,8 @@ e1000_configure_tx(struct e1000_adapter *adapter)
 {
 	uint64_t tdba;
 	struct e1000_hw *hw = &adapter->hw;
-	uint32_t tdlen, tctl, tipg, tarc;
-	uint32_t ipgr1, ipgr2;
+	u32 tdlen, tctl, tipg, tarc;
+	u32 ipgr1, ipgr2;
 
 	/* Setup the HW Tx Head and Tail descriptor pointers */
 
@@ -1947,10 +1947,10 @@ e1000_setup_all_rx_resources(struct e1000_adapter *adapter)
 static void
 e1000_setup_rctl(struct e1000_adapter *adapter)
 {
-	uint32_t rctl, rfctl;
-	uint32_t psrctl = 0;
+	u32 rctl, rfctl;
+	u32 psrctl = 0;
 #ifndef CONFIG_E1000_DISABLE_PACKET_SPLIT
-	uint32_t pages = 0;
+	u32 pages = 0;
 #endif
 
 	rctl = E1000_READ_REG(&adapter->hw, RCTL);
@@ -2067,7 +2067,7 @@ e1000_configure_rx(struct e1000_adapter *adapter)
 {
 	uint64_t rdba;
 	struct e1000_hw *hw = &adapter->hw;
-	uint32_t rdlen, rctl, rxcsum, ctrl_ext;
+	u32 rdlen, rctl, rxcsum, ctrl_ext;
 
 	if (adapter->rx_ps_pages) {
 		/* this is a 32 byte descriptor */
@@ -2387,7 +2387,7 @@ static void
 e1000_enter_82542_rst(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	uint32_t rctl;
+	u32 rctl;
 
 	e1000_pci_clear_mwi(&adapter->hw);
 
@@ -2405,7 +2405,7 @@ static void
 e1000_leave_82542_rst(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	uint32_t rctl;
+	u32 rctl;
 
 	rctl = E1000_READ_REG(&adapter->hw, RCTL);
 	rctl &= ~E1000_RCTL_RST;
@@ -2490,8 +2490,8 @@ e1000_set_rx_mode(struct net_device *netdev)
 	struct e1000_hw *hw = &adapter->hw;
 	struct dev_addr_list *uc_ptr;
 	struct dev_addr_list *mc_ptr;
-	uint32_t rctl;
-	uint32_t hash_value;
+	u32 rctl;
+	u32 hash_value;
 	int i, rar_entries = E1000_RAR_ENTRIES;
 	int mta_reg_count = (hw->mac_type == e1000_ich8lan) ?
 				E1000_NUM_MTA_REGISTERS_ICH8LAN :
@@ -2595,7 +2595,7 @@ e1000_82547_tx_fifo_stall(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
 	struct net_device *netdev = adapter->netdev;
-	uint32_t tctl;
+	u32 tctl;
 
 	if (atomic_read(&adapter->tx_fifo_stall)) {
 		if ((E1000_READ_REG(&adapter->hw, TDT) ==
@@ -2637,7 +2637,7 @@ e1000_watchdog(unsigned long data)
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
-	uint32_t link, tctl;
+	u32 link, tctl;
 	int32_t ret_val;
 
 	ret_val = e1000_check_for_link(&adapter->hw);
@@ -2663,7 +2663,7 @@ e1000_watchdog(unsigned long data)
 
 	if (link) {
 		if (!netif_carrier_ok(netdev)) {
-			uint32_t ctrl;
+			u32 ctrl;
 			bool txb2b = true;
 			e1000_get_speed_and_duplex(&adapter->hw,
 			                           &adapter->link_speed,
@@ -2700,7 +2700,7 @@ e1000_watchdog(unsigned long data)
 			if ((adapter->hw.mac_type == e1000_82571 ||
 			     adapter->hw.mac_type == e1000_82572) &&
 			    !txb2b) {
-				uint32_t tarc0;
+				u32 tarc0;
 				tarc0 = E1000_READ_REG(&adapter->hw, TARC0);
 				tarc0 &= ~(1 << 21);
 				E1000_WRITE_REG(&adapter->hw, TARC0, tarc0);
@@ -2742,7 +2742,7 @@ e1000_watchdog(unsigned long data)
 			/* make sure the receive unit is started */
 			if (adapter->hw.rx_needs_kicking) {
 				struct e1000_hw *hw = &adapter->hw;
-				uint32_t rctl = E1000_READ_REG(hw, RCTL);
+				u32 rctl = E1000_READ_REG(hw, RCTL);
 				E1000_WRITE_REG(hw, RCTL, rctl | E1000_RCTL_EN);
 			}
 		}
@@ -2885,7 +2885,7 @@ static void e1000_set_itr(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u16 current_itr;
-	uint32_t new_itr = adapter->itr;
+	u32 new_itr = adapter->itr;
 
 	if (unlikely(hw->mac_type < e1000_82540))
 		return;
@@ -2959,7 +2959,7 @@ e1000_tso(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 	struct e1000_context_desc *context_desc;
 	struct e1000_buffer *buffer_info;
 	unsigned int i;
-	uint32_t cmd_length = 0;
+	u32 cmd_length = 0;
 	u16 ipcse = 0, tucse, mss;
 	u8 ipcss, ipcso, tucss, tucso, hdr_len;
 	int err;
@@ -3177,7 +3177,7 @@ e1000_tx_queue(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 {
 	struct e1000_tx_desc *tx_desc = NULL;
 	struct e1000_buffer *buffer_info;
-	uint32_t txd_upper = 0, txd_lower = E1000_TXD_CMD_IFCS;
+	u32 txd_upper = 0, txd_lower = E1000_TXD_CMD_IFCS;
 	unsigned int i;
 
 	if (likely(tx_flags & E1000_TX_FLAGS_TSO)) {
@@ -3241,8 +3241,8 @@ e1000_tx_queue(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 static int
 e1000_82547_fifo_workaround(struct e1000_adapter *adapter, struct sk_buff *skb)
 {
-	uint32_t fifo_space = adapter->tx_fifo_size - adapter->tx_fifo_head;
-	uint32_t skb_fifo_len = skb->len + E1000_FIFO_HDR;
+	u32 fifo_space = adapter->tx_fifo_size - adapter->tx_fifo_head;
+	u32 skb_fifo_len = skb->len + E1000_FIFO_HDR;
 
 	skb_fifo_len = ALIGN(skb_fifo_len, E1000_FIFO_HDR);
 
@@ -3829,7 +3829,7 @@ e1000_intr_msi(int irq, void *data)
 #ifndef CONFIG_E1000_NAPI
 	int i;
 #endif
-	uint32_t icr = E1000_READ_REG(hw, ICR);
+	u32 icr = E1000_READ_REG(hw, ICR);
 
 	/* in NAPI mode read ICR disables interrupts using IAM */
 
@@ -3841,7 +3841,7 @@ e1000_intr_msi(int irq, void *data)
 		if (netif_carrier_ok(netdev) &&
 		    (adapter->hw.mac_type == e1000_80003es2lan)) {
 			/* disable receives */
-			uint32_t rctl = E1000_READ_REG(hw, RCTL);
+			u32 rctl = E1000_READ_REG(hw, RCTL);
 			E1000_WRITE_REG(hw, RCTL, rctl & ~E1000_RCTL_EN);
 		}
 		/* guard against interrupt when we're going down */
@@ -3888,7 +3888,7 @@ e1000_intr(int irq, void *data)
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	uint32_t rctl, icr = E1000_READ_REG(hw, ICR);
+	u32 rctl, icr = E1000_READ_REG(hw, ICR);
 #ifndef CONFIG_E1000_NAPI
 	int i;
 #endif
@@ -4139,7 +4139,7 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
 
 static void
 e1000_rx_checksum(struct e1000_adapter *adapter,
-		  uint32_t status_err, uint32_t csum,
+		  u32 status_err, u32 csum,
 		  struct sk_buff *skb)
 {
 	u16 status = (u16)status_err;
@@ -4200,7 +4200,7 @@ e1000_clean_rx_irq(struct e1000_adapter *adapter,
 	struct e1000_rx_desc *rx_desc, *next_rxd;
 	struct e1000_buffer *buffer_info, *next_buffer;
 	unsigned long flags;
-	uint32_t length;
+	u32 length;
 	u8 last_byte;
 	unsigned int i;
 	int cleaned_count = 0;
@@ -4301,8 +4301,8 @@ e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		/* Receive Checksum Offload */
 		e1000_rx_checksum(adapter,
-				  (uint32_t)(status) |
-				  ((uint32_t)(rx_desc->errors) << 24),
+				  (u32)(status) |
+				  ((u32)(rx_desc->errors) << 24),
 				  le16_to_cpu(rx_desc->csum), skb);
 
 		skb->protocol = eth_type_trans(skb, netdev);
@@ -4376,7 +4376,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 	struct e1000_ps_page_dma *ps_page_dma;
 	struct sk_buff *skb;
 	unsigned int i, j;
-	uint32_t length, staterr;
+	u32 length, staterr;
 	int cleaned_count = 0;
 	bool cleaned = false;
 	unsigned int total_rx_bytes=0, total_rx_packets=0;
@@ -4960,7 +4960,7 @@ e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc)
 }
 
 int32_t
-e1000_read_pcie_cap_reg(struct e1000_hw *hw, uint32_t reg, u16 *value)
+e1000_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
 {
     struct e1000_adapter *adapter = hw->back;
     u16 cap_offset;
@@ -4975,7 +4975,7 @@ e1000_read_pcie_cap_reg(struct e1000_hw *hw, uint32_t reg, u16 *value)
 }
 
 void
-e1000_io_write(struct e1000_hw *hw, unsigned long port, uint32_t value)
+e1000_io_write(struct e1000_hw *hw, unsigned long port, u32 value)
 {
 	outl(value, port);
 }
@@ -4984,7 +4984,7 @@ static void
 e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	uint32_t ctrl, rctl;
+	u32 ctrl, rctl;
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_disable(adapter);
@@ -5032,7 +5032,7 @@ static void
 e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	uint32_t vfta, index;
+	u32 vfta, index;
 
 	if ((adapter->hw.mng_cookie.status &
 	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) &&
@@ -5049,7 +5049,7 @@ static void
 e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	uint32_t vfta, index;
+	u32 vfta, index;
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_disable(adapter);
@@ -5129,8 +5129,8 @@ e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	uint32_t ctrl, ctrl_ext, rctl, status;
-	uint32_t wufc = adapter->wol;
+	u32 ctrl, ctrl_ext, rctl, status;
+	u32 wufc = adapter->wol;
 #ifdef CONFIG_PM
 	int retval = 0;
 #endif
@@ -5227,7 +5227,7 @@ e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	uint32_t err;
+	u32 err;
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-- 
1.5.4.rc2


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
