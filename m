From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/2] e1000: convert uint16_t style integers to
	u16
Date: Thu, 03 Apr 2008 10:06:32 -0700
Message-ID: <20080403170632.22624.70994.stgit@localhost.localdomain>
References: <20080403170625.22624.13870.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080403170625.22624.13870.stgit@localhost.localdomain>
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

From: Joe Perches <joe@perches.com>

Conglomerate from 4 separate patches from Joe.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h         |   86 +-
 drivers/net/e1000/e1000_ethtool.c |  160 ++--
 drivers/net/e1000/e1000_hw.c      | 1324 +++++++++++++++++++------------------
 drivers/net/e1000/e1000_hw.h      |  512 +++++++-------
 drivers/net/e1000/e1000_main.c    |  174 ++---
 5 files changed, 1128 insertions(+), 1128 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index a05aa51..31feae1 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -161,13 +161,13 @@ struct e1000_buffer {
 	struct sk_buff *skb;
 	dma_addr_t dma;
 	unsigned long time_stamp;
-	uint16_t length;
-	uint16_t next_to_watch;
+	u16 length;
+	u16 next_to_watch;
 };
 
 
 struct e1000_ps_page { struct page *ps_page[PS_PAGE_BUFFERS]; };
-struct e1000_ps_page_dma { uint64_t ps_page_dma[PS_PAGE_BUFFERS]; };
+struct e1000_ps_page_dma { u64 ps_page_dma[PS_PAGE_BUFFERS]; };
 
 struct e1000_tx_ring {
 	/* pointer to the descriptor ring memory */
@@ -186,8 +186,8 @@ struct e1000_tx_ring {
 	struct e1000_buffer *buffer_info;
 
 	spinlock_t tx_lock;
-	uint16_t tdh;
-	uint16_t tdt;
+	u16 tdh;
+	u16 tdt;
 	bool last_tx_tso;
 };
 
@@ -213,8 +213,8 @@ struct e1000_rx_ring {
 	/* cpu for rx queue */
 	int cpu;
 
-	uint16_t rdh;
-	uint16_t rdt;
+	u16 rdh;
+	u16 rdt;
 };
 
 #define E1000_DESC_UNUSED(R) \
@@ -237,14 +237,14 @@ struct e1000_adapter {
 	struct timer_list watchdog_timer;
 	struct timer_list phy_info_timer;
 	struct vlan_group *vlgrp;
-	uint16_t mng_vlan_id;
-	uint32_t bd_number;
-	uint32_t rx_buffer_len;
-	uint32_t wol;
-	uint32_t smartspeed;
-	uint32_t en_mng_pt;
-	uint16_t link_speed;
-	uint16_t link_duplex;
+	u16 mng_vlan_id;
+	u32 bd_number;
+	u32 rx_buffer_len;
+	u32 wol;
+	u32 smartspeed;
+	u32 en_mng_pt;
+	u16 link_speed;
+	u16 link_duplex;
 	spinlock_t stats_lock;
 #ifdef CONFIG_E1000_NAPI
 	spinlock_t tx_queue_lock;
@@ -254,13 +254,13 @@ struct e1000_adapter {
 	unsigned int total_rx_bytes;
 	unsigned int total_rx_packets;
 	/* Interrupt Throttle Rate */
-	uint32_t itr;
-	uint32_t itr_setting;
-	uint16_t tx_itr;
-	uint16_t rx_itr;
+	u32 itr;
+	u32 itr_setting;
+	u16 tx_itr;
+	u16 rx_itr;
 
 	struct work_struct reset_task;
-	uint8_t fc_autoneg;
+	u8 fc_autoneg;
 
 	struct timer_list blink_timer;
 	unsigned long led_status;
@@ -269,18 +269,18 @@ struct e1000_adapter {
 	struct e1000_tx_ring *tx_ring;      /* One per active queue */
 	unsigned int restart_queue;
 	unsigned long tx_queue_len;
-	uint32_t txd_cmd;
-	uint32_t tx_int_delay;
-	uint32_t tx_abs_int_delay;
-	uint32_t gotcl;
-	uint64_t gotcl_old;
-	uint64_t tpt_old;
-	uint64_t colc_old;
-	uint32_t tx_timeout_count;
-	uint32_t tx_fifo_head;
-	uint32_t tx_head_addr;
-	uint32_t tx_fifo_size;
-	uint8_t  tx_timeout_factor;
+	u32 txd_cmd;
+	u32 tx_int_delay;
+	u32 tx_abs_int_delay;
+	u32 gotcl;
+	u64 gotcl_old;
+	u64 tpt_old;
+	u64 colc_old;
+	u32 tx_timeout_count;
+	u32 tx_fifo_head;
+	u32 tx_head_addr;
+	u32 tx_fifo_size;
+	u8  tx_timeout_factor;
 	atomic_t tx_fifo_stall;
 	bool pcix_82544;
 	bool detect_tx_hung;
@@ -305,17 +305,17 @@ struct e1000_adapter {
 	int num_tx_queues;
 	int num_rx_queues;
 
-	uint64_t hw_csum_err;
-	uint64_t hw_csum_good;
-	uint64_t rx_hdr_split;
-	uint32_t alloc_rx_buff_failed;
-	uint32_t rx_int_delay;
-	uint32_t rx_abs_int_delay;
+	u64 hw_csum_err;
+	u64 hw_csum_good;
+	u64 rx_hdr_split;
+	u32 alloc_rx_buff_failed;
+	u32 rx_int_delay;
+	u32 rx_abs_int_delay;
 	bool rx_csum;
 	unsigned int rx_ps_pages;
-	uint32_t gorcl;
-	uint64_t gorcl_old;
-	uint16_t rx_ps_bsize0;
+	u32 gorcl;
+	u64 gorcl_old;
+	u16 rx_ps_bsize0;
 
 
 	/* OS defined structs */
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
index 05e1fb3..701531e 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -36,7 +36,7 @@ extern int e1000_up(struct e1000_adapter *adapter);
 extern void e1000_down(struct e1000_adapter *adapter);
 extern void e1000_reinit_locked(struct e1000_adapter *adapter);
 extern void e1000_reset(struct e1000_adapter *adapter);
-extern int e1000_set_spd_dplx(struct e1000_adapter *adapter, uint16_t spddplx);
+extern int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx);
 extern int e1000_setup_all_rx_resources(struct e1000_adapter *adapter);
 extern int e1000_setup_all_tx_resources(struct e1000_adapter *adapter);
 extern void e1000_free_all_rx_resources(struct e1000_adapter *adapter);
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
-	uint16_t phy_data;
+	u32 *regs_buff = p;
+	u16 phy_data;
 
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
@@ -477,14 +477,14 @@ e1000_get_eeprom_len(struct net_device *netdev)
 
 static int
 e1000_get_eeprom(struct net_device *netdev,
-                      struct ethtool_eeprom *eeprom, uint8_t *bytes)
+                      struct ethtool_eeprom *eeprom, u8 *bytes)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	uint16_t *eeprom_buff;
+	u16 *eeprom_buff;
 	int first_word, last_word;
 	int ret_val = 0;
-	uint16_t i;
+	u16 i;
 
 	if (eeprom->len == 0)
 		return -EINVAL;
@@ -494,7 +494,7 @@ e1000_get_eeprom(struct net_device *netdev,
 	first_word = eeprom->offset >> 1;
 	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
 
-	eeprom_buff = kmalloc(sizeof(uint16_t) *
+	eeprom_buff = kmalloc(sizeof(u16) *
 			(last_word - first_word + 1), GFP_KERNEL);
 	if (!eeprom_buff)
 		return -ENOMEM;
@@ -514,7 +514,7 @@ e1000_get_eeprom(struct net_device *netdev,
 	for (i = 0; i < last_word - first_word + 1; i++)
 		le16_to_cpus(&eeprom_buff[i]);
 
-	memcpy(bytes, (uint8_t *)eeprom_buff + (eeprom->offset & 1),
+	memcpy(bytes, (u8 *)eeprom_buff + (eeprom->offset & 1),
 			eeprom->len);
 	kfree(eeprom_buff);
 
@@ -523,14 +523,14 @@ e1000_get_eeprom(struct net_device *netdev,
 
 static int
 e1000_set_eeprom(struct net_device *netdev,
-                      struct ethtool_eeprom *eeprom, uint8_t *bytes)
+                      struct ethtool_eeprom *eeprom, u8 *bytes)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	uint16_t *eeprom_buff;
+	u16 *eeprom_buff;
 	void *ptr;
 	int max_len, first_word, last_word, ret_val = 0;
-	uint16_t i;
+	u16 i;
 
 	if (eeprom->len == 0)
 		return -EOPNOTSUPP;
@@ -590,7 +590,7 @@ e1000_get_drvinfo(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	char firmware_version[32];
-	uint16_t eeprom_data;
+	u16 eeprom_data;
 
 	strncpy(drvinfo->driver,  e1000_driver_name, 32);
 	strncpy(drvinfo->version, e1000_driver_version, 32);
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
 
@@ -728,13 +728,13 @@ err_setup:
 	return err;
 }
 
-static bool reg_pattern_test(struct e1000_adapter *adapter, uint64_t *data,
-			     int reg, uint32_t mask, uint32_t write)
+static bool reg_pattern_test(struct e1000_adapter *adapter, u64 *data,
+			     int reg, u32 mask, u32 write)
 {
-	static const uint32_t test[] =
+	static const u32 test[] =
 		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
-	uint8_t __iomem *address = adapter->hw.hw_addr + reg;
-	uint32_t read;
+	u8 __iomem *address = adapter->hw.hw_addr + reg;
+	u32 read;
 	int i;
 
 	for (i = 0; i < ARRAY_SIZE(test); i++) {
@@ -751,11 +751,11 @@ static bool reg_pattern_test(struct e1000_adapter *adapter, uint64_t *data,
 	return false;
 }
 
-static bool reg_set_and_check(struct e1000_adapter *adapter, uint64_t *data,
-			      int reg, uint32_t mask, uint32_t write)
+static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data,
+			      int reg, u32 mask, u32 write)
 {
-	uint8_t __iomem *address = adapter->hw.hw_addr + reg;
-	uint32_t read;
+	u8 __iomem *address = adapter->hw.hw_addr + reg;
+	u32 read;
 
 	writel(write & mask, address);
 	read = readl(address);
@@ -788,10 +788,10 @@ static bool reg_set_and_check(struct e1000_adapter *adapter, uint64_t *data,
 	} while (0)
 
 static int
-e1000_reg_test(struct e1000_adapter *adapter, uint64_t *data)
+e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 {
-	uint32_t value, before, after;
-	uint32_t i, toggle;
+	u32 value, before, after;
+	u32 i, toggle;
 
 	/* The status register is Read Only, so a write should fail.
 	 * Some bits that get toggled are ignored.
@@ -884,11 +884,11 @@ e1000_reg_test(struct e1000_adapter *adapter, uint64_t *data)
 }
 
 static int
-e1000_eeprom_test(struct e1000_adapter *adapter, uint64_t *data)
+e1000_eeprom_test(struct e1000_adapter *adapter, u64 *data)
 {
-	uint16_t temp;
-	uint16_t checksum = 0;
-	uint16_t i;
+	u16 temp;
+	u16 checksum = 0;
+	u16 i;
 
 	*data = 0;
 	/* Read and add up the contents of the EEPROM */
@@ -901,7 +901,7 @@ e1000_eeprom_test(struct e1000_adapter *adapter, uint64_t *data)
 	}
 
 	/* If Checksum is not Correct return error else test passed */
-	if ((checksum != (uint16_t) EEPROM_SUM) && !(*data))
+	if ((checksum != (u16) EEPROM_SUM) && !(*data))
 		*data = 2;
 
 	return *data;
@@ -919,12 +919,12 @@ e1000_test_intr(int irq, void *data)
 }
 
 static int
-e1000_intr_test(struct e1000_adapter *adapter, uint64_t *data)
+e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
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
@@ -1096,8 +1096,8 @@ e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	txdr->next_to_use = txdr->next_to_clean = 0;
 
 	E1000_WRITE_REG(&adapter->hw, TDBAL,
-			((uint64_t) txdr->dma & 0x00000000FFFFFFFF));
-	E1000_WRITE_REG(&adapter->hw, TDBAH, ((uint64_t) txdr->dma >> 32));
+			((u64) txdr->dma & 0x00000000FFFFFFFF));
+	E1000_WRITE_REG(&adapter->hw, TDBAH, ((u64) txdr->dma >> 32));
 	E1000_WRITE_REG(&adapter->hw, TDLEN,
 			txdr->count * sizeof(struct e1000_tx_desc));
 	E1000_WRITE_REG(&adapter->hw, TDH, 0);
@@ -1153,8 +1153,8 @@ e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	rctl = E1000_READ_REG(&adapter->hw, RCTL);
 	E1000_WRITE_REG(&adapter->hw, RCTL, rctl & ~E1000_RCTL_EN);
 	E1000_WRITE_REG(&adapter->hw, RDBAL,
-			((uint64_t) rxdr->dma & 0xFFFFFFFF));
-	E1000_WRITE_REG(&adapter->hw, RDBAH, ((uint64_t) rxdr->dma >> 32));
+			((u64) rxdr->dma & 0xFFFFFFFF));
+	E1000_WRITE_REG(&adapter->hw, RDBAH, ((u64) rxdr->dma >> 32));
 	E1000_WRITE_REG(&adapter->hw, RDLEN, rxdr->size);
 	E1000_WRITE_REG(&adapter->hw, RDH, 0);
 	E1000_WRITE_REG(&adapter->hw, RDT, 0);
@@ -1202,7 +1202,7 @@ e1000_phy_disable_receiver(struct e1000_adapter *adapter)
 static void
 e1000_phy_reset_clk_and_crs(struct e1000_adapter *adapter)
 {
-	uint16_t phy_reg;
+	u16 phy_reg;
 
 	/* Because we reset the PHY above, we need to re-force TX_CLK in the
 	 * Extended PHY Specific Control Register to 25MHz clock.  This
@@ -1226,8 +1226,8 @@ e1000_phy_reset_clk_and_crs(struct e1000_adapter *adapter)
 static int
 e1000_nonintegrated_phy_loopback(struct e1000_adapter *adapter)
 {
-	uint32_t ctrl_reg;
-	uint16_t phy_reg;
+	u32 ctrl_reg;
+	u16 phy_reg;
 
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
 
@@ -1363,8 +1363,8 @@ e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 static int
 e1000_set_phy_loopback(struct e1000_adapter *adapter)
 {
-	uint16_t phy_reg = 0;
-	uint16_t count = 0;
+	u16 phy_reg = 0;
+	u16 count = 0;
 
 	switch (adapter->hw.mac_type) {
 	case e1000_82543:
@@ -1416,7 +1416,7 @@ static int
 e1000_setup_loopback_test(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	uint32_t rctl;
+	u32 rctl;
 
 	if (hw->media_type == e1000_media_type_fiber ||
 	    hw->media_type == e1000_media_type_internal_serdes) {
@@ -1451,8 +1451,8 @@ static void
 e1000_loopback_cleanup(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	uint32_t rctl;
-	uint16_t phy_reg;
+	u32 rctl;
+	u16 phy_reg;
 
 	rctl = E1000_READ_REG(hw, RCTL);
 	rctl &= ~(E1000_RCTL_LBM_TCVR | E1000_RCTL_LBM_MAC);
@@ -1578,7 +1578,7 @@ e1000_run_loopback_test(struct e1000_adapter *adapter)
 }
 
 static int
-e1000_loopback_test(struct e1000_adapter *adapter, uint64_t *data)
+e1000_loopback_test(struct e1000_adapter *adapter, u64 *data)
 {
 	/* PHY loopback cannot be performed if SoL/IDER
 	 * sessions are active */
@@ -1603,7 +1603,7 @@ out:
 }
 
 static int
-e1000_link_test(struct e1000_adapter *adapter, uint64_t *data)
+e1000_link_test(struct e1000_adapter *adapter, u64 *data)
 {
 	*data = 0;
 	if (adapter->hw.media_type == e1000_media_type_internal_serdes) {
@@ -1647,7 +1647,7 @@ e1000_get_sset_count(struct net_device *netdev, int sset)
 
 static void
 e1000_diag_test(struct net_device *netdev,
-		   struct ethtool_test *eth_test, uint64_t *data)
+		   struct ethtool_test *eth_test, u64 *data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	bool if_running = netif_running(netdev);
@@ -1657,9 +1657,9 @@ e1000_diag_test(struct net_device *netdev,
 		/* Offline tests */
 
 		/* save speed, duplex, autoneg settings */
-		uint16_t autoneg_advertised = adapter->hw.autoneg_advertised;
-		uint8_t forced_speed_duplex = adapter->hw.forced_speed_duplex;
-		uint8_t autoneg = adapter->hw.autoneg;
+		u16 autoneg_advertised = adapter->hw.autoneg_advertised;
+		u8 forced_speed_duplex = adapter->hw.forced_speed_duplex;
+		u8 autoneg = adapter->hw.autoneg;
 
 		DPRINTK(HW, INFO, "offline testing starting\n");
 
@@ -1877,7 +1877,7 @@ e1000_led_blink_callback(unsigned long data)
 }
 
 static int
-e1000_phys_id(struct net_device *netdev, uint32_t data)
+e1000_phys_id(struct net_device *netdev, u32 data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
@@ -1927,7 +1927,7 @@ e1000_nway_reset(struct net_device *netdev)
 
 static void
 e1000_get_ethtool_stats(struct net_device *netdev,
-		struct ethtool_stats *stats, uint64_t *data)
+		struct ethtool_stats *stats, u64 *data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int i;
@@ -1936,15 +1936,15 @@ e1000_get_ethtool_stats(struct net_device *netdev,
 	for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
 		char *p = (char *)adapter+e1000_gstrings_stats[i].stat_offset;
 		data[i] = (e1000_gstrings_stats[i].sizeof_stat ==
-			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
+			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
 /*	BUG_ON(i != E1000_STATS_LEN); */
 }
 
 static void
-e1000_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
+e1000_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 {
-	uint8_t *p = data;
+	u8 *p = data;
 	int i;
 
 	switch (stringset) {
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index b642034..9a4b6cb 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -33,107 +33,107 @@
 
 #include "e1000_hw.h"
 
-static int32_t e1000_swfw_sync_acquire(struct e1000_hw *hw, uint16_t mask);
-static void e1000_swfw_sync_release(struct e1000_hw *hw, uint16_t mask);
-static int32_t e1000_read_kmrn_reg(struct e1000_hw *hw, uint32_t reg_addr, uint16_t *data);
-static int32_t e1000_write_kmrn_reg(struct e1000_hw *hw, uint32_t reg_addr, uint16_t data);
-static int32_t e1000_get_software_semaphore(struct e1000_hw *hw);
+static s32 e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask);
+static void e1000_swfw_sync_release(struct e1000_hw *hw, u16 mask);
+static s32 e1000_read_kmrn_reg(struct e1000_hw *hw, u32 reg_addr, u16 *data);
+static s32 e1000_write_kmrn_reg(struct e1000_hw *hw, u32 reg_addr, u16 data);
+static s32 e1000_get_software_semaphore(struct e1000_hw *hw);
 static void e1000_release_software_semaphore(struct e1000_hw *hw);
 
-static uint8_t e1000_arc_subsystem_valid(struct e1000_hw *hw);
-static int32_t e1000_check_downshift(struct e1000_hw *hw);
-static int32_t e1000_check_polarity(struct e1000_hw *hw, e1000_rev_polarity *polarity);
+static u8 e1000_arc_subsystem_valid(struct e1000_hw *hw);
+static s32 e1000_check_downshift(struct e1000_hw *hw);
+static s32 e1000_check_polarity(struct e1000_hw *hw, e1000_rev_polarity *polarity);
 static void e1000_clear_hw_cntrs(struct e1000_hw *hw);
 static void e1000_clear_vfta(struct e1000_hw *hw);
-static int32_t e1000_commit_shadow_ram(struct e1000_hw *hw);
-static int32_t e1000_config_dsp_after_link_change(struct e1000_hw *hw,
+static s32 e1000_commit_shadow_ram(struct e1000_hw *hw);
+static s32 e1000_config_dsp_after_link_change(struct e1000_hw *hw,
 						  bool link_up);
-static int32_t e1000_config_fc_after_link_up(struct e1000_hw *hw);
-static int32_t e1000_detect_gig_phy(struct e1000_hw *hw);
-static int32_t e1000_erase_ich8_4k_segment(struct e1000_hw *hw, uint32_t bank);
-static int32_t e1000_get_auto_rd_done(struct e1000_hw *hw);
-static int32_t e1000_get_cable_length(struct e1000_hw *hw, uint16_t *min_length, uint16_t *max_length);
-static int32_t e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw);
-static int32_t e1000_get_phy_cfg_done(struct e1000_hw *hw);
-static int32_t e1000_get_software_flag(struct e1000_hw *hw);
-static int32_t e1000_ich8_cycle_init(struct e1000_hw *hw);
-static int32_t e1000_ich8_flash_cycle(struct e1000_hw *hw, uint32_t timeout);
-static int32_t e1000_id_led_init(struct e1000_hw *hw);
-static int32_t e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw, uint32_t cnf_base_addr, uint32_t cnf_size);
-static int32_t e1000_init_lcd_from_nvm(struct e1000_hw *hw);
+static s32 e1000_config_fc_after_link_up(struct e1000_hw *hw);
+static s32 e1000_detect_gig_phy(struct e1000_hw *hw);
+static s32 e1000_erase_ich8_4k_segment(struct e1000_hw *hw, u32 bank);
+static s32 e1000_get_auto_rd_done(struct e1000_hw *hw);
+static s32 e1000_get_cable_length(struct e1000_hw *hw, u16 *min_length, u16 *max_length);
+static s32 e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw);
+static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw);
+static s32 e1000_get_software_flag(struct e1000_hw *hw);
+static s32 e1000_ich8_cycle_init(struct e1000_hw *hw);
+static s32 e1000_ich8_flash_cycle(struct e1000_hw *hw, u32 timeout);
+static s32 e1000_id_led_init(struct e1000_hw *hw);
+static s32 e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw, u32 cnf_base_addr, u32 cnf_size);
+static s32 e1000_init_lcd_from_nvm(struct e1000_hw *hw);
 static void e1000_init_rx_addrs(struct e1000_hw *hw);
 static void e1000_initialize_hardware_bits(struct e1000_hw *hw);
 static bool e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw);
-static int32_t e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw);
-static int32_t e1000_mng_enable_host_if(struct e1000_hw *hw);
-static int32_t e1000_mng_host_if_write(struct e1000_hw *hw, uint8_t *buffer, uint16_t length, uint16_t offset, uint8_t *sum);
-static int32_t e1000_mng_write_cmd_header(struct e1000_hw* hw, struct e1000_host_mng_command_header* hdr);
-static int32_t e1000_mng_write_commit(struct e1000_hw *hw);
-static int32_t e1000_phy_ife_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
-static int32_t e1000_phy_igp_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
-static int32_t e1000_read_eeprom_eerd(struct e1000_hw *hw, uint16_t offset, uint16_t words, uint16_t *data);
-static int32_t e1000_write_eeprom_eewr(struct e1000_hw *hw, uint16_t offset, uint16_t words, uint16_t *data);
-static int32_t e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd);
-static int32_t e1000_phy_m88_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
+static s32 e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw);
+static s32 e1000_mng_enable_host_if(struct e1000_hw *hw);
+static s32 e1000_mng_host_if_write(struct e1000_hw *hw, u8 *buffer, u16 length, u16 offset, u8 *sum);
+static s32 e1000_mng_write_cmd_header(struct e1000_hw* hw, struct e1000_host_mng_command_header* hdr);
+static s32 e1000_mng_write_commit(struct e1000_hw *hw);
+static s32 e1000_phy_ife_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
+static s32 e1000_phy_igp_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
+static s32 e1000_read_eeprom_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
+static s32 e1000_write_eeprom_eewr(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
+static s32 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd);
+static s32 e1000_phy_m88_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
 static void e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw);
-static int32_t e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t *data);
-static int32_t e1000_verify_write_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t byte);
-static int32_t e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t byte);
-static int32_t e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index, uint16_t *data);
-static int32_t e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size, uint16_t *data);
-static int32_t e1000_write_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size, uint16_t data);
-static int32_t e1000_read_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words, uint16_t *data);
-static int32_t e1000_write_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words, uint16_t *data);
+static s32 e1000_read_ich8_byte(struct e1000_hw *hw, u32 index, u8 *data);
+static s32 e1000_verify_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte);
+static s32 e1000_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte);
+static s32 e1000_read_ich8_word(struct e1000_hw *hw, u32 index, u16 *data);
+static s32 e1000_read_ich8_data(struct e1000_hw *hw, u32 index, u32 size, u16 *data);
+static s32 e1000_write_ich8_data(struct e1000_hw *hw, u32 index, u32 size, u16 data);
+static s32 e1000_read_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
+static s32 e1000_write_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
 static void e1000_release_software_flag(struct e1000_hw *hw);
-static int32_t e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active);
-static int32_t e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active);
-static int32_t e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, uint32_t no_snoop);
+static s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active);
+static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active);
+static s32 e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, u32 no_snoop);
 static void e1000_set_pci_express_master_disable(struct e1000_hw *hw);
-static int32_t e1000_wait_autoneg(struct e1000_hw *hw);
-static void e1000_write_reg_io(struct e1000_hw *hw, uint32_t offset, uint32_t value);
-static int32_t e1000_set_phy_type(struct e1000_hw *hw);
+static s32 e1000_wait_autoneg(struct e1000_hw *hw);
+static void e1000_write_reg_io(struct e1000_hw *hw, u32 offset, u32 value);
+static s32 e1000_set_phy_type(struct e1000_hw *hw);
 static void e1000_phy_init_script(struct e1000_hw *hw);
-static int32_t e1000_setup_copper_link(struct e1000_hw *hw);
-static int32_t e1000_setup_fiber_serdes_link(struct e1000_hw *hw);
-static int32_t e1000_adjust_serdes_amplitude(struct e1000_hw *hw);
-static int32_t e1000_phy_force_speed_duplex(struct e1000_hw *hw);
-static int32_t e1000_config_mac_to_phy(struct e1000_hw *hw);
-static void e1000_raise_mdi_clk(struct e1000_hw *hw, uint32_t *ctrl);
-static void e1000_lower_mdi_clk(struct e1000_hw *hw, uint32_t *ctrl);
-static void e1000_shift_out_mdi_bits(struct e1000_hw *hw, uint32_t data,
-                                     uint16_t count);
-static uint16_t e1000_shift_in_mdi_bits(struct e1000_hw *hw);
-static int32_t e1000_phy_reset_dsp(struct e1000_hw *hw);
-static int32_t e1000_write_eeprom_spi(struct e1000_hw *hw, uint16_t offset,
-                                      uint16_t words, uint16_t *data);
-static int32_t e1000_write_eeprom_microwire(struct e1000_hw *hw,
-                                            uint16_t offset, uint16_t words,
-                                            uint16_t *data);
-static int32_t e1000_spi_eeprom_ready(struct e1000_hw *hw);
-static void e1000_raise_ee_clk(struct e1000_hw *hw, uint32_t *eecd);
-static void e1000_lower_ee_clk(struct e1000_hw *hw, uint32_t *eecd);
-static void e1000_shift_out_ee_bits(struct e1000_hw *hw, uint16_t data,
-                                    uint16_t count);
-static int32_t e1000_write_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
-                                      uint16_t phy_data);
-static int32_t e1000_read_phy_reg_ex(struct e1000_hw *hw,uint32_t reg_addr,
-                                     uint16_t *phy_data);
-static uint16_t e1000_shift_in_ee_bits(struct e1000_hw *hw, uint16_t count);
-static int32_t e1000_acquire_eeprom(struct e1000_hw *hw);
+static s32 e1000_setup_copper_link(struct e1000_hw *hw);
+static s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw);
+static s32 e1000_adjust_serdes_amplitude(struct e1000_hw *hw);
+static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw);
+static s32 e1000_config_mac_to_phy(struct e1000_hw *hw);
+static void e1000_raise_mdi_clk(struct e1000_hw *hw, u32 *ctrl);
+static void e1000_lower_mdi_clk(struct e1000_hw *hw, u32 *ctrl);
+static void e1000_shift_out_mdi_bits(struct e1000_hw *hw, u32 data,
+                                     u16 count);
+static u16 e1000_shift_in_mdi_bits(struct e1000_hw *hw);
+static s32 e1000_phy_reset_dsp(struct e1000_hw *hw);
+static s32 e1000_write_eeprom_spi(struct e1000_hw *hw, u16 offset,
+                                      u16 words, u16 *data);
+static s32 e1000_write_eeprom_microwire(struct e1000_hw *hw,
+                                            u16 offset, u16 words,
+                                            u16 *data);
+static s32 e1000_spi_eeprom_ready(struct e1000_hw *hw);
+static void e1000_raise_ee_clk(struct e1000_hw *hw, u32 *eecd);
+static void e1000_lower_ee_clk(struct e1000_hw *hw, u32 *eecd);
+static void e1000_shift_out_ee_bits(struct e1000_hw *hw, u16 data,
+                                    u16 count);
+static s32 e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
+                                      u16 phy_data);
+static s32 e1000_read_phy_reg_ex(struct e1000_hw *hw,u32 reg_addr,
+                                     u16 *phy_data);
+static u16 e1000_shift_in_ee_bits(struct e1000_hw *hw, u16 count);
+static s32 e1000_acquire_eeprom(struct e1000_hw *hw);
 static void e1000_release_eeprom(struct e1000_hw *hw);
 static void e1000_standby_eeprom(struct e1000_hw *hw);
-static int32_t e1000_set_vco_speed(struct e1000_hw *hw);
-static int32_t e1000_polarity_reversal_workaround(struct e1000_hw *hw);
-static int32_t e1000_set_phy_mode(struct e1000_hw *hw);
-static int32_t e1000_host_if_read_cookie(struct e1000_hw *hw, uint8_t *buffer);
-static uint8_t e1000_calculate_mng_checksum(char *buffer, uint32_t length);
-static int32_t e1000_configure_kmrn_for_10_100(struct e1000_hw *hw,
-                                               uint16_t duplex);
-static int32_t e1000_configure_kmrn_for_1000(struct e1000_hw *hw);
+static s32 e1000_set_vco_speed(struct e1000_hw *hw);
+static s32 e1000_polarity_reversal_workaround(struct e1000_hw *hw);
+static s32 e1000_set_phy_mode(struct e1000_hw *hw);
+static s32 e1000_host_if_read_cookie(struct e1000_hw *hw, u8 *buffer);
+static u8 e1000_calculate_mng_checksum(char *buffer, u32 length);
+static s32 e1000_configure_kmrn_for_10_100(struct e1000_hw *hw,
+                                               u16 duplex);
+static s32 e1000_configure_kmrn_for_1000(struct e1000_hw *hw);
 
 /* IGP cable length table */
 static const
-uint16_t e1000_igp_cable_length_table[IGP01E1000_AGC_LENGTH_TABLE_SIZE] =
+u16 e1000_igp_cable_length_table[IGP01E1000_AGC_LENGTH_TABLE_SIZE] =
     { 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
       5, 10, 10, 10, 10, 10, 10, 10, 20, 20, 20, 20, 20, 25, 25, 25,
       25, 25, 25, 25, 30, 30, 30, 30, 40, 40, 40, 40, 40, 40, 40, 40,
@@ -144,7 +144,7 @@ uint16_t e1000_igp_cable_length_table[IGP01E1000_AGC_LENGTH_TABLE_SIZE] =
       110, 110, 110, 110, 110, 110, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120};
 
 static const
-uint16_t e1000_igp_2_cable_length_table[IGP02E1000_AGC_LENGTH_TABLE_SIZE] =
+u16 e1000_igp_2_cable_length_table[IGP02E1000_AGC_LENGTH_TABLE_SIZE] =
     { 0, 0, 0, 0, 0, 0, 0, 0, 3, 5, 8, 11, 13, 16, 18, 21,
       0, 0, 0, 3, 6, 10, 13, 16, 19, 23, 26, 29, 32, 35, 38, 41,
       6, 10, 14, 18, 22, 26, 30, 33, 37, 41, 44, 48, 51, 54, 58, 61,
@@ -159,7 +159,7 @@ uint16_t e1000_igp_2_cable_length_table[IGP02E1000_AGC_LENGTH_TABLE_SIZE] =
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static int32_t
+static s32
 e1000_set_phy_type(struct e1000_hw *hw)
 {
     DEBUGFUNC("e1000_set_phy_type");
@@ -213,8 +213,8 @@ e1000_set_phy_type(struct e1000_hw *hw)
 static void
 e1000_phy_init_script(struct e1000_hw *hw)
 {
-    uint32_t ret_val;
-    uint16_t phy_saved_data;
+    u32 ret_val;
+    u16 phy_saved_data;
 
     DEBUGFUNC("e1000_phy_init_script");
 
@@ -272,7 +272,7 @@ e1000_phy_init_script(struct e1000_hw *hw)
         e1000_write_phy_reg(hw, 0x2F5B, phy_saved_data);
 
         if (hw->mac_type == e1000_82547) {
-            uint16_t fused, fine, coarse;
+            u16 fused, fine, coarse;
 
             /* Move to analog registers page */
             e1000_read_phy_reg(hw, IGP01E1000_ANALOG_SPARE_FUSE_STATUS, &fused);
@@ -306,7 +306,7 @@ e1000_phy_init_script(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+s32
 e1000_set_mac_type(struct e1000_hw *hw)
 {
 	DEBUGFUNC("e1000_set_mac_type");
@@ -477,7 +477,7 @@ e1000_set_mac_type(struct e1000_hw *hw)
 void
 e1000_set_media_type(struct e1000_hw *hw)
 {
-    uint32_t status;
+    u32 status;
 
     DEBUGFUNC("e1000_set_media_type");
 
@@ -528,17 +528,17 @@ e1000_set_media_type(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+s32
 e1000_reset_hw(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
-    uint32_t ctrl_ext;
-    uint32_t icr;
-    uint32_t manc;
-    uint32_t led_ctrl;
-    uint32_t timeout;
-    uint32_t extcnf_ctrl;
-    int32_t ret_val;
+    u32 ctrl;
+    u32 ctrl_ext;
+    u32 icr;
+    u32 manc;
+    u32 led_ctrl;
+    u32 timeout;
+    u32 extcnf_ctrl;
+    s32 ret_val;
 
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
@@ -866,15 +866,15 @@ e1000_initialize_hardware_bits(struct e1000_hw *hw)
  * configuration and flow control settings. Clears all on-chip counters. Leaves
  * the transmit and receive units disabled and uninitialized.
  *****************************************************************************/
-int32_t
+s32
 e1000_init_hw(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
-    uint32_t i;
-    int32_t ret_val;
-    uint32_t mta_size;
-    uint32_t reg_data;
-    uint32_t ctrl_ext;
+    u32 ctrl;
+    u32 i;
+    s32 ret_val;
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
@@ -1054,11 +1054,11 @@ e1000_init_hw(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_adjust_serdes_amplitude(struct e1000_hw *hw)
 {
-    uint16_t eeprom_data;
-    int32_t  ret_val;
+    u16 eeprom_data;
+    s32  ret_val;
 
     DEBUGFUNC("e1000_adjust_serdes_amplitude");
 
@@ -1100,12 +1100,12 @@ e1000_adjust_serdes_amplitude(struct e1000_hw *hw)
  * established. Assumes the hardware has previously been reset and the
  * transmitter and receiver are not enabled.
  *****************************************************************************/
-int32_t
+s32
 e1000_setup_link(struct e1000_hw *hw)
 {
-    uint32_t ctrl_ext;
-    int32_t ret_val;
-    uint16_t eeprom_data;
+    u32 ctrl_ext;
+    s32 ret_val;
+    u16 eeprom_data;
 
     DEBUGFUNC("e1000_setup_link");
 
@@ -1233,15 +1233,15 @@ e1000_setup_link(struct e1000_hw *hw)
  * link. Assumes the hardware has been previously reset and the transmitter
  * and receiver are not enabled.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
-    uint32_t status;
-    uint32_t txcw = 0;
-    uint32_t i;
-    uint32_t signal = 0;
-    int32_t ret_val;
+    u32 ctrl;
+    u32 status;
+    u32 txcw = 0;
+    u32 i;
+    u32 signal = 0;
+    s32 ret_val;
 
     DEBUGFUNC("e1000_setup_fiber_serdes_link");
 
@@ -1380,12 +1380,12 @@ e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
+static s32
 e1000_copper_link_preconfig(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
-    int32_t ret_val;
-    uint16_t phy_data;
+    u32 ctrl;
+    s32 ret_val;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_copper_link_preconfig");
 
@@ -1440,12 +1440,12 @@ e1000_copper_link_preconfig(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 *********************************************************************/
-static int32_t
+static s32
 e1000_copper_link_igp_setup(struct e1000_hw *hw)
 {
-    uint32_t led_ctrl;
-    int32_t ret_val;
-    uint16_t phy_data;
+    u32 led_ctrl;
+    s32 ret_val;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_copper_link_igp_setup");
 
@@ -1587,12 +1587,12 @@ e1000_copper_link_igp_setup(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 *********************************************************************/
-static int32_t
+static s32
 e1000_copper_link_ggp_setup(struct e1000_hw *hw)
 {
-    int32_t ret_val;
-    uint16_t phy_data;
-    uint32_t reg_data;
+    s32 ret_val;
+    u16 phy_data;
+    u32 reg_data;
 
     DEBUGFUNC("e1000_copper_link_ggp_setup");
 
@@ -1735,11 +1735,11 @@ e1000_copper_link_ggp_setup(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 *********************************************************************/
-static int32_t
+static s32
 e1000_copper_link_mgp_setup(struct e1000_hw *hw)
 {
-    int32_t ret_val;
-    uint16_t phy_data;
+    s32 ret_val;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_copper_link_mgp_setup");
 
@@ -1839,11 +1839,11 @@ e1000_copper_link_mgp_setup(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 *********************************************************************/
-static int32_t
+static s32
 e1000_copper_link_autoneg(struct e1000_hw *hw)
 {
-    int32_t ret_val;
-    uint16_t phy_data;
+    s32 ret_val;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_copper_link_autoneg");
 
@@ -1910,10 +1910,10 @@ e1000_copper_link_autoneg(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
+static s32
 e1000_copper_link_postconfig(struct e1000_hw *hw)
 {
-    int32_t ret_val;
+    s32 ret_val;
     DEBUGFUNC("e1000_copper_link_postconfig");
 
     if (hw->mac_type >= e1000_82544) {
@@ -1948,13 +1948,13 @@ e1000_copper_link_postconfig(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
+static s32
 e1000_setup_copper_link(struct e1000_hw *hw)
 {
-    int32_t ret_val;
-    uint16_t i;
-    uint16_t phy_data;
-    uint16_t reg_data;
+    s32 ret_val;
+    u16 i;
+    u16 phy_data;
+    u16 reg_data;
 
     DEBUGFUNC("e1000_setup_copper_link");
 
@@ -2062,12 +2062,12 @@ e1000_setup_copper_link(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
-e1000_configure_kmrn_for_10_100(struct e1000_hw *hw, uint16_t duplex)
+static s32
+e1000_configure_kmrn_for_10_100(struct e1000_hw *hw, u16 duplex)
 {
-    int32_t ret_val = E1000_SUCCESS;
-    uint32_t tipg;
-    uint16_t reg_data;
+    s32 ret_val = E1000_SUCCESS;
+    u32 tipg;
+    u16 reg_data;
 
     DEBUGFUNC("e1000_configure_kmrn_for_10_100");
 
@@ -2098,12 +2098,12 @@ e1000_configure_kmrn_for_10_100(struct e1000_hw *hw, uint16_t duplex)
     return ret_val;
 }
 
-static int32_t
+static s32
 e1000_configure_kmrn_for_1000(struct e1000_hw *hw)
 {
-    int32_t ret_val = E1000_SUCCESS;
-    uint16_t reg_data;
-    uint32_t tipg;
+    s32 ret_val = E1000_SUCCESS;
+    u16 reg_data;
+    u32 tipg;
 
     DEBUGFUNC("e1000_configure_kmrn_for_1000");
 
@@ -2135,12 +2135,12 @@ e1000_configure_kmrn_for_1000(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-int32_t
+s32
 e1000_phy_setup_autoneg(struct e1000_hw *hw)
 {
-    int32_t ret_val;
-    uint16_t mii_autoneg_adv_reg;
-    uint16_t mii_1000t_ctrl_reg;
+    s32 ret_val;
+    u16 mii_autoneg_adv_reg;
+    u16 mii_1000t_ctrl_reg;
 
     DEBUGFUNC("e1000_phy_setup_autoneg");
 
@@ -2284,15 +2284,15 @@ e1000_phy_setup_autoneg(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
+static s32
 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
-    int32_t ret_val;
-    uint16_t mii_ctrl_reg;
-    uint16_t mii_status_reg;
-    uint16_t phy_data;
-    uint16_t i;
+    u32 ctrl;
+    s32 ret_val;
+    u16 mii_ctrl_reg;
+    u16 mii_status_reg;
+    u16 phy_data;
+    u16 i;
 
     DEBUGFUNC("e1000_phy_force_speed_duplex");
 
@@ -2538,7 +2538,7 @@ e1000_phy_force_speed_duplex(struct e1000_hw *hw)
 void
 e1000_config_collision_dist(struct e1000_hw *hw)
 {
-    uint32_t tctl, coll_dist;
+    u32 tctl, coll_dist;
 
     DEBUGFUNC("e1000_config_collision_dist");
 
@@ -2565,12 +2565,12 @@ e1000_config_collision_dist(struct e1000_hw *hw)
 * The contents of the PHY register containing the needed information need to
 * be passed in.
 ******************************************************************************/
-static int32_t
+static s32
 e1000_config_mac_to_phy(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
-    int32_t ret_val;
-    uint16_t phy_data;
+    u32 ctrl;
+    s32 ret_val;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_config_mac_to_phy");
 
@@ -2624,10 +2624,10 @@ e1000_config_mac_to_phy(struct e1000_hw *hw)
  * by the PHY rather than the MAC. Software must also configure these
  * bits when link is forced on a fiber connection.
  *****************************************************************************/
-int32_t
+s32
 e1000_force_mac_fc(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
+    u32 ctrl;
 
     DEBUGFUNC("e1000_force_mac_fc");
 
@@ -2691,15 +2691,15 @@ e1000_force_mac_fc(struct e1000_hw *hw)
  * based on the flow control negotiated by the PHY. In TBI mode, the TFCE
  * and RFCE bits will be automaticaly set to the negotiated flow control mode.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_config_fc_after_link_up(struct e1000_hw *hw)
 {
-    int32_t ret_val;
-    uint16_t mii_status_reg;
-    uint16_t mii_nway_adv_reg;
-    uint16_t mii_nway_lp_ability_reg;
-    uint16_t speed;
-    uint16_t duplex;
+    s32 ret_val;
+    u16 mii_status_reg;
+    u16 mii_nway_adv_reg;
+    u16 mii_nway_lp_ability_reg;
+    u16 speed;
+    u16 duplex;
 
     DEBUGFUNC("e1000_config_fc_after_link_up");
 
@@ -2896,17 +2896,17 @@ e1000_config_fc_after_link_up(struct e1000_hw *hw)
  *
  * Called by any function that needs to check the link status of the adapter.
  *****************************************************************************/
-int32_t
+s32
 e1000_check_for_link(struct e1000_hw *hw)
 {
-    uint32_t rxcw = 0;
-    uint32_t ctrl;
-    uint32_t status;
-    uint32_t rctl;
-    uint32_t icr;
-    uint32_t signal = 0;
-    int32_t ret_val;
-    uint16_t phy_data;
+    u32 rxcw = 0;
+    u32 ctrl;
+    u32 status;
+    u32 rctl;
+    u32 icr;
+    u32 signal = 0;
+    s32 ret_val;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_check_for_link");
 
@@ -3022,7 +3022,7 @@ e1000_check_for_link(struct e1000_hw *hw)
          * at gigabit speed, we turn on TBI compatibility.
          */
         if (hw->tbi_compatibility_en) {
-            uint16_t speed, duplex;
+            u16 speed, duplex;
             ret_val = e1000_get_speed_and_duplex(hw, &speed, &duplex);
             if (ret_val) {
                 DEBUGOUT("Error getting link speed and duplex\n");
@@ -3132,14 +3132,14 @@ e1000_check_for_link(struct e1000_hw *hw)
  * speed - Speed of the connection
  * duplex - Duplex setting of the connection
  *****************************************************************************/
-int32_t
+s32
 e1000_get_speed_and_duplex(struct e1000_hw *hw,
-                           uint16_t *speed,
-                           uint16_t *duplex)
+                           u16 *speed,
+                           u16 *duplex)
 {
-    uint32_t status;
-    int32_t ret_val;
-    uint16_t phy_data;
+    u32 status;
+    s32 ret_val;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_get_speed_and_duplex");
 
@@ -3214,12 +3214,12 @@ e1000_get_speed_and_duplex(struct e1000_hw *hw,
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
+static s32
 e1000_wait_autoneg(struct e1000_hw *hw)
 {
-    int32_t ret_val;
-    uint16_t i;
-    uint16_t phy_data;
+    s32 ret_val;
+    u16 i;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_wait_autoneg");
     DEBUGOUT("Waiting for Auto-Neg to complete.\n");
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
-                         uint16_t count)
+                         u32 data,
+                         u16 count)
 {
-    uint32_t ctrl;
-    uint32_t mask;
+    u32 ctrl;
+    u32 mask;
 
     /* We need to shift "count" number of bits out to the PHY. So, the value
      * in the "data" parameter will be shifted out to the PHY one bit at a
@@ -3338,12 +3338,12 @@ e1000_shift_out_mdi_bits(struct e1000_hw *hw,
 *
 * Bits are shifted in in MSB to LSB order.
 ******************************************************************************/
-static uint16_t
+static u16
 e1000_shift_in_mdi_bits(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
-    uint16_t data = 0;
-    uint8_t i;
+    u32 ctrl;
+    u16 data = 0;
+    u8 i;
 
     /* In order to read a register from the PHY, we need to shift in a total
      * of 18 bits from the PHY. The first two bit (turnaround) times are used
@@ -3384,13 +3384,13 @@ e1000_shift_in_mdi_bits(struct e1000_hw *hw)
     return data;
 }
 
-static int32_t
-e1000_swfw_sync_acquire(struct e1000_hw *hw, uint16_t mask)
+static s32
+e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask)
 {
-    uint32_t swfw_sync = 0;
-    uint32_t swmask = mask;
-    uint32_t fwmask = mask << 16;
-    int32_t timeout = 200;
+    u32 swfw_sync = 0;
+    u32 swmask = mask;
+    u32 fwmask = mask << 16;
+    s32 timeout = 200;
 
     DEBUGFUNC("e1000_swfw_sync_acquire");
 
@@ -3429,10 +3429,10 @@ e1000_swfw_sync_acquire(struct e1000_hw *hw, uint16_t mask)
 }
 
 static void
-e1000_swfw_sync_release(struct e1000_hw *hw, uint16_t mask)
+e1000_swfw_sync_release(struct e1000_hw *hw, u16 mask)
 {
-    uint32_t swfw_sync;
-    uint32_t swmask = mask;
+    u32 swfw_sync;
+    u32 swmask = mask;
 
     DEBUGFUNC("e1000_swfw_sync_release");
 
@@ -3464,13 +3464,13 @@ e1000_swfw_sync_release(struct e1000_hw *hw, uint16_t mask)
 * hw - Struct containing variables accessed by shared code
 * reg_addr - address of the PHY register to read
 ******************************************************************************/
-int32_t
+s32
 e1000_read_phy_reg(struct e1000_hw *hw,
-                   uint32_t reg_addr,
-                   uint16_t *phy_data)
+                   u32 reg_addr,
+                   u16 *phy_data)
 {
-    uint32_t ret_val;
-    uint16_t swfw;
+    u32 ret_val;
+    u16 swfw;
 
     DEBUGFUNC("e1000_read_phy_reg");
 
@@ -3488,7 +3488,7 @@ e1000_read_phy_reg(struct e1000_hw *hw,
         hw->phy_type == e1000_phy_igp_2) &&
        (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
         ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
-                                         (uint16_t)reg_addr);
+                                         (u16)reg_addr);
         if (ret_val) {
             e1000_swfw_sync_release(hw, swfw);
             return ret_val;
@@ -3499,14 +3499,14 @@ e1000_read_phy_reg(struct e1000_hw *hw,
             /* Select Configuration Page */
             if ((reg_addr & MAX_PHY_REG_ADDRESS) < GG82563_MIN_ALT_REG) {
                 ret_val = e1000_write_phy_reg_ex(hw, GG82563_PHY_PAGE_SELECT,
-                          (uint16_t)((uint16_t)reg_addr >> GG82563_PAGE_SHIFT));
+                          (u16)((u16)reg_addr >> GG82563_PAGE_SHIFT));
             } else {
                 /* Use Alternative Page Select register to access
                  * registers 30 and 31
                  */
                 ret_val = e1000_write_phy_reg_ex(hw,
                                                  GG82563_PHY_PAGE_SELECT_ALT,
-                          (uint16_t)((uint16_t)reg_addr >> GG82563_PAGE_SHIFT));
+                          (u16)((u16)reg_addr >> GG82563_PAGE_SHIFT));
             }
 
             if (ret_val) {
@@ -3523,13 +3523,13 @@ e1000_read_phy_reg(struct e1000_hw *hw,
     return ret_val;
 }
 
-static int32_t
-e1000_read_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
-                      uint16_t *phy_data)
+static s32
+e1000_read_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
+                      u16 *phy_data)
 {
-    uint32_t i;
-    uint32_t mdic = 0;
-    const uint32_t phy_addr = 1;
+    u32 i;
+    u32 mdic = 0;
+    const u32 phy_addr = 1;
 
     DEBUGFUNC("e1000_read_phy_reg_ex");
 
@@ -3563,7 +3563,7 @@ e1000_read_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
             DEBUGOUT("MDI Error\n");
             return -E1000_ERR_PHY;
         }
-        *phy_data = (uint16_t) mdic;
+        *phy_data = (u16) mdic;
     } else {
         /* We must first send a preamble through the MDIO pin to signal the
          * beginning of an MII instruction.  This is done by sending 32
@@ -3603,12 +3603,12 @@ e1000_read_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
 * reg_addr - address of the PHY register to write
 * data - data to write to the PHY
 ******************************************************************************/
-int32_t
-e1000_write_phy_reg(struct e1000_hw *hw, uint32_t reg_addr,
-                    uint16_t phy_data)
+s32
+e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr,
+                    u16 phy_data)
 {
-    uint32_t ret_val;
-    uint16_t swfw;
+    u32 ret_val;
+    u16 swfw;
 
     DEBUGFUNC("e1000_write_phy_reg");
 
@@ -3626,7 +3626,7 @@ e1000_write_phy_reg(struct e1000_hw *hw, uint32_t reg_addr,
         hw->phy_type == e1000_phy_igp_2) &&
        (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
         ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
-                                         (uint16_t)reg_addr);
+                                         (u16)reg_addr);
         if (ret_val) {
             e1000_swfw_sync_release(hw, swfw);
             return ret_val;
@@ -3637,14 +3637,14 @@ e1000_write_phy_reg(struct e1000_hw *hw, uint32_t reg_addr,
             /* Select Configuration Page */
             if ((reg_addr & MAX_PHY_REG_ADDRESS) < GG82563_MIN_ALT_REG) {
                 ret_val = e1000_write_phy_reg_ex(hw, GG82563_PHY_PAGE_SELECT,
-                          (uint16_t)((uint16_t)reg_addr >> GG82563_PAGE_SHIFT));
+                          (u16)((u16)reg_addr >> GG82563_PAGE_SHIFT));
             } else {
                 /* Use Alternative Page Select register to access
                  * registers 30 and 31
                  */
                 ret_val = e1000_write_phy_reg_ex(hw,
                                                  GG82563_PHY_PAGE_SELECT_ALT,
-                          (uint16_t)((uint16_t)reg_addr >> GG82563_PAGE_SHIFT));
+                          (u16)((u16)reg_addr >> GG82563_PAGE_SHIFT));
             }
 
             if (ret_val) {
@@ -3661,13 +3661,13 @@ e1000_write_phy_reg(struct e1000_hw *hw, uint32_t reg_addr,
     return ret_val;
 }
 
-static int32_t
-e1000_write_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
-                       uint16_t phy_data)
+static s32
+e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
+                       u16 phy_data)
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
@@ -3723,13 +3723,13 @@ e1000_write_phy_reg_ex(struct e1000_hw *hw, uint32_t reg_addr,
     return E1000_SUCCESS;
 }
 
-static int32_t
+static s32
 e1000_read_kmrn_reg(struct e1000_hw *hw,
-                    uint32_t reg_addr,
-                    uint16_t *data)
+                    u32 reg_addr,
+                    u16 *data)
 {
-    uint32_t reg_val;
-    uint16_t swfw;
+    u32 reg_val;
+    u16 swfw;
     DEBUGFUNC("e1000_read_kmrn_reg");
 
     if ((hw->mac_type == e1000_80003es2lan) &&
@@ -3750,19 +3750,19 @@ e1000_read_kmrn_reg(struct e1000_hw *hw,
 
     /* Read the data returned */
     reg_val = E1000_READ_REG(hw, KUMCTRLSTA);
-    *data = (uint16_t)reg_val;
+    *data = (u16)reg_val;
 
     e1000_swfw_sync_release(hw, swfw);
     return E1000_SUCCESS;
 }
 
-static int32_t
+static s32
 e1000_write_kmrn_reg(struct e1000_hw *hw,
-                     uint32_t reg_addr,
-                     uint16_t data)
+                     u32 reg_addr,
+                     u16 data)
 {
-    uint32_t reg_val;
-    uint16_t swfw;
+    u32 reg_val;
+    u16 swfw;
     DEBUGFUNC("e1000_write_kmrn_reg");
 
     if ((hw->mac_type == e1000_80003es2lan) &&
@@ -3788,13 +3788,13 @@ e1000_write_kmrn_reg(struct e1000_hw *hw,
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-int32_t
+s32
 e1000_phy_hw_reset(struct e1000_hw *hw)
 {
-    uint32_t ctrl, ctrl_ext;
-    uint32_t led_ctrl;
-    int32_t ret_val;
-    uint16_t swfw;
+    u32 ctrl, ctrl_ext;
+    u32 led_ctrl;
+    s32 ret_val;
+    u16 swfw;
 
     DEBUGFUNC("e1000_phy_hw_reset");
 
@@ -3882,11 +3882,11 @@ e1000_phy_hw_reset(struct e1000_hw *hw)
 *
 * Sets bit 15 of the MII Control register
 ******************************************************************************/
-int32_t
+s32
 e1000_phy_reset(struct e1000_hw *hw)
 {
-    int32_t ret_val;
-    uint16_t phy_data;
+    s32 ret_val;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_phy_reset");
 
@@ -3937,9 +3937,9 @@ e1000_phy_reset(struct e1000_hw *hw)
 void
 e1000_phy_powerdown_workaround(struct e1000_hw *hw)
 {
-    int32_t reg;
-    uint16_t phy_data;
-    int32_t retry = 0;
+    s32 reg;
+    u16 phy_data;
+    s32 retry = 0;
 
     DEBUGFUNC("e1000_phy_powerdown_workaround");
 
@@ -3987,13 +3987,13 @@ e1000_phy_powerdown_workaround(struct e1000_hw *hw)
 *
 * hw - struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
+static s32
 e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw)
 {
-    int32_t ret_val;
-    int32_t reg;
-    int32_t cnt;
-    uint16_t phy_data;
+    s32 ret_val;
+    s32 reg;
+    s32 cnt;
+    u16 phy_data;
 
     if (hw->kmrn_lock_loss_workaround_disabled)
         return E1000_SUCCESS;
@@ -4040,11 +4040,11 @@ e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
+static s32
 e1000_detect_gig_phy(struct e1000_hw *hw)
 {
-    int32_t phy_init_status, ret_val;
-    uint16_t phy_id_high, phy_id_low;
+    s32 phy_init_status, ret_val;
+    u16 phy_id_high, phy_id_low;
     bool match = false;
 
     DEBUGFUNC("e1000_detect_gig_phy");
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
@@ -4136,10 +4136,10 @@ e1000_detect_gig_phy(struct e1000_hw *hw)
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
+static s32
 e1000_phy_reset_dsp(struct e1000_hw *hw)
 {
-    int32_t ret_val;
+    s32 ret_val;
     DEBUGFUNC("e1000_phy_reset_dsp");
 
     do {
@@ -4163,12 +4163,12 @@ e1000_phy_reset_dsp(struct e1000_hw *hw)
 * hw - Struct containing variables accessed by shared code
 * phy_info - PHY information structure
 ******************************************************************************/
-static int32_t
+static s32
 e1000_phy_igp_get_info(struct e1000_hw *hw,
                        struct e1000_phy_info *phy_info)
 {
-    int32_t ret_val;
-    uint16_t phy_data, min_length, max_length, average;
+    s32 ret_val;
+    u16 phy_data, min_length, max_length, average;
     e1000_rev_polarity polarity;
 
     DEBUGFUNC("e1000_phy_igp_get_info");
@@ -4240,12 +4240,12 @@ e1000_phy_igp_get_info(struct e1000_hw *hw,
 * hw - Struct containing variables accessed by shared code
 * phy_info - PHY information structure
 ******************************************************************************/
-static int32_t
+static s32
 e1000_phy_ife_get_info(struct e1000_hw *hw,
                        struct e1000_phy_info *phy_info)
 {
-    int32_t ret_val;
-    uint16_t phy_data;
+    s32 ret_val;
+    u16 phy_data;
     e1000_rev_polarity polarity;
 
     DEBUGFUNC("e1000_phy_ife_get_info");
@@ -4290,12 +4290,12 @@ e1000_phy_ife_get_info(struct e1000_hw *hw,
 * hw - Struct containing variables accessed by shared code
 * phy_info - PHY information structure
 ******************************************************************************/
-static int32_t
+static s32
 e1000_phy_m88_get_info(struct e1000_hw *hw,
                        struct e1000_phy_info *phy_info)
 {
-    int32_t ret_val;
-    uint16_t phy_data;
+    s32 ret_val;
+    u16 phy_data;
     e1000_rev_polarity polarity;
 
     DEBUGFUNC("e1000_phy_m88_get_info");
@@ -4369,12 +4369,12 @@ e1000_phy_m88_get_info(struct e1000_hw *hw,
 * hw - Struct containing variables accessed by shared code
 * phy_info - PHY information structure
 ******************************************************************************/
-int32_t
+s32
 e1000_phy_get_info(struct e1000_hw *hw,
                    struct e1000_phy_info *phy_info)
 {
-    int32_t ret_val;
-    uint16_t phy_data;
+    s32 ret_val;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_phy_get_info");
 
@@ -4415,7 +4415,7 @@ e1000_phy_get_info(struct e1000_hw *hw,
         return e1000_phy_m88_get_info(hw, phy_info);
 }
 
-int32_t
+s32
 e1000_validate_mdi_setting(struct e1000_hw *hw)
 {
     DEBUGFUNC("e1000_validate_mdi_settings");
@@ -4436,13 +4436,13 @@ e1000_validate_mdi_setting(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+s32
 e1000_init_eeprom_params(struct e1000_hw *hw)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
-    uint32_t eecd = E1000_READ_REG(hw, EECD);
-    int32_t ret_val = E1000_SUCCESS;
-    uint16_t eeprom_size;
+    u32 eecd = E1000_READ_REG(hw, EECD);
+    s32 ret_val = E1000_SUCCESS;
+    u16 eeprom_size;
 
     DEBUGFUNC("e1000_init_eeprom_params");
 
@@ -4561,8 +4561,8 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
         break;
     case e1000_ich8lan:
         {
-        int32_t  i = 0;
-        uint32_t flash_size = E1000_READ_ICH_FLASH_REG(hw, ICH_FLASH_GFPREG);
+        s32  i = 0;
+        u32 flash_size = E1000_READ_ICH_FLASH_REG(hw, ICH_FLASH_GFPREG);
 
         eeprom->type = e1000_eeprom_ich8;
         eeprom->use_eerd = false;
@@ -4586,7 +4586,7 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
 
         hw->flash_bank_size *= ICH_FLASH_SECTOR_SIZE;
 
-        hw->flash_bank_size /= 2 * sizeof(uint16_t);
+        hw->flash_bank_size /= 2 * sizeof(u16);
 
         break;
         }
@@ -4611,7 +4611,7 @@ e1000_init_eeprom_params(struct e1000_hw *hw)
             if (eeprom_size)
                 eeprom_size++;
         } else {
-            eeprom_size = (uint16_t)((eecd & E1000_EECD_SIZE_EX_MASK) >>
+            eeprom_size = (u16)((eecd & E1000_EECD_SIZE_EX_MASK) >>
                           E1000_EECD_SIZE_EX_SHIFT);
         }
 
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
@@ -4667,12 +4667,12 @@ e1000_lower_ee_clk(struct e1000_hw *hw,
  *****************************************************************************/
 static void
 e1000_shift_out_ee_bits(struct e1000_hw *hw,
-                        uint16_t data,
-                        uint16_t count)
+                        u16 data,
+                        u16 count)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
-    uint32_t eecd;
-    uint32_t mask;
+    u32 eecd;
+    u32 mask;
 
     /* We need to shift "count" bits out to the EEPROM. So, value in the
      * "data" parameter will be shifted out to the EEPROM one bit at a time.
@@ -4718,13 +4718,13 @@ e1000_shift_out_ee_bits(struct e1000_hw *hw,
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static uint16_t
+static u16
 e1000_shift_in_ee_bits(struct e1000_hw *hw,
-                       uint16_t count)
+                       u16 count)
 {
-    uint32_t eecd;
-    uint32_t i;
-    uint16_t data;
+    u32 eecd;
+    u32 i;
+    u16 data;
 
     /* In order to read a register from the EEPROM, we need to shift 'count'
      * bits in from the EEPROM. Bits are "shifted in" by raising the clock
@@ -4762,11 +4762,11 @@ e1000_shift_in_ee_bits(struct e1000_hw *hw,
  * Lowers EEPROM clock. Clears input pin. Sets the chip select pin. This
  * function should be called before issuing a command to the EEPROM.
  *****************************************************************************/
-static int32_t
+static s32
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
 
@@ -4921,11 +4921,11 @@ e1000_release_eeprom(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static int32_t
+static s32
 e1000_spi_eeprom_ready(struct e1000_hw *hw)
 {
-    uint16_t retry_count = 0;
-    uint8_t spi_stat_reg;
+    u16 retry_count = 0;
+    u8 spi_stat_reg;
 
     DEBUGFUNC("e1000_spi_eeprom_ready");
 
@@ -4938,7 +4938,7 @@ e1000_spi_eeprom_ready(struct e1000_hw *hw)
     do {
         e1000_shift_out_ee_bits(hw, EEPROM_RDSR_OPCODE_SPI,
                                 hw->eeprom.opcode_bits);
-        spi_stat_reg = (uint8_t)e1000_shift_in_ee_bits(hw, 8);
+        spi_stat_reg = (u8)e1000_shift_in_ee_bits(hw, 8);
         if (!(spi_stat_reg & EEPROM_STATUS_RDY_SPI))
             break;
 
@@ -4967,14 +4967,14 @@ e1000_spi_eeprom_ready(struct e1000_hw *hw)
  * data - word read from the EEPROM
  * words - number of words to read
  *****************************************************************************/
-int32_t
+s32
 e1000_read_eeprom(struct e1000_hw *hw,
-                  uint16_t offset,
-                  uint16_t words,
-                  uint16_t *data)
+                  u16 offset,
+                  u16 words,
+                  u16 *data)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
-    uint32_t i = 0;
+    u32 i = 0;
 
     DEBUGFUNC("e1000_read_eeprom");
 
@@ -5012,8 +5012,8 @@ e1000_read_eeprom(struct e1000_hw *hw,
     /* Set up the SPI or Microwire EEPROM for bit-bang reading.  We have
      * acquired the EEPROM at this point, so any returns should relase it */
     if (eeprom->type == e1000_eeprom_spi) {
-        uint16_t word_in;
-        uint8_t read_opcode = EEPROM_READ_OPCODE_SPI;
+        u16 word_in;
+        u8 read_opcode = EEPROM_READ_OPCODE_SPI;
 
         if (e1000_spi_eeprom_ready(hw)) {
             e1000_release_eeprom(hw);
@@ -5028,7 +5028,7 @@ e1000_read_eeprom(struct e1000_hw *hw,
 
         /* Send the READ command (opcode + addr)  */
         e1000_shift_out_ee_bits(hw, read_opcode, eeprom->opcode_bits);
-        e1000_shift_out_ee_bits(hw, (uint16_t)(offset*2), eeprom->address_bits);
+        e1000_shift_out_ee_bits(hw, (u16)(offset*2), eeprom->address_bits);
 
         /* Read the data.  The address of the eeprom internally increments with
          * each byte (spi) being read, saving on the overhead of eeprom setup
@@ -5044,7 +5044,7 @@ e1000_read_eeprom(struct e1000_hw *hw,
             /* Send the READ command (opcode + addr)  */
             e1000_shift_out_ee_bits(hw, EEPROM_READ_OPCODE_MICROWIRE,
                                     eeprom->opcode_bits);
-            e1000_shift_out_ee_bits(hw, (uint16_t)(offset + i),
+            e1000_shift_out_ee_bits(hw, (u16)(offset + i),
                                     eeprom->address_bits);
 
             /* Read the data.  For microwire, each word requires the overhead
@@ -5068,14 +5068,14 @@ e1000_read_eeprom(struct e1000_hw *hw,
  * data - word read from the EEPROM
  * words - number of words to read
  *****************************************************************************/
-static int32_t
+static s32
 e1000_read_eeprom_eerd(struct e1000_hw *hw,
-                  uint16_t offset,
-                  uint16_t words,
-                  uint16_t *data)
+                  u16 offset,
+                  u16 words,
+                  u16 *data)
 {
-    uint32_t i, eerd = 0;
-    int32_t error = 0;
+    u32 i, eerd = 0;
+    s32 error = 0;
 
     for (i = 0; i < words; i++) {
         eerd = ((offset+i) << E1000_EEPROM_RW_ADDR_SHIFT) +
@@ -5102,15 +5102,15 @@ e1000_read_eeprom_eerd(struct e1000_hw *hw,
  * data - word read from the EEPROM
  * words - number of words to read
  *****************************************************************************/
-static int32_t
+static s32
 e1000_write_eeprom_eewr(struct e1000_hw *hw,
-                   uint16_t offset,
-                   uint16_t words,
-                   uint16_t *data)
+                   u16 offset,
+                   u16 words,
+                   u16 *data)
 {
-    uint32_t    register_value = 0;
-    uint32_t    i              = 0;
-    int32_t     error          = 0;
+    u32    register_value = 0;
+    u32    i              = 0;
+    s32     error          = 0;
 
     if (e1000_swfw_sync_acquire(hw, E1000_SWFW_EEP_SM))
         return -E1000_ERR_SWFW_SYNC;
@@ -5143,12 +5143,12 @@ e1000_write_eeprom_eewr(struct e1000_hw *hw,
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static int32_t
+static s32
 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd)
 {
-    uint32_t attempts = 100000;
-    uint32_t i, reg = 0;
-    int32_t done = E1000_ERR_EEPROM;
+    u32 attempts = 100000;
+    u32 i, reg = 0;
+    s32 done = E1000_ERR_EEPROM;
 
     for (i = 0; i < attempts; i++) {
         if (eerd == E1000_EEPROM_POLL_READ)
@@ -5174,7 +5174,7 @@ e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd)
 static bool
 e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw)
 {
-    uint32_t eecd = 0;
+    u32 eecd = 0;
 
     DEBUGFUNC("e1000_is_onboard_nvm_eeprom");
 
@@ -5204,11 +5204,11 @@ e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw)
  * If the the sum of the 64 16 bit words is 0xBABA, the EEPROM's checksum is
  * valid.
  *****************************************************************************/
-int32_t
+s32
 e1000_validate_eeprom_checksum(struct e1000_hw *hw)
 {
-    uint16_t checksum = 0;
-    uint16_t i, eeprom_data;
+    u16 checksum = 0;
+    u16 i, eeprom_data;
 
     DEBUGFUNC("e1000_validate_eeprom_checksum");
 
@@ -5252,7 +5252,7 @@ e1000_validate_eeprom_checksum(struct e1000_hw *hw)
         checksum += eeprom_data;
     }
 
-    if (checksum == (uint16_t) EEPROM_SUM)
+    if (checksum == (u16) EEPROM_SUM)
         return E1000_SUCCESS;
     else {
         DEBUGOUT("EEPROM Checksum Invalid\n");
@@ -5268,12 +5268,12 @@ e1000_validate_eeprom_checksum(struct e1000_hw *hw)
  * Sums the first 63 16 bit words of the EEPROM. Subtracts the sum from 0xBABA.
  * Writes the difference to word offset 63 of the EEPROM.
  *****************************************************************************/
-int32_t
+s32
 e1000_update_eeprom_checksum(struct e1000_hw *hw)
 {
-    uint32_t ctrl_ext;
-    uint16_t checksum = 0;
-    uint16_t i, eeprom_data;
+    u32 ctrl_ext;
+    u16 checksum = 0;
+    u16 i, eeprom_data;
 
     DEBUGFUNC("e1000_update_eeprom_checksum");
 
@@ -5284,7 +5284,7 @@ e1000_update_eeprom_checksum(struct e1000_hw *hw)
         }
         checksum += eeprom_data;
     }
-    checksum = (uint16_t) EEPROM_SUM - checksum;
+    checksum = (u16) EEPROM_SUM - checksum;
     if (e1000_write_eeprom(hw, EEPROM_CHECKSUM_REG, 1, &checksum) < 0) {
         DEBUGOUT("EEPROM Write Error\n");
         return -E1000_ERR_EEPROM;
@@ -5313,14 +5313,14 @@ e1000_update_eeprom_checksum(struct e1000_hw *hw)
  * If e1000_update_eeprom_checksum is not called after this function, the
  * EEPROM will most likely contain an invalid checksum.
  *****************************************************************************/
-int32_t
+s32
 e1000_write_eeprom(struct e1000_hw *hw,
-                   uint16_t offset,
-                   uint16_t words,
-                   uint16_t *data)
+                   u16 offset,
+                   u16 words,
+                   u16 *data)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
-    int32_t status = 0;
+    s32 status = 0;
 
     DEBUGFUNC("e1000_write_eeprom");
 
@@ -5370,19 +5370,19 @@ e1000_write_eeprom(struct e1000_hw *hw,
  * data - pointer to array of 8 bit words to be written to the EEPROM
  *
  *****************************************************************************/
-static int32_t
+static s32
 e1000_write_eeprom_spi(struct e1000_hw *hw,
-                       uint16_t offset,
-                       uint16_t words,
-                       uint16_t *data)
+                       u16 offset,
+                       u16 words,
+                       u16 *data)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
-    uint16_t widx = 0;
+    u16 widx = 0;
 
     DEBUGFUNC("e1000_write_eeprom_spi");
 
     while (widx < words) {
-        uint8_t write_opcode = EEPROM_WRITE_OPCODE_SPI;
+        u8 write_opcode = EEPROM_WRITE_OPCODE_SPI;
 
         if (e1000_spi_eeprom_ready(hw)) return -E1000_ERR_EEPROM;
 
@@ -5401,14 +5401,14 @@ e1000_write_eeprom_spi(struct e1000_hw *hw,
         /* Send the Write command (8-bit opcode + addr) */
         e1000_shift_out_ee_bits(hw, write_opcode, eeprom->opcode_bits);
 
-        e1000_shift_out_ee_bits(hw, (uint16_t)((offset + widx)*2),
+        e1000_shift_out_ee_bits(hw, (u16)((offset + widx)*2),
                                 eeprom->address_bits);
 
         /* Send the data */
 
         /* Loop to allow for up to whole page write (32 bytes) of eeprom */
         while (widx < words) {
-            uint16_t word_out = data[widx];
+            u16 word_out = data[widx];
             word_out = (word_out >> 8) | (word_out << 8);
             e1000_shift_out_ee_bits(hw, word_out, 16);
             widx++;
@@ -5436,16 +5436,16 @@ e1000_write_eeprom_spi(struct e1000_hw *hw,
  * data - pointer to array of 16 bit words to be written to the EEPROM
  *
  *****************************************************************************/
-static int32_t
+static s32
 e1000_write_eeprom_microwire(struct e1000_hw *hw,
-                             uint16_t offset,
-                             uint16_t words,
-                             uint16_t *data)
+                             u16 offset,
+                             u16 words,
+                             u16 *data)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
-    uint32_t eecd;
-    uint16_t words_written = 0;
-    uint16_t i = 0;
+    u32 eecd;
+    u16 words_written = 0;
+    u16 i = 0;
 
     DEBUGFUNC("e1000_write_eeprom_microwire");
 
@@ -5456,9 +5456,9 @@ e1000_write_eeprom_microwire(struct e1000_hw *hw,
      * EEPROM into write/erase mode.
      */
     e1000_shift_out_ee_bits(hw, EEPROM_EWEN_OPCODE_MICROWIRE,
-                            (uint16_t)(eeprom->opcode_bits + 2));
+                            (u16)(eeprom->opcode_bits + 2));
 
-    e1000_shift_out_ee_bits(hw, 0, (uint16_t)(eeprom->address_bits - 2));
+    e1000_shift_out_ee_bits(hw, 0, (u16)(eeprom->address_bits - 2));
 
     /* Prepare the EEPROM */
     e1000_standby_eeprom(hw);
@@ -5468,7 +5468,7 @@ e1000_write_eeprom_microwire(struct e1000_hw *hw,
         e1000_shift_out_ee_bits(hw, EEPROM_WRITE_OPCODE_MICROWIRE,
                                 eeprom->opcode_bits);
 
-        e1000_shift_out_ee_bits(hw, (uint16_t)(offset + words_written),
+        e1000_shift_out_ee_bits(hw, (u16)(offset + words_written),
                                 eeprom->address_bits);
 
         /* Send the data */
@@ -5506,9 +5506,9 @@ e1000_write_eeprom_microwire(struct e1000_hw *hw,
      * EEPROM out of write/erase mode.
      */
     e1000_shift_out_ee_bits(hw, EEPROM_EWDS_OPCODE_MICROWIRE,
-                            (uint16_t)(eeprom->opcode_bits + 2));
+                            (u16)(eeprom->opcode_bits + 2));
 
-    e1000_shift_out_ee_bits(hw, 0, (uint16_t)(eeprom->address_bits - 2));
+    e1000_shift_out_ee_bits(hw, 0, (u16)(eeprom->address_bits - 2));
 
     return E1000_SUCCESS;
 }
@@ -5523,18 +5523,18 @@ e1000_write_eeprom_microwire(struct e1000_hw *hw,
  * data - word read from the EEPROM
  * words - number of words to read
  *****************************************************************************/
-static int32_t
+static s32
 e1000_commit_shadow_ram(struct e1000_hw *hw)
 {
-    uint32_t attempts = 100000;
-    uint32_t eecd = 0;
-    uint32_t flop = 0;
-    uint32_t i = 0;
-    int32_t error = E1000_SUCCESS;
-    uint32_t old_bank_offset = 0;
-    uint32_t new_bank_offset = 0;
-    uint8_t low_byte = 0;
-    uint8_t high_byte = 0;
+    u32 attempts = 100000;
+    u32 eecd = 0;
+    u32 flop = 0;
+    u32 i = 0;
+    s32 error = E1000_SUCCESS;
+    u32 old_bank_offset = 0;
+    u32 new_bank_offset = 0;
+    u8 low_byte = 0;
+    u8 high_byte = 0;
     bool sector_write_failed = false;
 
     if (hw->mac_type == e1000_82573) {
@@ -5595,7 +5595,7 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
              * in the other NVM bank or a modified value stored
              * in the shadow RAM */
             if (hw->eeprom_shadow_ram[i].modified) {
-                low_byte = (uint8_t)hw->eeprom_shadow_ram[i].eeprom_word;
+                low_byte = (u8)hw->eeprom_shadow_ram[i].eeprom_word;
                 udelay(100);
                 error = e1000_verify_write_ich8_byte(hw,
                             (i << 1) + new_bank_offset, low_byte);
@@ -5604,7 +5604,7 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
                     sector_write_failed = true;
                 else {
                     high_byte =
-                        (uint8_t)(hw->eeprom_shadow_ram[i].eeprom_word >> 8);
+                        (u8)(hw->eeprom_shadow_ram[i].eeprom_word >> 8);
                     udelay(100);
                 }
             } else {
@@ -5687,11 +5687,11 @@ e1000_commit_shadow_ram(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+s32
 e1000_read_mac_addr(struct e1000_hw * hw)
 {
-    uint16_t offset;
-    uint16_t eeprom_data, i;
+    u16 offset;
+    u16 eeprom_data, i;
 
     DEBUGFUNC("e1000_read_mac_addr");
 
@@ -5701,8 +5701,8 @@ e1000_read_mac_addr(struct e1000_hw * hw)
             DEBUGOUT("EEPROM Read Error\n");
             return -E1000_ERR_EEPROM;
         }
-        hw->perm_mac_addr[i] = (uint8_t) (eeprom_data & 0x00FF);
-        hw->perm_mac_addr[i+1] = (uint8_t) (eeprom_data >> 8);
+        hw->perm_mac_addr[i] = (u8) (eeprom_data & 0x00FF);
+        hw->perm_mac_addr[i+1] = (u8) (eeprom_data >> 8);
     }
 
     switch (hw->mac_type) {
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
-                   uint8_t *mc_addr)
+                   u8 *mc_addr)
 {
-    uint32_t hash_value = 0;
+    u32 hash_value = 0;
 
     /* The portion of the address that is used for the hash table is
      * determined by the mc_filter_type setting.
@@ -5787,37 +5787,37 @@ e1000_hash_mc_addr(struct e1000_hw *hw,
     case 0:
         if (hw->mac_type == e1000_ich8lan) {
             /* [47:38] i.e. 0x158 for above example address */
-            hash_value = ((mc_addr[4] >> 6) | (((uint16_t) mc_addr[5]) << 2));
+            hash_value = ((mc_addr[4] >> 6) | (((u16) mc_addr[5]) << 2));
         } else {
             /* [47:36] i.e. 0x563 for above example address */
-            hash_value = ((mc_addr[4] >> 4) | (((uint16_t) mc_addr[5]) << 4));
+            hash_value = ((mc_addr[4] >> 4) | (((u16) mc_addr[5]) << 4));
         }
         break;
     case 1:
         if (hw->mac_type == e1000_ich8lan) {
             /* [46:37] i.e. 0x2B1 for above example address */
-            hash_value = ((mc_addr[4] >> 5) | (((uint16_t) mc_addr[5]) << 3));
+            hash_value = ((mc_addr[4] >> 5) | (((u16) mc_addr[5]) << 3));
         } else {
             /* [46:35] i.e. 0xAC6 for above example address */
-            hash_value = ((mc_addr[4] >> 3) | (((uint16_t) mc_addr[5]) << 5));
+            hash_value = ((mc_addr[4] >> 3) | (((u16) mc_addr[5]) << 5));
         }
         break;
     case 2:
         if (hw->mac_type == e1000_ich8lan) {
             /*[45:36] i.e. 0x163 for above example address */
-            hash_value = ((mc_addr[4] >> 4) | (((uint16_t) mc_addr[5]) << 4));
+            hash_value = ((mc_addr[4] >> 4) | (((u16) mc_addr[5]) << 4));
         } else {
             /* [45:34] i.e. 0x5D8 for above example address */
-            hash_value = ((mc_addr[4] >> 2) | (((uint16_t) mc_addr[5]) << 6));
+            hash_value = ((mc_addr[4] >> 2) | (((u16) mc_addr[5]) << 6));
         }
         break;
     case 3:
         if (hw->mac_type == e1000_ich8lan) {
             /* [43:34] i.e. 0x18D for above example address */
-            hash_value = ((mc_addr[4] >> 2) | (((uint16_t) mc_addr[5]) << 6));
+            hash_value = ((mc_addr[4] >> 2) | (((u16) mc_addr[5]) << 6));
         } else {
             /* [43:32] i.e. 0x634 for above example address */
-            hash_value = ((mc_addr[4]) | (((uint16_t) mc_addr[5]) << 8));
+            hash_value = ((mc_addr[4]) | (((u16) mc_addr[5]) << 8));
         }
         break;
     }
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
@@ -5886,18 +5886,18 @@ e1000_mta_set(struct e1000_hw *hw,
  *****************************************************************************/
 void
 e1000_rar_set(struct e1000_hw *hw,
-              uint8_t *addr,
-              uint32_t index)
+              u8 *addr,
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
@@ -6003,15 +6003,15 @@ e1000_clear_vfta(struct e1000_hw *hw)
     }
 }
 
-static int32_t
+static s32
 e1000_id_led_init(struct e1000_hw * hw)
 {
-    uint32_t ledctl;
-    const uint32_t ledctl_mask = 0x000000FF;
-    const uint32_t ledctl_on = E1000_LEDCTL_MODE_LED_ON;
-    const uint32_t ledctl_off = E1000_LEDCTL_MODE_LED_OFF;
-    uint16_t eeprom_data, i, temp;
-    const uint16_t led_mask = 0x0F;
+    u32 ledctl;
+    const u32 ledctl_mask = 0x000000FF;
+    const u32 ledctl_on = E1000_LEDCTL_MODE_LED_ON;
+    const u32 ledctl_off = E1000_LEDCTL_MODE_LED_OFF;
+    u16 eeprom_data, i, temp;
+    const u16 led_mask = 0x0F;
 
     DEBUGFUNC("e1000_id_led_init");
 
@@ -6086,11 +6086,11 @@ e1000_id_led_init(struct e1000_hw * hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+s32
 e1000_setup_led(struct e1000_hw *hw)
 {
-    uint32_t ledctl;
-    int32_t ret_val = E1000_SUCCESS;
+    u32 ledctl;
+    s32 ret_val = E1000_SUCCESS;
 
     DEBUGFUNC("e1000_setup_led");
 
@@ -6111,7 +6111,7 @@ e1000_setup_led(struct e1000_hw *hw)
         if (ret_val)
             return ret_val;
         ret_val = e1000_write_phy_reg(hw, IGP01E1000_GMII_FIFO,
-                                      (uint16_t)(hw->phy_spd_default &
+                                      (u16)(hw->phy_spd_default &
                                       ~IGP01E1000_GMII_SPD));
         if (ret_val)
             return ret_val;
@@ -6145,11 +6145,11 @@ e1000_setup_led(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+s32
 e1000_blink_led_start(struct e1000_hw *hw)
 {
-    int16_t  i;
-    uint32_t ledctl_blink = 0;
+    s16  i;
+    u32 ledctl_blink = 0;
 
     DEBUGFUNC("e1000_id_led_blink_on");
 
@@ -6180,10 +6180,10 @@ e1000_blink_led_start(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+s32
 e1000_cleanup_led(struct e1000_hw *hw)
 {
-    int32_t ret_val = E1000_SUCCESS;
+    s32 ret_val = E1000_SUCCESS;
 
     DEBUGFUNC("e1000_cleanup_led");
 
@@ -6222,10 +6222,10 @@ e1000_cleanup_led(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+s32
 e1000_led_on(struct e1000_hw *hw)
 {
-    uint32_t ctrl = E1000_READ_REG(hw, CTRL);
+    u32 ctrl = E1000_READ_REG(hw, CTRL);
 
     DEBUGFUNC("e1000_led_on");
 
@@ -6273,10 +6273,10 @@ e1000_led_on(struct e1000_hw *hw)
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-int32_t
+s32
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
@@ -6495,10 +6495,10 @@ e1000_update_adaptive(struct e1000_hw *hw)
 void
 e1000_tbi_adjust_stats(struct e1000_hw *hw,
                        struct e1000_hw_stats *stats,
-                       uint32_t frame_len,
-                       uint8_t *mac_addr)
+                       u32 frame_len,
+                       u8 *mac_addr)
 {
-    uint64_t carry_bit;
+    u64 carry_bit;
 
     /* First adjust the frame length. */
     frame_len--;
@@ -6527,7 +6527,7 @@ e1000_tbi_adjust_stats(struct e1000_hw *hw,
      * since the test for a multicast frame will test positive on
      * a broadcast frame.
      */
-    if ((mac_addr[0] == (uint8_t) 0xff) && (mac_addr[1] == (uint8_t) 0xff))
+    if ((mac_addr[0] == (u8) 0xff) && (mac_addr[1] == (u8) 0xff))
         /* Broadcast packet */
         stats->bprc++;
     else if (*mac_addr & 0x01)
@@ -6573,9 +6573,9 @@ e1000_tbi_adjust_stats(struct e1000_hw *hw,
 void
 e1000_get_bus_info(struct e1000_hw *hw)
 {
-    int32_t ret_val;
-    uint16_t pci_ex_link_status;
-    uint32_t status;
+    s32 ret_val;
+    u16 pci_ex_link_status;
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
@@ -6672,15 +6672,15 @@ e1000_write_reg_io(struct e1000_hw *hw,
  * register to the minimum and maximum range.
  * For IGP phy's, the function calculates the range by the AGC registers.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_get_cable_length(struct e1000_hw *hw,
-                       uint16_t *min_length,
-                       uint16_t *max_length)
+                       u16 *min_length,
+                       u16 *max_length)
 {
-    int32_t ret_val;
-    uint16_t agc_value = 0;
-    uint16_t i, phy_data;
-    uint16_t cable_length;
+    s32 ret_val;
+    u16 agc_value = 0;
+    u16 i, phy_data;
+    u16 cable_length;
 
     DEBUGFUNC("e1000_get_cable_length");
 
@@ -6751,9 +6751,9 @@ e1000_get_cable_length(struct e1000_hw *hw,
             break;
         }
     } else if (hw->phy_type == e1000_phy_igp) { /* For IGP PHY */
-        uint16_t cur_agc_value;
-        uint16_t min_agc_value = IGP01E1000_AGC_LENGTH_TABLE_SIZE;
-        uint16_t agc_reg_array[IGP01E1000_PHY_CHANNEL_NUM] =
+        u16 cur_agc_value;
+        u16 min_agc_value = IGP01E1000_AGC_LENGTH_TABLE_SIZE;
+        u16 agc_reg_array[IGP01E1000_PHY_CHANNEL_NUM] =
                                                          {IGP01E1000_PHY_AGC_A,
                                                           IGP01E1000_PHY_AGC_B,
                                                           IGP01E1000_PHY_AGC_C,
@@ -6799,9 +6799,9 @@ e1000_get_cable_length(struct e1000_hw *hw,
                       IGP01E1000_AGC_RANGE;
     } else if (hw->phy_type == e1000_phy_igp_2 ||
                hw->phy_type == e1000_phy_igp_3) {
-        uint16_t cur_agc_index, max_agc_index = 0;
-        uint16_t min_agc_index = IGP02E1000_AGC_LENGTH_TABLE_SIZE - 1;
-        uint16_t agc_reg_array[IGP02E1000_PHY_CHANNEL_NUM] =
+        u16 cur_agc_index, max_agc_index = 0;
+        u16 min_agc_index = IGP02E1000_AGC_LENGTH_TABLE_SIZE - 1;
+        u16 agc_reg_array[IGP02E1000_PHY_CHANNEL_NUM] =
                                                          {IGP02E1000_PHY_AGC_A,
                                                           IGP02E1000_PHY_AGC_B,
                                                           IGP02E1000_PHY_AGC_C,
@@ -6863,12 +6863,12 @@ e1000_get_cable_length(struct e1000_hw *hw,
  * return 0.  If the link speed is 1000 Mbps the polarity status is in the
  * IGP01E1000_PHY_PCS_INIT_REG.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_check_polarity(struct e1000_hw *hw,
                      e1000_rev_polarity *polarity)
 {
-    int32_t ret_val;
-    uint16_t phy_data;
+    s32 ret_val;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_check_polarity");
 
@@ -6939,11 +6939,11 @@ e1000_check_polarity(struct e1000_hw *hw,
  * Link Health register.  In IGP this bit is latched high, so the driver must
  * read it immediately after link is established.
  *****************************************************************************/
-static int32_t
+static s32
 e1000_check_downshift(struct e1000_hw *hw)
 {
-    int32_t ret_val;
-    uint16_t phy_data;
+    s32 ret_val;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_check_downshift");
 
@@ -6985,18 +6985,18 @@ e1000_check_downshift(struct e1000_hw *hw)
  *
  ****************************************************************************/
 
-static int32_t
+static s32
 e1000_config_dsp_after_link_change(struct e1000_hw *hw,
                                    bool link_up)
 {
-    int32_t ret_val;
-    uint16_t phy_data, phy_saved_data, speed, duplex, i;
-    uint16_t dsp_reg_array[IGP01E1000_PHY_CHANNEL_NUM] =
+    s32 ret_val;
+    u16 phy_data, phy_saved_data, speed, duplex, i;
+    u16 dsp_reg_array[IGP01E1000_PHY_CHANNEL_NUM] =
                                         {IGP01E1000_PHY_AGC_PARAM_A,
                                         IGP01E1000_PHY_AGC_PARAM_B,
                                         IGP01E1000_PHY_AGC_PARAM_C,
                                         IGP01E1000_PHY_AGC_PARAM_D};
-    uint16_t min_length, max_length;
+    u16 min_length, max_length;
 
     DEBUGFUNC("e1000_config_dsp_after_link_change");
 
@@ -7038,8 +7038,8 @@ e1000_config_dsp_after_link_change(struct e1000_hw *hw,
             if ((hw->ffe_config_state == e1000_ffe_config_enabled) &&
                (min_length < e1000_igp_cable_length_50)) {
 
-                uint16_t ffe_idle_err_timeout = FFE_IDLE_ERR_COUNT_TIMEOUT_20;
-                uint32_t idle_errs = 0;
+                u16 ffe_idle_err_timeout = FFE_IDLE_ERR_COUNT_TIMEOUT_20;
+                u32 idle_errs = 0;
 
                 /* clear previous idle error counts */
                 ret_val = e1000_read_phy_reg(hw, PHY_1000T_STATUS,
@@ -7173,11 +7173,11 @@ e1000_config_dsp_after_link_change(struct e1000_hw *hw,
  *
  * hw - Struct containing variables accessed by shared code
  ****************************************************************************/
-static int32_t
+static s32
 e1000_set_phy_mode(struct e1000_hw *hw)
 {
-    int32_t ret_val;
-    uint16_t eeprom_data;
+    s32 ret_val;
+    u16 eeprom_data;
 
     DEBUGFUNC("e1000_set_phy_mode");
 
@@ -7218,13 +7218,13 @@ e1000_set_phy_mode(struct e1000_hw *hw)
  *
  ****************************************************************************/
 
-static int32_t
+static s32
 e1000_set_d3_lplu_state(struct e1000_hw *hw,
                         bool active)
 {
-    uint32_t phy_ctrl = 0;
-    int32_t ret_val;
-    uint16_t phy_data;
+    u32 phy_ctrl = 0;
+    s32 ret_val;
+    u16 phy_data;
     DEBUGFUNC("e1000_set_d3_lplu_state");
 
     if (hw->phy_type != e1000_phy_igp && hw->phy_type != e1000_phy_igp_2
@@ -7348,13 +7348,13 @@ e1000_set_d3_lplu_state(struct e1000_hw *hw,
  *
  ****************************************************************************/
 
-static int32_t
+static s32
 e1000_set_d0_lplu_state(struct e1000_hw *hw,
                         bool active)
 {
-    uint32_t phy_ctrl = 0;
-    int32_t ret_val;
-    uint16_t phy_data;
+    u32 phy_ctrl = 0;
+    s32 ret_val;
+    u16 phy_data;
     DEBUGFUNC("e1000_set_d0_lplu_state");
 
     if (hw->mac_type <= e1000_82547_rev_2)
@@ -7439,12 +7439,12 @@ e1000_set_d0_lplu_state(struct e1000_hw *hw,
  *
  * hw - Struct containing variables accessed by shared code
  *****************************************************************************/
-static int32_t
+static s32
 e1000_set_vco_speed(struct e1000_hw *hw)
 {
-    int32_t  ret_val;
-    uint16_t default_page = 0;
-    uint16_t phy_data;
+    s32  ret_val;
+    u16 default_page = 0;
+    u16 phy_data;
 
     DEBUGFUNC("e1000_set_vco_speed");
 
@@ -7503,18 +7503,18 @@ e1000_set_vco_speed(struct e1000_hw *hw)
  *
  * returns: - E1000_SUCCESS .
  ****************************************************************************/
-static int32_t
-e1000_host_if_read_cookie(struct e1000_hw * hw, uint8_t *buffer)
+static s32
+e1000_host_if_read_cookie(struct e1000_hw * hw, u8 *buffer)
 {
-    uint8_t i;
-    uint32_t offset = E1000_MNG_DHCP_COOKIE_OFFSET;
-    uint8_t length = E1000_MNG_DHCP_COOKIE_LENGTH;
+    u8 i;
+    u32 offset = E1000_MNG_DHCP_COOKIE_OFFSET;
+    u8 length = E1000_MNG_DHCP_COOKIE_LENGTH;
 
     length = (length >> 2);
     offset = (offset >> 2);
 
     for (i = 0; i < length; i++) {
-        *((uint32_t *) buffer + i) =
+        *((u32 *) buffer + i) =
             E1000_READ_REG_ARRAY_DWORD(hw, HOST_IF, offset + i);
     }
     return E1000_SUCCESS;
@@ -7530,11 +7530,11 @@ e1000_host_if_read_cookie(struct e1000_hw * hw, uint8_t *buffer)
  *            timeout
  *          - E1000_SUCCESS for success.
  ****************************************************************************/
-static int32_t
+static s32
 e1000_mng_enable_host_if(struct e1000_hw * hw)
 {
-    uint32_t hicr;
-    uint8_t i;
+    u32 hicr;
+    u8 i;
 
     /* Check that the host interface is enabled. */
     hicr = E1000_READ_REG(hw, HICR);
@@ -7564,14 +7564,14 @@ e1000_mng_enable_host_if(struct e1000_hw * hw)
  *
  * returns  - E1000_SUCCESS for success.
  ****************************************************************************/
-static int32_t
-e1000_mng_host_if_write(struct e1000_hw * hw, uint8_t *buffer,
-                        uint16_t length, uint16_t offset, uint8_t *sum)
+static s32
+e1000_mng_host_if_write(struct e1000_hw * hw, u8 *buffer,
+                        u16 length, u16 offset, u8 *sum)
 {
-    uint8_t *tmp;
-    uint8_t *bufptr = buffer;
-    uint32_t data = 0;
-    uint16_t remaining, i, j, prev_bytes;
+    u8 *tmp;
+    u8 *bufptr = buffer;
+    u32 data = 0;
+    u16 remaining, i, j, prev_bytes;
 
     /* sum = only sum of the data and it is not checksum */
 
@@ -7579,14 +7579,14 @@ e1000_mng_host_if_write(struct e1000_hw * hw, uint8_t *buffer,
         return -E1000_ERR_PARAM;
     }
 
-    tmp = (uint8_t *)&data;
+    tmp = (u8 *)&data;
     prev_bytes = offset & 0x3;
     offset &= 0xFFFC;
     offset >>= 2;
 
     if (prev_bytes) {
         data = E1000_READ_REG_ARRAY_DWORD(hw, HOST_IF, offset);
-        for (j = prev_bytes; j < sizeof(uint32_t); j++) {
+        for (j = prev_bytes; j < sizeof(u32); j++) {
             *(tmp + j) = *bufptr++;
             *sum += *(tmp + j);
         }
@@ -7604,7 +7604,7 @@ e1000_mng_host_if_write(struct e1000_hw * hw, uint8_t *buffer,
     /* The device driver writes the relevant command block into the
      * ram area. */
     for (i = 0; i < length; i++) {
-        for (j = 0; j < sizeof(uint32_t); j++) {
+        for (j = 0; j < sizeof(u32); j++) {
             *(tmp + j) = *bufptr++;
             *sum += *(tmp + j);
         }
@@ -7612,7 +7612,7 @@ e1000_mng_host_if_write(struct e1000_hw * hw, uint8_t *buffer,
         E1000_WRITE_REG_ARRAY_DWORD(hw, HOST_IF, offset + i, data);
     }
     if (remaining) {
-        for (j = 0; j < sizeof(uint32_t); j++) {
+        for (j = 0; j < sizeof(u32); j++) {
             if (j < remaining)
                 *(tmp + j) = *bufptr++;
             else
@@ -7632,23 +7632,23 @@ e1000_mng_host_if_write(struct e1000_hw * hw, uint8_t *buffer,
  *
  * returns  - E1000_SUCCESS for success.
  ****************************************************************************/
-static int32_t
+static s32
 e1000_mng_write_cmd_header(struct e1000_hw * hw,
                            struct e1000_host_mng_command_header * hdr)
 {
-    uint16_t i;
-    uint8_t sum;
-    uint8_t *buffer;
+    u16 i;
+    u8 sum;
+    u8 *buffer;
 
     /* Write the whole command header structure which includes sum of
      * the buffer */
 
-    uint16_t length = sizeof(struct e1000_host_mng_command_header);
+    u16 length = sizeof(struct e1000_host_mng_command_header);
 
     sum = hdr->checksum;
     hdr->checksum = 0;
 
-    buffer = (uint8_t *) hdr;
+    buffer = (u8 *) hdr;
     i = length;
     while (i--)
         sum += buffer[i];
@@ -7658,7 +7658,7 @@ e1000_mng_write_cmd_header(struct e1000_hw * hw,
     length >>= 2;
     /* The device driver writes the relevant command block into the ram area. */
     for (i = 0; i < length; i++) {
-        E1000_WRITE_REG_ARRAY_DWORD(hw, HOST_IF, i, *((uint32_t *) hdr + i));
+        E1000_WRITE_REG_ARRAY_DWORD(hw, HOST_IF, i, *((u32 *) hdr + i));
         E1000_WRITE_FLUSH(hw);
     }
 
@@ -7672,10 +7672,10 @@ e1000_mng_write_cmd_header(struct e1000_hw * hw,
  *
  * returns  - E1000_SUCCESS for success.
  ****************************************************************************/
-static int32_t
+static s32
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
 
@@ -7712,11 +7712,11 @@ e1000_check_mng_mode(struct e1000_hw *hw)
 /*****************************************************************************
  * This function writes the dhcp info .
  ****************************************************************************/
-int32_t
-e1000_mng_write_dhcp_info(struct e1000_hw * hw, uint8_t *buffer,
-                          uint16_t length)
+s32
+e1000_mng_write_dhcp_info(struct e1000_hw * hw, u8 *buffer,
+                          u16 length)
 {
-    int32_t ret_val;
+    s32 ret_val;
     struct e1000_host_mng_command_header hdr;
 
     hdr.command_id = E1000_MNG_DHCP_TX_PAYLOAD_CMD;
@@ -7744,11 +7744,11 @@ e1000_mng_write_dhcp_info(struct e1000_hw * hw, uint8_t *buffer,
  *
  * returns  - checksum of buffer contents.
  ****************************************************************************/
-static uint8_t
-e1000_calculate_mng_checksum(char *buffer, uint32_t length)
+static u8
+e1000_calculate_mng_checksum(char *buffer, u32 length)
 {
-    uint8_t sum = 0;
-    uint32_t i;
+    u8 sum = 0;
+    u32 i;
 
     if (!buffer)
         return 0;
@@ -7756,7 +7756,7 @@ e1000_calculate_mng_checksum(char *buffer, uint32_t length)
     for (i=0; i < length; i++)
         sum += buffer[i];
 
-    return (uint8_t) (0 - sum);
+    return (u8) (0 - sum);
 }
 
 /*****************************************************************************
@@ -7769,10 +7769,10 @@ e1000_enable_tx_pkt_filtering(struct e1000_hw *hw)
 {
     /* called in init as well as watchdog timer functions */
 
-    int32_t ret_val, checksum;
+    s32 ret_val, checksum;
     bool tx_filter = false;
     struct e1000_host_mng_dhcp_cookie *hdr = &(hw->mng_cookie);
-    uint8_t *buffer = (uint8_t *) &(hw->mng_cookie);
+    u8 *buffer = (u8 *) &(hw->mng_cookie);
 
     if (e1000_check_mng_mode(hw)) {
         ret_val = e1000_mng_enable_host_if(hw);
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
@@ -7832,12 +7832,12 @@ e1000_enable_mng_pass_thru(struct e1000_hw *hw)
     return false;
 }
 
-static int32_t
+static s32
 e1000_polarity_reversal_workaround(struct e1000_hw *hw)
 {
-    int32_t ret_val;
-    uint16_t mii_status_reg;
-    uint16_t i;
+    s32 ret_val;
+    u16 mii_status_reg;
+    u16 i;
 
     /* Polarity reversal workaround for forced 10F/10H links. */
 
@@ -7929,7 +7929,7 @@ e1000_polarity_reversal_workaround(struct e1000_hw *hw)
 static void
 e1000_set_pci_express_master_disable(struct e1000_hw *hw)
 {
-    uint32_t ctrl;
+    u32 ctrl;
 
     DEBUGFUNC("e1000_set_pci_express_master_disable");
 
@@ -7952,10 +7952,10 @@ e1000_set_pci_express_master_disable(struct e1000_hw *hw)
  *            E1000_SUCCESS master requests disabled.
  *
  ******************************************************************************/
-int32_t
+s32
 e1000_disable_pciex_master(struct e1000_hw *hw)
 {
-    int32_t timeout = MASTER_DISABLE_TIMEOUT;   /* 80ms */
+    s32 timeout = MASTER_DISABLE_TIMEOUT;   /* 80ms */
 
     DEBUGFUNC("e1000_disable_pciex_master");
 
@@ -7990,10 +7990,10 @@ e1000_disable_pciex_master(struct e1000_hw *hw)
  *            E1000_SUCCESS at any other case.
  *
  ******************************************************************************/
-static int32_t
+static s32
 e1000_get_auto_rd_done(struct e1000_hw *hw)
 {
-    int32_t timeout = AUTO_READ_DONE_TIMEOUT;
+    s32 timeout = AUTO_READ_DONE_TIMEOUT;
 
     DEBUGFUNC("e1000_get_auto_rd_done");
 
@@ -8038,11 +8038,11 @@ e1000_get_auto_rd_done(struct e1000_hw *hw)
  *            E1000_SUCCESS at any other case.
  *
  ***************************************************************************/
-static int32_t
+static s32
 e1000_get_phy_cfg_done(struct e1000_hw *hw)
 {
-    int32_t timeout = PHY_CFG_TIMEOUT;
-    uint32_t cfg_mask = E1000_EEPROM_CFG_DONE;
+    s32 timeout = PHY_CFG_TIMEOUT;
+    u32 cfg_mask = E1000_EEPROM_CFG_DONE;
 
     DEBUGFUNC("e1000_get_phy_cfg_done");
 
@@ -8085,11 +8085,11 @@ e1000_get_phy_cfg_done(struct e1000_hw *hw)
  *            E1000_SUCCESS at any other case.
  *
  ***************************************************************************/
-static int32_t
+static s32
 e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw)
 {
-    int32_t timeout;
-    uint32_t swsm;
+    s32 timeout;
+    u32 swsm;
 
     DEBUGFUNC("e1000_get_hw_eeprom_semaphore");
 
@@ -8138,7 +8138,7 @@ e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw)
 static void
 e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw)
 {
-    uint32_t swsm;
+    u32 swsm;
 
     DEBUGFUNC("e1000_put_hw_eeprom_semaphore");
 
@@ -8164,11 +8164,11 @@ e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw)
  *            E1000_SUCCESS at any other case.
  *
  ***************************************************************************/
-static int32_t
+static s32
 e1000_get_software_semaphore(struct e1000_hw *hw)
 {
-    int32_t timeout = hw->eeprom.word_size + 1;
-    uint32_t swsm;
+    s32 timeout = hw->eeprom.word_size + 1;
+    u32 swsm;
 
     DEBUGFUNC("e1000_get_software_semaphore");
 
@@ -8203,7 +8203,7 @@ e1000_get_software_semaphore(struct e1000_hw *hw)
 static void
 e1000_release_software_semaphore(struct e1000_hw *hw)
 {
-    uint32_t swsm;
+    u32 swsm;
 
     DEBUGFUNC("e1000_release_software_semaphore");
 
@@ -8228,11 +8228,11 @@ e1000_release_software_semaphore(struct e1000_hw *hw)
  *            E1000_SUCCESS
  *
  *****************************************************************************/
-int32_t
+s32
 e1000_check_phy_reset_block(struct e1000_hw *hw)
 {
-    uint32_t manc = 0;
-    uint32_t fwsm = 0;
+    u32 manc = 0;
+    u32 fwsm = 0;
 
     if (hw->mac_type == e1000_ich8lan) {
         fwsm = E1000_READ_REG(hw, FWSM);
@@ -8246,10 +8246,10 @@ e1000_check_phy_reset_block(struct e1000_hw *hw)
         E1000_BLK_PHY_RESET : E1000_SUCCESS;
 }
 
-static uint8_t
+static u8
 e1000_arc_subsystem_valid(struct e1000_hw *hw)
 {
-    uint32_t fwsm;
+    u32 fwsm;
 
     /* On 8257x silicon, registers in the range of 0x8800 - 0x8FFC
      * may not be provided a DMA clock when no manageability features are
@@ -8283,10 +8283,10 @@ e1000_arc_subsystem_valid(struct e1000_hw *hw)
  * returns: E1000_SUCCESS
  *
  *****************************************************************************/
-static int32_t
-e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, uint32_t no_snoop)
+static s32
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
 
@@ -8324,11 +8324,11 @@ e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, uint32_t no_snoop)
  * hw: Struct containing variables accessed by shared code
  *
  ***************************************************************************/
-static int32_t
+static s32
 e1000_get_software_flag(struct e1000_hw *hw)
 {
-    int32_t timeout = PHY_CFG_TIMEOUT;
-    uint32_t extcnf_ctrl;
+    s32 timeout = PHY_CFG_TIMEOUT;
+    u32 extcnf_ctrl;
 
     DEBUGFUNC("e1000_get_software_flag");
 
@@ -8366,7 +8366,7 @@ e1000_get_software_flag(struct e1000_hw *hw)
 static void
 e1000_release_software_flag(struct e1000_hw *hw)
 {
-    uint32_t extcnf_ctrl;
+    u32 extcnf_ctrl;
 
     DEBUGFUNC("e1000_release_software_flag");
 
@@ -8388,16 +8388,16 @@ e1000_release_software_flag(struct e1000_hw *hw)
  * data - word read from the EEPROM
  * words - number of words to read
  *****************************************************************************/
-static int32_t
-e1000_read_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words,
-                       uint16_t *data)
+static s32
+e1000_read_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
+                       u16 *data)
 {
-    int32_t  error = E1000_SUCCESS;
-    uint32_t flash_bank = 0;
-    uint32_t act_offset = 0;
-    uint32_t bank_offset = 0;
-    uint16_t word = 0;
-    uint16_t i = 0;
+    s32  error = E1000_SUCCESS;
+    u32 flash_bank = 0;
+    u32 act_offset = 0;
+    u32 bank_offset = 0;
+    u16 word = 0;
+    u16 i = 0;
 
     /* We need to know which is the valid flash bank.  In the event
      * that we didn't allocate eeprom_shadow_ram, we may not be
@@ -8444,12 +8444,12 @@ e1000_read_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words,
  * words - number of words to write
  * data - words to write to the EEPROM
  *****************************************************************************/
-static int32_t
-e1000_write_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words,
-                        uint16_t *data)
+static s32
+e1000_write_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
+                        u16 *data)
 {
-    uint32_t i = 0;
-    int32_t error = E1000_SUCCESS;
+    u32 i = 0;
+    s32 error = E1000_SUCCESS;
 
     error = e1000_get_software_flag(hw);
     if (error != E1000_SUCCESS)
@@ -8491,12 +8491,12 @@ e1000_write_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words,
  *
  * hw - The pointer to the hw structure
  ****************************************************************************/
-static int32_t
+static s32
 e1000_ich8_cycle_init(struct e1000_hw *hw)
 {
     union ich8_hws_flash_status hsfsts;
-    int32_t error = E1000_ERR_EEPROM;
-    int32_t i     = 0;
+    s32 error = E1000_ERR_EEPROM;
+    s32 i     = 0;
 
     DEBUGFUNC("e1000_ich8_cycle_init");
 
@@ -8558,13 +8558,13 @@ e1000_ich8_cycle_init(struct e1000_hw *hw)
  *
  * hw - The pointer to the hw structure
  ****************************************************************************/
-static int32_t
-e1000_ich8_flash_cycle(struct e1000_hw *hw, uint32_t timeout)
+static s32
+e1000_ich8_flash_cycle(struct e1000_hw *hw, u32 timeout)
 {
     union ich8_hws_flash_ctrl hsflctl;
     union ich8_hws_flash_status hsfsts;
-    int32_t error = E1000_ERR_EEPROM;
-    uint32_t i = 0;
+    s32 error = E1000_ERR_EEPROM;
+    u32 i = 0;
 
     /* Start a cycle by writing 1 in Flash Cycle Go in Hw Flash Control */
     hsflctl.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFCTL);
@@ -8593,16 +8593,16 @@ e1000_ich8_flash_cycle(struct e1000_hw *hw, uint32_t timeout)
  * size - Size of data to read, 1=byte 2=word
  * data - Pointer to the word to store the value read.
  *****************************************************************************/
-static int32_t
-e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index,
-                     uint32_t size, uint16_t* data)
+static s32
+e1000_read_ich8_data(struct e1000_hw *hw, u32 index,
+                     u32 size, u16* data)
 {
     union ich8_hws_flash_status hsfsts;
     union ich8_hws_flash_ctrl hsflctl;
-    uint32_t flash_linear_address;
-    uint32_t flash_data = 0;
-    int32_t error = -E1000_ERR_EEPROM;
-    int32_t count = 0;
+    u32 flash_linear_address;
+    u32 flash_data = 0;
+    s32 error = -E1000_ERR_EEPROM;
+    s32 count = 0;
 
     DEBUGFUNC("e1000_read_ich8_data");
 
@@ -8640,9 +8640,9 @@ e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index,
         if (error == E1000_SUCCESS) {
             flash_data = E1000_READ_ICH_FLASH_REG(hw, ICH_FLASH_FDATA0);
             if (size == 1) {
-                *data = (uint8_t)(flash_data & 0x000000FF);
+                *data = (u8)(flash_data & 0x000000FF);
             } else if (size == 2) {
-                *data = (uint16_t)(flash_data & 0x0000FFFF);
+                *data = (u16)(flash_data & 0x0000FFFF);
             }
             break;
         } else {
@@ -8672,16 +8672,16 @@ e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index,
  * size - Size of data to read, 1=byte 2=word
  * data - The byte(s) to write to the NVM.
  *****************************************************************************/
-static int32_t
-e1000_write_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size,
-                      uint16_t data)
+static s32
+e1000_write_ich8_data(struct e1000_hw *hw, u32 index, u32 size,
+                      u16 data)
 {
     union ich8_hws_flash_status hsfsts;
     union ich8_hws_flash_ctrl hsflctl;
-    uint32_t flash_linear_address;
-    uint32_t flash_data = 0;
-    int32_t error = -E1000_ERR_EEPROM;
-    int32_t count = 0;
+    u32 flash_linear_address;
+    u32 flash_data = 0;
+    s32 error = -E1000_ERR_EEPROM;
+    s32 count = 0;
 
     DEBUGFUNC("e1000_write_ich8_data");
 
@@ -8710,9 +8710,9 @@ e1000_write_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size,
         E1000_WRITE_ICH_FLASH_REG(hw, ICH_FLASH_FADDR, flash_linear_address);
 
         if (size == 1)
-            flash_data = (uint32_t)data & 0x00FF;
+            flash_data = (u32)data & 0x00FF;
         else
-            flash_data = (uint32_t)data;
+            flash_data = (u32)data;
 
         E1000_WRITE_ICH_FLASH_REG(hw, ICH_FLASH_FDATA0, flash_data);
 
@@ -8747,15 +8747,15 @@ e1000_write_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size,
  * index - The index of the byte to read.
  * data - Pointer to a byte to store the value read.
  *****************************************************************************/
-static int32_t
-e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t* data)
+static s32
+e1000_read_ich8_byte(struct e1000_hw *hw, u32 index, u8* data)
 {
-    int32_t status = E1000_SUCCESS;
-    uint16_t word = 0;
+    s32 status = E1000_SUCCESS;
+    u16 word = 0;
 
     status = e1000_read_ich8_data(hw, index, 1, &word);
     if (status == E1000_SUCCESS) {
-        *data = (uint8_t)word;
+        *data = (u8)word;
     }
 
     return status;
@@ -8770,11 +8770,11 @@ e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t* data)
  * index - The index of the byte to write.
  * byte - The byte to write to the NVM.
  *****************************************************************************/
-static int32_t
-e1000_verify_write_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t byte)
+static s32
+e1000_verify_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 byte)
 {
-    int32_t error = E1000_SUCCESS;
-    int32_t program_retries = 0;
+    s32 error = E1000_SUCCESS;
+    s32 program_retries = 0;
 
     DEBUGOUT2("Byte := %2.2X Offset := %d\n", byte, index);
 
@@ -8803,11 +8803,11 @@ e1000_verify_write_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t byte)
  * index - The index of the byte to read.
  * data - The byte to write to the NVM.
  *****************************************************************************/
-static int32_t
-e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t data)
+static s32
+e1000_write_ich8_byte(struct e1000_hw *hw, u32 index, u8 data)
 {
-    int32_t status = E1000_SUCCESS;
-    uint16_t word = (uint16_t)data;
+    s32 status = E1000_SUCCESS;
+    u16 word = (u16)data;
 
     status = e1000_write_ich8_data(hw, index, 1, word);
 
@@ -8821,10 +8821,10 @@ e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t data)
  * index - The starting byte index of the word to read.
  * data - Pointer to a word to store the value read.
  *****************************************************************************/
-static int32_t
-e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index, uint16_t *data)
+static s32
+e1000_read_ich8_word(struct e1000_hw *hw, u32 index, u16 *data)
 {
-    int32_t status = E1000_SUCCESS;
+    s32 status = E1000_SUCCESS;
     status = e1000_read_ich8_data(hw, index, 2, data);
     return status;
 }
@@ -8840,19 +8840,19 @@ e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index, uint16_t *data)
  * amount of NVM used in each bank is a *minimum* of 4 KBytes, but in fact the
  * bank size may be 4, 8 or 64 KBytes
  *****************************************************************************/
-static int32_t
-e1000_erase_ich8_4k_segment(struct e1000_hw *hw, uint32_t bank)
+static s32
+e1000_erase_ich8_4k_segment(struct e1000_hw *hw, u32 bank)
 {
     union ich8_hws_flash_status hsfsts;
     union ich8_hws_flash_ctrl hsflctl;
-    uint32_t flash_linear_address;
-    int32_t  count = 0;
-    int32_t  error = E1000_ERR_EEPROM;
-    int32_t  iteration;
-    int32_t  sub_sector_size = 0;
-    int32_t  bank_size;
-    int32_t  j = 0;
-    int32_t  error_flag = 0;
+    u32 flash_linear_address;
+    s32  count = 0;
+    s32  error = E1000_ERR_EEPROM;
+    s32  iteration;
+    s32  sub_sector_size = 0;
+    s32  bank_size;
+    s32  j = 0;
+    s32  error_flag = 0;
 
     hsfsts.regval = E1000_READ_ICH_FLASH_REG16(hw, ICH_FLASH_HSFSTS);
 
@@ -8930,16 +8930,16 @@ e1000_erase_ich8_4k_segment(struct e1000_hw *hw, uint32_t bank)
     return error;
 }
 
-static int32_t
+static s32
 e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw,
-                                      uint32_t cnf_base_addr, uint32_t cnf_size)
+                                      u32 cnf_base_addr, u32 cnf_size)
 {
-    uint32_t ret_val = E1000_SUCCESS;
-    uint16_t word_addr, reg_data, reg_addr;
-    uint16_t i;
+    u32 ret_val = E1000_SUCCESS;
+    u16 word_addr, reg_data, reg_addr;
+    u16 i;
 
     /* cnf_base_addr is in DWORD */
-    word_addr = (uint16_t)(cnf_base_addr << 1);
+    word_addr = (u16)(cnf_base_addr << 1);
 
     /* cnf_size is returned in size of dwords */
     for (i = 0; i < cnf_size; i++) {
@@ -8955,7 +8955,7 @@ e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw,
         if (ret_val != E1000_SUCCESS)
             return ret_val;
 
-        ret_val = e1000_write_phy_reg_ex(hw, (uint32_t)reg_addr, reg_data);
+        ret_val = e1000_write_phy_reg_ex(hw, (u32)reg_addr, reg_data);
 
         e1000_release_software_flag(hw);
     }
@@ -8972,10 +8972,10 @@ e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw,
  *
  * hw: Struct containing variables accessed by shared code
  *****************************************************************************/
-static int32_t
+static s32
 e1000_init_lcd_from_nvm(struct e1000_hw *hw)
 {
-    uint32_t reg_data, cnf_base_addr, cnf_size, ret_val, loop;
+    u32 reg_data, cnf_base_addr, cnf_size, ret_val, loop;
 
     if (hw->phy_type != e1000_phy_igp_3)
           return E1000_SUCCESS;
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index 572a7b6..99fce2c 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -100,7 +100,7 @@ typedef enum {
 } e1000_fc_type;
 
 struct e1000_shadow_ram {
-    uint16_t eeprom_word;
+    u16 eeprom_word;
     bool modified;
 };
 
@@ -263,17 +263,17 @@ struct e1000_phy_info {
 };
 
 struct e1000_phy_stats {
-    uint32_t idle_errors;
-    uint32_t receive_errors;
+    u32 idle_errors;
+    u32 receive_errors;
 };
 
 struct e1000_eeprom_info {
     e1000_eeprom_type type;
-    uint16_t word_size;
-    uint16_t opcode_bits;
-    uint16_t address_bits;
-    uint16_t delay_usec;
-    uint16_t page_size;
+    u16 word_size;
+    u16 opcode_bits;
+    u16 address_bits;
+    u16 delay_usec;
+    u16 page_size;
     bool use_eerd;
     bool use_eewr;
 };
@@ -308,34 +308,34 @@ typedef enum {
 
 /* Function prototypes */
 /* Initialization */
-int32_t e1000_reset_hw(struct e1000_hw *hw);
-int32_t e1000_init_hw(struct e1000_hw *hw);
-int32_t e1000_set_mac_type(struct e1000_hw *hw);
+s32 e1000_reset_hw(struct e1000_hw *hw);
+s32 e1000_init_hw(struct e1000_hw *hw);
+s32 e1000_set_mac_type(struct e1000_hw *hw);
 void e1000_set_media_type(struct e1000_hw *hw);
 
 /* Link Configuration */
-int32_t e1000_setup_link(struct e1000_hw *hw);
-int32_t e1000_phy_setup_autoneg(struct e1000_hw *hw);
+s32 e1000_setup_link(struct e1000_hw *hw);
+s32 e1000_phy_setup_autoneg(struct e1000_hw *hw);
 void e1000_config_collision_dist(struct e1000_hw *hw);
-int32_t e1000_check_for_link(struct e1000_hw *hw);
-int32_t e1000_get_speed_and_duplex(struct e1000_hw *hw, uint16_t *speed, uint16_t *duplex);
-int32_t e1000_force_mac_fc(struct e1000_hw *hw);
+s32 e1000_check_for_link(struct e1000_hw *hw);
+s32 e1000_get_speed_and_duplex(struct e1000_hw *hw, u16 *speed, u16 *duplex);
+s32 e1000_force_mac_fc(struct e1000_hw *hw);
 
 /* PHY */
-int32_t e1000_read_phy_reg(struct e1000_hw *hw, uint32_t reg_addr, uint16_t *phy_data);
-int32_t e1000_write_phy_reg(struct e1000_hw *hw, uint32_t reg_addr, uint16_t data);
-int32_t e1000_phy_hw_reset(struct e1000_hw *hw);
-int32_t e1000_phy_reset(struct e1000_hw *hw);
-int32_t e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
-int32_t e1000_validate_mdi_setting(struct e1000_hw *hw);
+s32 e1000_read_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 *phy_data);
+s32 e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 data);
+s32 e1000_phy_hw_reset(struct e1000_hw *hw);
+s32 e1000_phy_reset(struct e1000_hw *hw);
+s32 e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
+s32 e1000_validate_mdi_setting(struct e1000_hw *hw);
 
 void e1000_phy_powerdown_workaround(struct e1000_hw *hw);
 
 /* EEPROM Functions */
-int32_t e1000_init_eeprom_params(struct e1000_hw *hw);
+s32 e1000_init_eeprom_params(struct e1000_hw *hw);
 
 /* MNG HOST IF functions */
-uint32_t e1000_enable_mng_pass_thru(struct e1000_hw *hw);
+u32 e1000_enable_mng_pass_thru(struct e1000_hw *hw);
 
 #define E1000_MNG_DHCP_TX_PAYLOAD_CMD   64
 #define E1000_HI_MAX_MNG_DATA_LENGTH    0x6F8   /* Host Interface data length */
@@ -354,80 +354,80 @@ uint32_t e1000_enable_mng_pass_thru(struct e1000_hw *hw);
 #define E1000_VFTA_ENTRY_BIT_SHIFT_MASK              0x1F
 
 struct e1000_host_mng_command_header {
-    uint8_t command_id;
-    uint8_t checksum;
-    uint16_t reserved1;
-    uint16_t reserved2;
-    uint16_t command_length;
+    u8 command_id;
+    u8 checksum;
+    u16 reserved1;
+    u16 reserved2;
+    u16 command_length;
 };
 
 struct e1000_host_mng_command_info {
     struct e1000_host_mng_command_header command_header;  /* Command Head/Command Result Head has 4 bytes */
-    uint8_t command_data[E1000_HI_MAX_MNG_DATA_LENGTH];   /* Command data can length 0..0x658*/
+    u8 command_data[E1000_HI_MAX_MNG_DATA_LENGTH];   /* Command data can length 0..0x658*/
 };
 #ifdef __BIG_ENDIAN
 struct e1000_host_mng_dhcp_cookie{
-    uint32_t signature;
-    uint16_t vlan_id;
-    uint8_t reserved0;
-    uint8_t status;
-    uint32_t reserved1;
-    uint8_t checksum;
-    uint8_t reserved3;
-    uint16_t reserved2;
+    u32 signature;
+    u16 vlan_id;
+    u8 reserved0;
+    u8 status;
+    u32 reserved1;
+    u8 checksum;
+    u8 reserved3;
+    u16 reserved2;
 };
 #else
 struct e1000_host_mng_dhcp_cookie{
-    uint32_t signature;
-    uint8_t status;
-    uint8_t reserved0;
-    uint16_t vlan_id;
-    uint32_t reserved1;
-    uint16_t reserved2;
-    uint8_t reserved3;
-    uint8_t checksum;
+    u32 signature;
+    u8 status;
+    u8 reserved0;
+    u16 vlan_id;
+    u32 reserved1;
+    u16 reserved2;
+    u8 reserved3;
+    u8 checksum;
 };
 #endif
 
-int32_t e1000_mng_write_dhcp_info(struct e1000_hw *hw, uint8_t *buffer,
-                                  uint16_t length);
+s32 e1000_mng_write_dhcp_info(struct e1000_hw *hw, u8 *buffer,
+                                  u16 length);
 bool e1000_check_mng_mode(struct e1000_hw *hw);
 bool e1000_enable_tx_pkt_filtering(struct e1000_hw *hw);
-int32_t e1000_read_eeprom(struct e1000_hw *hw, uint16_t reg, uint16_t words, uint16_t *data);
-int32_t e1000_validate_eeprom_checksum(struct e1000_hw *hw);
-int32_t e1000_update_eeprom_checksum(struct e1000_hw *hw);
-int32_t e1000_write_eeprom(struct e1000_hw *hw, uint16_t reg, uint16_t words, uint16_t *data);
-int32_t e1000_read_mac_addr(struct e1000_hw * hw);
+s32 e1000_read_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 *data);
+s32 e1000_validate_eeprom_checksum(struct e1000_hw *hw);
+s32 e1000_update_eeprom_checksum(struct e1000_hw *hw);
+s32 e1000_write_eeprom(struct e1000_hw *hw, u16 reg, u16 words, u16 *data);
+s32 e1000_read_mac_addr(struct e1000_hw * hw);
 
 /* Filters (multicast, vlan, receive) */
-uint32_t e1000_hash_mc_addr(struct e1000_hw *hw, uint8_t * mc_addr);
-void e1000_mta_set(struct e1000_hw *hw, uint32_t hash_value);
-void e1000_rar_set(struct e1000_hw *hw, uint8_t * mc_addr, uint32_t rar_index);
-void e1000_write_vfta(struct e1000_hw *hw, uint32_t offset, uint32_t value);
+u32 e1000_hash_mc_addr(struct e1000_hw *hw, u8 * mc_addr);
+void e1000_mta_set(struct e1000_hw *hw, u32 hash_value);
+void e1000_rar_set(struct e1000_hw *hw, u8 * mc_addr, u32 rar_index);
+void e1000_write_vfta(struct e1000_hw *hw, u32 offset, u32 value);
 
 /* LED functions */
-int32_t e1000_setup_led(struct e1000_hw *hw);
-int32_t e1000_cleanup_led(struct e1000_hw *hw);
-int32_t e1000_led_on(struct e1000_hw *hw);
-int32_t e1000_led_off(struct e1000_hw *hw);
-int32_t e1000_blink_led_start(struct e1000_hw *hw);
+s32 e1000_setup_led(struct e1000_hw *hw);
+s32 e1000_cleanup_led(struct e1000_hw *hw);
+s32 e1000_led_on(struct e1000_hw *hw);
+s32 e1000_led_off(struct e1000_hw *hw);
+s32 e1000_blink_led_start(struct e1000_hw *hw);
 
 /* Adaptive IFS Functions */
 
 /* Everything else */
 void e1000_reset_adaptive(struct e1000_hw *hw);
 void e1000_update_adaptive(struct e1000_hw *hw);
-void e1000_tbi_adjust_stats(struct e1000_hw *hw, struct e1000_hw_stats *stats, uint32_t frame_len, uint8_t * mac_addr);
+void e1000_tbi_adjust_stats(struct e1000_hw *hw, struct e1000_hw_stats *stats, u32 frame_len, u8 * mac_addr);
 void e1000_get_bus_info(struct e1000_hw *hw);
 void e1000_pci_set_mwi(struct e1000_hw *hw);
 void e1000_pci_clear_mwi(struct e1000_hw *hw);
-int32_t e1000_read_pcie_cap_reg(struct e1000_hw *hw, uint32_t reg, uint16_t *value);
+s32 e1000_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value);
 void e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc);
 int e1000_pcix_get_mmrbc(struct e1000_hw *hw);
 /* Port I/O is only supported on 82544 and newer */
-void e1000_io_write(struct e1000_hw *hw, unsigned long port, uint32_t value);
-int32_t e1000_disable_pciex_master(struct e1000_hw *hw);
-int32_t e1000_check_phy_reset_block(struct e1000_hw *hw);
+void e1000_io_write(struct e1000_hw *hw, unsigned long port, u32 value);
+s32 e1000_disable_pciex_master(struct e1000_hw *hw);
+s32 e1000_check_phy_reset_block(struct e1000_hw *hw);
 
 
 #define E1000_READ_REG_IO(a, reg) \
@@ -596,8 +596,8 @@ struct e1000_rx_desc {
     __le64 buffer_addr; /* Address of the descriptor's data buffer */
     __le16 length;     /* Length of data DMAed into data buffer */
     __le16 csum;       /* Packet checksum */
-    uint8_t status;      /* Descriptor status */
-    uint8_t errors;      /* Descriptor Errors */
+    u8 status;      /* Descriptor status */
+    u8 errors;      /* Descriptor Errors */
     __le16 special;
 };
 
@@ -718,15 +718,15 @@ struct e1000_tx_desc {
         __le32 data;
         struct {
             __le16 length;    /* Data buffer length */
-            uint8_t cso;        /* Checksum offset */
-            uint8_t cmd;        /* Descriptor control */
+            u8 cso;        /* Checksum offset */
+            u8 cmd;        /* Descriptor control */
         } flags;
     } lower;
     union {
         __le32 data;
         struct {
-            uint8_t status;     /* Descriptor status */
-            uint8_t css;        /* Checksum start */
+            u8 status;     /* Descriptor status */
+            u8 css;        /* Checksum start */
             __le16 special;
         } fields;
     } upper;
@@ -759,16 +759,16 @@ struct e1000_context_desc {
     union {
         __le32 ip_config;
         struct {
-            uint8_t ipcss;      /* IP checksum start */
-            uint8_t ipcso;      /* IP checksum offset */
+            u8 ipcss;      /* IP checksum start */
+            u8 ipcso;      /* IP checksum offset */
             __le16 ipcse;     /* IP checksum end */
         } ip_fields;
     } lower_setup;
     union {
         __le32 tcp_config;
         struct {
-            uint8_t tucss;      /* TCP checksum start */
-            uint8_t tucso;      /* TCP checksum offset */
+            u8 tucss;      /* TCP checksum start */
+            u8 tucso;      /* TCP checksum offset */
             __le16 tucse;     /* TCP checksum end */
         } tcp_fields;
     } upper_setup;
@@ -776,8 +776,8 @@ struct e1000_context_desc {
     union {
         __le32 data;
         struct {
-            uint8_t status;     /* Descriptor status */
-            uint8_t hdr_len;    /* Header length */
+            u8 status;     /* Descriptor status */
+            u8 hdr_len;    /* Header length */
             __le16 mss;       /* Maximum segment size */
         } fields;
     } tcp_seg_setup;
@@ -790,15 +790,15 @@ struct e1000_data_desc {
         __le32 data;
         struct {
             __le16 length;    /* Data buffer length */
-            uint8_t typ_len_ext;        /* */
-            uint8_t cmd;        /* */
+            u8 typ_len_ext;        /* */
+            u8 cmd;        /* */
         } flags;
     } lower;
     union {
         __le32 data;
         struct {
-            uint8_t status;     /* Descriptor status */
-            uint8_t popts;      /* Packet Options */
+            u8 status;     /* Descriptor status */
+            u8 popts;      /* Packet Options */
             __le16 special;   /* */
         } fields;
     } upper;
@@ -825,8 +825,8 @@ struct e1000_rar {
 
 /* IPv4 Address Table Entry */
 struct e1000_ipv4_at_entry {
-    volatile uint32_t ipv4_addr;        /* IP Address (RW) */
-    volatile uint32_t reserved;
+    volatile u32 ipv4_addr;        /* IP Address (RW) */
+    volatile u32 reserved;
 };
 
 /* Four wakeup IP addresses are supported */
@@ -837,25 +837,25 @@ struct e1000_ipv4_at_entry {
 
 /* IPv6 Address Table Entry */
 struct e1000_ipv6_at_entry {
-    volatile uint8_t ipv6_addr[16];
+    volatile u8 ipv6_addr[16];
 };
 
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
@@ -1309,89 +1309,89 @@ struct e1000_ffvt_entry {
 
 /* Statistics counters collected by the MAC */
 struct e1000_hw_stats {
-	uint64_t		crcerrs;
-	uint64_t		algnerrc;
-	uint64_t		symerrs;
-	uint64_t		rxerrc;
-	uint64_t		txerrc;
-	uint64_t		mpc;
-	uint64_t		scc;
-	uint64_t		ecol;
-	uint64_t		mcc;
-	uint64_t		latecol;
-	uint64_t		colc;
-	uint64_t		dc;
-	uint64_t		tncrs;
-	uint64_t		sec;
-	uint64_t		cexterr;
-	uint64_t		rlec;
-	uint64_t		xonrxc;
-	uint64_t		xontxc;
-	uint64_t		xoffrxc;
-	uint64_t		xofftxc;
-	uint64_t		fcruc;
-	uint64_t		prc64;
-	uint64_t		prc127;
-	uint64_t		prc255;
-	uint64_t		prc511;
-	uint64_t		prc1023;
-	uint64_t		prc1522;
-	uint64_t		gprc;
-	uint64_t		bprc;
-	uint64_t		mprc;
-	uint64_t		gptc;
-	uint64_t		gorcl;
-	uint64_t		gorch;
-	uint64_t		gotcl;
-	uint64_t		gotch;
-	uint64_t		rnbc;
-	uint64_t		ruc;
-	uint64_t		rfc;
-	uint64_t		roc;
-	uint64_t		rlerrc;
-	uint64_t		rjc;
-	uint64_t		mgprc;
-	uint64_t		mgpdc;
-	uint64_t		mgptc;
-	uint64_t		torl;
-	uint64_t		torh;
-	uint64_t		totl;
-	uint64_t		toth;
-	uint64_t		tpr;
-	uint64_t		tpt;
-	uint64_t		ptc64;
-	uint64_t		ptc127;
-	uint64_t		ptc255;
-	uint64_t		ptc511;
-	uint64_t		ptc1023;
-	uint64_t		ptc1522;
-	uint64_t		mptc;
-	uint64_t		bptc;
-	uint64_t		tsctc;
-	uint64_t		tsctfc;
-	uint64_t		iac;
-	uint64_t		icrxptc;
-	uint64_t		icrxatc;
-	uint64_t		ictxptc;
-	uint64_t		ictxatc;
-	uint64_t		ictxqec;
-	uint64_t		ictxqmtc;
-	uint64_t		icrxdmtc;
-	uint64_t		icrxoc;
+	u64		crcerrs;
+	u64		algnerrc;
+	u64		symerrs;
+	u64		rxerrc;
+	u64		txerrc;
+	u64		mpc;
+	u64		scc;
+	u64		ecol;
+	u64		mcc;
+	u64		latecol;
+	u64		colc;
+	u64		dc;
+	u64		tncrs;
+	u64		sec;
+	u64		cexterr;
+	u64		rlec;
+	u64		xonrxc;
+	u64		xontxc;
+	u64		xoffrxc;
+	u64		xofftxc;
+	u64		fcruc;
+	u64		prc64;
+	u64		prc127;
+	u64		prc255;
+	u64		prc511;
+	u64		prc1023;
+	u64		prc1522;
+	u64		gprc;
+	u64		bprc;
+	u64		mprc;
+	u64		gptc;
+	u64		gorcl;
+	u64		gorch;
+	u64		gotcl;
+	u64		gotch;
+	u64		rnbc;
+	u64		ruc;
+	u64		rfc;
+	u64		roc;
+	u64		rlerrc;
+	u64		rjc;
+	u64		mgprc;
+	u64		mgpdc;
+	u64		mgptc;
+	u64		torl;
+	u64		torh;
+	u64		totl;
+	u64		toth;
+	u64		tpr;
+	u64		tpt;
+	u64		ptc64;
+	u64		ptc127;
+	u64		ptc255;
+	u64		ptc511;
+	u64		ptc1023;
+	u64		ptc1522;
+	u64		mptc;
+	u64		bptc;
+	u64		tsctc;
+	u64		tsctfc;
+	u64		iac;
+	u64		icrxptc;
+	u64		icrxatc;
+	u64		ictxptc;
+	u64		ictxatc;
+	u64		ictxqec;
+	u64		ictxqmtc;
+	u64		icrxdmtc;
+	u64		icrxoc;
 };
 
 /* Structure containing variables used by the shared code (e1000_hw.c) */
 struct e1000_hw {
-	uint8_t __iomem		*hw_addr;
-	uint8_t __iomem		*flash_address;
+	u8 __iomem		*hw_addr;
+	u8 __iomem		*flash_address;
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
@@ -1400,51 +1400,51 @@ struct e1000_hw {
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
-	uint16_t		phy_spd_default;
-	uint16_t		autoneg_advertised;
-	uint16_t		pci_cmd_word;
-	uint16_t		fc_high_water;
-	uint16_t		fc_low_water;
-	uint16_t		fc_pause_time;
-	uint16_t		current_ifs_val;
-	uint16_t		ifs_min_val;
-	uint16_t		ifs_max_val;
-	uint16_t		ifs_step_size;
-	uint16_t		ifs_ratio;
-	uint16_t		device_id;
-	uint16_t		vendor_id;
-	uint16_t		subsystem_id;
-	uint16_t		subsystem_vendor_id;
-	uint8_t			revision_id;
-	uint8_t			autoneg;
-	uint8_t			mdix;
-	uint8_t			forced_speed_duplex;
-	uint8_t			wait_autoneg_complete;
-	uint8_t			dma_fairness;
-	uint8_t			mac_addr[NODE_ADDRESS_SIZE];
-	uint8_t			perm_mac_addr[NODE_ADDRESS_SIZE];
+	u16		phy_spd_default;
+	u16		autoneg_advertised;
+	u16		pci_cmd_word;
+	u16		fc_high_water;
+	u16		fc_low_water;
+	u16		fc_pause_time;
+	u16		current_ifs_val;
+	u16		ifs_min_val;
+	u16		ifs_max_val;
+	u16		ifs_step_size;
+	u16		ifs_ratio;
+	u16		device_id;
+	u16		vendor_id;
+	u16		subsystem_id;
+	u16		subsystem_vendor_id;
+	u8			revision_id;
+	u8			autoneg;
+	u8			mdix;
+	u8			forced_speed_duplex;
+	u8			wait_autoneg_complete;
+	u8			dma_fairness;
+	u8			mac_addr[NODE_ADDRESS_SIZE];
+	u8			perm_mac_addr[NODE_ADDRESS_SIZE];
 	bool			disable_polarity_correction;
 	bool			speed_downgraded;
 	e1000_smart_speed	smart_speed;
@@ -2165,14 +2165,14 @@ typedef enum {
 #define E1000_HI_COMMAND_TIMEOUT         500 /* Time in ms to process HI command */
 
 struct e1000_host_command_header {
-    uint8_t command_id;
-    uint8_t command_length;
-    uint8_t command_options;   /* I/F bits for command, status for return */
-    uint8_t checksum;
+    u8 command_id;
+    u8 command_length;
+    u8 command_options;   /* I/F bits for command, status for return */
+    u8 checksum;
 };
 struct e1000_host_command_info {
     struct e1000_host_command_header command_header;  /* Command Head/Command Result Head has 4 bytes */
-    uint8_t command_data[E1000_HI_MAX_DATA_LENGTH];   /* Command data can length 0..252 */
+    u8 command_data[E1000_HI_MAX_DATA_LENGTH];   /* Command data can length 0..252 */
 };
 
 /* Host SMB register #0 */
@@ -2495,7 +2495,7 @@ struct e1000_host_command_info {
 /* Number of milliseconds we wait for PHY configuration done after MAC reset */
 #define PHY_CFG_TIMEOUT             100
 
-#define E1000_TX_BUFFER_SIZE ((uint32_t)1514)
+#define E1000_TX_BUFFER_SIZE ((u32)1514)
 
 /* The carrier extension symbol, as received by the NIC. */
 #define CARRIER_EXTENSION   0x0F
@@ -3312,68 +3312,68 @@ struct e1000_host_command_info {
 /* Offset 04h HSFSTS */
 union ich8_hws_flash_status {
     struct ich8_hsfsts {
-#ifdef E1000_BIG_ENDIAN
-        uint16_t reserved2      :6;
-        uint16_t fldesvalid     :1;
-        uint16_t flockdn        :1;
-        uint16_t flcdone        :1;
-        uint16_t flcerr         :1;
-        uint16_t dael           :1;
-        uint16_t berasesz       :2;
-        uint16_t flcinprog      :1;
-        uint16_t reserved1      :2;
+#ifdef __BIG_ENDIAN
+        u16 reserved2      :6;
+        u16 fldesvalid     :1;
+        u16 flockdn        :1;
+        u16 flcdone        :1;
+        u16 flcerr         :1;
+        u16 dael           :1;
+        u16 berasesz       :2;
+        u16 flcinprog      :1;
+        u16 reserved1      :2;
 #else
-        uint16_t flcdone        :1;   /* bit 0 Flash Cycle Done */
-        uint16_t flcerr         :1;   /* bit 1 Flash Cycle Error */
-        uint16_t dael           :1;   /* bit 2 Direct Access error Log */
-        uint16_t berasesz       :2;   /* bit 4:3 Block/Sector Erase Size */
-        uint16_t flcinprog      :1;   /* bit 5 flash SPI cycle in Progress */
-        uint16_t reserved1      :2;   /* bit 13:6 Reserved */
-        uint16_t reserved2      :6;   /* bit 13:6 Reserved */
-        uint16_t fldesvalid     :1;   /* bit 14 Flash Descriptor Valid */
-        uint16_t flockdn        :1;   /* bit 15 Flash Configuration Lock-Down */
+        u16 flcdone        :1;   /* bit 0 Flash Cycle Done */
+        u16 flcerr         :1;   /* bit 1 Flash Cycle Error */
+        u16 dael           :1;   /* bit 2 Direct Access error Log */
+        u16 berasesz       :2;   /* bit 4:3 Block/Sector Erase Size */
+        u16 flcinprog      :1;   /* bit 5 flash SPI cycle in Progress */
+        u16 reserved1      :2;   /* bit 13:6 Reserved */
+        u16 reserved2      :6;   /* bit 13:6 Reserved */
+        u16 fldesvalid     :1;   /* bit 14 Flash Descriptor Valid */
+        u16 flockdn        :1;   /* bit 15 Flash Configuration Lock-Down */
 #endif
     } hsf_status;
-    uint16_t regval;
+    u16 regval;
 };
 
 /* ICH8 GbE Flash Hardware Sequencing Flash control Register bit breakdown */
 /* Offset 06h FLCTL */
 union ich8_hws_flash_ctrl {
     struct ich8_hsflctl {
-#ifdef E1000_BIG_ENDIAN
-        uint16_t fldbcount      :2;
-        uint16_t flockdn        :6;
-        uint16_t flcgo          :1;
-        uint16_t flcycle        :2;
-        uint16_t reserved       :5;
+#ifdef __BIG_ENDIAN
+        u16 fldbcount      :2;
+        u16 flockdn        :6;
+        u16 flcgo          :1;
+        u16 flcycle        :2;
+        u16 reserved       :5;
 #else
-        uint16_t flcgo          :1;   /* 0 Flash Cycle Go */
-        uint16_t flcycle        :2;   /* 2:1 Flash Cycle */
-        uint16_t reserved       :5;   /* 7:3 Reserved  */
-        uint16_t fldbcount      :2;   /* 9:8 Flash Data Byte Count */
-        uint16_t flockdn        :6;   /* 15:10 Reserved */
+        u16 flcgo          :1;   /* 0 Flash Cycle Go */
+        u16 flcycle        :2;   /* 2:1 Flash Cycle */
+        u16 reserved       :5;   /* 7:3 Reserved  */
+        u16 fldbcount      :2;   /* 9:8 Flash Data Byte Count */
+        u16 flockdn        :6;   /* 15:10 Reserved */
 #endif
     } hsf_ctrl;
-    uint16_t regval;
+    u16 regval;
 };
 
 /* ICH8 Flash Region Access Permissions */
 union ich8_hws_flash_regacc {
     struct ich8_flracc {
-#ifdef E1000_BIG_ENDIAN
-        uint32_t gmwag          :8;
-        uint32_t gmrag          :8;
-        uint32_t grwa           :8;
-        uint32_t grra           :8;
+#ifdef __BIG_ENDIAN
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
-    uint16_t regval;
+    u16 regval;
 };
 
 /* Miscellaneous PHY bit definitions. */
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f12de3c..b0e2493 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -94,7 +94,7 @@ int e1000_up(struct e1000_adapter *adapter);
 void e1000_down(struct e1000_adapter *adapter);
 void e1000_reinit_locked(struct e1000_adapter *adapter);
 void e1000_reset(struct e1000_adapter *adapter);
-int e1000_set_spd_dplx(struct e1000_adapter *adapter, uint16_t spddplx);
+int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx);
 int e1000_setup_all_tx_resources(struct e1000_adapter *adapter);
 int e1000_setup_all_rx_resources(struct e1000_adapter *adapter);
 void e1000_free_all_tx_resources(struct e1000_adapter *adapter);
@@ -170,8 +170,8 @@ static int e1000_82547_fifo_workaround(struct e1000_adapter *adapter,
                                        struct sk_buff *skb);
 
 static void e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp);
-static void e1000_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid);
-static void e1000_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid);
+static void e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid);
+static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid);
 static void e1000_restore_vlan(struct e1000_adapter *adapter);
 
 static int e1000_suspend(struct pci_dev *pdev, pm_message_t state);
@@ -335,8 +335,8 @@ static void
 e1000_update_mng_vlan(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	uint16_t vid = adapter->hw.mng_cookie.vlan_id;
-	uint16_t old_vid = adapter->mng_vlan_id;
+	u16 vid = adapter->hw.mng_cookie.vlan_id;
+	u16 old_vid = adapter->mng_vlan_id;
 	if (adapter->vlgrp) {
 		if (!vlan_group_get_device(adapter->vlgrp, vid)) {
 			if (adapter->hw.mng_cookie.status &
@@ -346,7 +346,7 @@ e1000_update_mng_vlan(struct e1000_adapter *adapter)
 			} else
 				adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
 
-			if ((old_vid != (uint16_t)E1000_MNG_VLAN_NONE) &&
+			if ((old_vid != (u16)E1000_MNG_VLAN_NONE) &&
 					(vid != old_vid) &&
 			    !vlan_group_get_device(adapter->vlgrp, old_vid))
 				e1000_vlan_rx_kill_vid(netdev, old_vid);
@@ -369,8 +369,8 @@ e1000_update_mng_vlan(struct e1000_adapter *adapter)
 static void
 e1000_release_hw_control(struct e1000_adapter *adapter)
 {
-	uint32_t ctrl_ext;
-	uint32_t swsm;
+	u32 ctrl_ext;
+	u32 swsm;
 
 	/* Let firmware taken over control of h/w */
 	switch (adapter->hw.mac_type) {
@@ -406,8 +406,8 @@ e1000_release_hw_control(struct e1000_adapter *adapter)
 static void
 e1000_get_hw_control(struct e1000_adapter *adapter)
 {
-	uint32_t ctrl_ext;
-	uint32_t swsm;
+	u32 ctrl_ext;
+	u32 swsm;
 
 	/* Let firmware know the driver has taken over */
 	switch (adapter->hw.mac_type) {
@@ -433,7 +433,7 @@ static void
 e1000_init_manageability(struct e1000_adapter *adapter)
 {
 	if (adapter->en_mng_pt) {
-		uint32_t manc = E1000_READ_REG(&adapter->hw, MANC);
+		u32 manc = E1000_READ_REG(&adapter->hw, MANC);
 
 		/* disable hardware interception of ARP */
 		manc &= ~(E1000_MANC_ARP_EN);
@@ -442,7 +442,7 @@ e1000_init_manageability(struct e1000_adapter *adapter)
 		/* this will probably generate destination unreachable messages
 		 * from the host OS, but the packets will be handled on SMBUS */
 		if (adapter->hw.has_manc2h) {
-			uint32_t manc2h = E1000_READ_REG(&adapter->hw, MANC2H);
+			u32 manc2h = E1000_READ_REG(&adapter->hw, MANC2H);
 
 			manc |= E1000_MANC_EN_MNG2HOST;
 #define E1000_MNG2HOST_PORT_623 (1 << 5)
@@ -460,7 +460,7 @@ static void
 e1000_release_manageability(struct e1000_adapter *adapter)
 {
 	if (adapter->en_mng_pt) {
-		uint32_t manc = E1000_READ_REG(&adapter->hw, MANC);
+		u32 manc = E1000_READ_REG(&adapter->hw, MANC);
 
 		/* re-enable hardware interception of ARP */
 		manc |= E1000_MANC_ARP_EN;
@@ -533,7 +533,7 @@ int e1000_up(struct e1000_adapter *adapter)
 
 void e1000_power_up_phy(struct e1000_adapter *adapter)
 {
-	uint16_t mii_reg = 0;
+	u16 mii_reg = 0;
 
 	/* Just clear the power down bit to wake the phy back up */
 	if (adapter->hw.media_type == e1000_media_type_copper) {
@@ -554,7 +554,7 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 	 * (c) SoL/IDER session is active */
 	if (!adapter->wol && adapter->hw.mac_type >= e1000_82540 &&
 	   adapter->hw.media_type == e1000_media_type_copper) {
-		uint16_t mii_reg = 0;
+		u16 mii_reg = 0;
 
 		switch (adapter->hw.mac_type) {
 		case e1000_82540:
@@ -634,8 +634,8 @@ e1000_reinit_locked(struct e1000_adapter *adapter)
 void
 e1000_reset(struct e1000_adapter *adapter)
 {
-	uint32_t pba = 0, tx_space, min_tx_space, min_rx_space;
-	uint16_t fc_high_water_mark = E1000_FC_HIGH_DIFF;
+	u32 pba = 0, tx_space, min_tx_space, min_rx_space;
+	u16 fc_high_water_mark = E1000_FC_HIGH_DIFF;
 	bool legacy_pba_adjust = false;
 
 	/* Repartition Pba for greater than 9k mtu
@@ -782,7 +782,7 @@ e1000_reset(struct e1000_adapter *adapter)
 	    adapter->hw.mac_type <= e1000_82547_rev_2 &&
 	    adapter->hw.autoneg == 1 &&
 	    adapter->hw.autoneg_advertised == ADVERTISE_1000_FULL) {
-		uint32_t ctrl = E1000_READ_REG(&adapter->hw, CTRL);
+		u32 ctrl = E1000_READ_REG(&adapter->hw, CTRL);
 		/* clear phy power management bit if we are in gig only mode,
 		 * which if enabled will attempt negotiation to 100Mb, which
 		 * can cause a loss of link at power off or driver unload */
@@ -799,7 +799,7 @@ e1000_reset(struct e1000_adapter *adapter)
 	if (!adapter->smart_power_down &&
 	    (adapter->hw.mac_type == e1000_82571 ||
 	     adapter->hw.mac_type == e1000_82572)) {
-		uint16_t phy_data = 0;
+		u16 phy_data = 0;
 		/* speed up time to link by disabling smart power down, ignore
 		 * the return value of this function because there is nothing
 		 * different we would do if it failed */
@@ -893,8 +893,8 @@ e1000_probe(struct pci_dev *pdev,
 	static int cards_found = 0;
 	static int global_quad_port_a = 0; /* global ksp3 port a indication */
 	int i, err, pci_using_dac;
-	uint16_t eeprom_data = 0;
-	uint16_t eeprom_apme_mask = E1000_EEPROM_APME;
+	u16 eeprom_data = 0;
+	u16 eeprom_apme_mask = E1000_EEPROM_APME;
 	DECLARE_MAC_BUF(mac);
 
 	if ((err = pci_enable_device(pdev)))
@@ -1669,10 +1669,10 @@ e1000_setup_all_tx_resources(struct e1000_adapter *adapter)
 static void
 e1000_configure_tx(struct e1000_adapter *adapter)
 {
-	uint64_t tdba;
+	u64 tdba;
 	struct e1000_hw *hw = &adapter->hw;
-	uint32_t tdlen, tctl, tipg, tarc;
-	uint32_t ipgr1, ipgr2;
+	u32 tdlen, tctl, tipg, tarc;
+	u32 ipgr1, ipgr2;
 
 	/* Setup the HW Tx Head and Tail descriptor pointers */
 
@@ -1914,10 +1914,10 @@ e1000_setup_all_rx_resources(struct e1000_adapter *adapter)
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
@@ -2032,9 +2032,9 @@ e1000_setup_rctl(struct e1000_adapter *adapter)
 static void
 e1000_configure_rx(struct e1000_adapter *adapter)
 {
-	uint64_t rdba;
+	u64 rdba;
 	struct e1000_hw *hw = &adapter->hw;
-	uint32_t rdlen, rctl, rxcsum, ctrl_ext;
+	u32 rdlen, rctl, rxcsum, ctrl_ext;
 
 	if (adapter->rx_ps_pages) {
 		/* this is a 32 byte descriptor */
@@ -2354,7 +2354,7 @@ static void
 e1000_enter_82542_rst(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	uint32_t rctl;
+	u32 rctl;
 
 	e1000_pci_clear_mwi(&adapter->hw);
 
@@ -2372,7 +2372,7 @@ static void
 e1000_leave_82542_rst(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	uint32_t rctl;
+	u32 rctl;
 
 	rctl = E1000_READ_REG(&adapter->hw, RCTL);
 	rctl &= ~E1000_RCTL_RST;
@@ -2457,8 +2457,8 @@ e1000_set_rx_mode(struct net_device *netdev)
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
@@ -2562,7 +2562,7 @@ e1000_82547_tx_fifo_stall(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
 	struct net_device *netdev = adapter->netdev;
-	uint32_t tctl;
+	u32 tctl;
 
 	if (atomic_read(&adapter->tx_fifo_stall)) {
 		if ((E1000_READ_REG(&adapter->hw, TDT) ==
@@ -2604,8 +2604,8 @@ e1000_watchdog(unsigned long data)
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
-	uint32_t link, tctl;
-	int32_t ret_val;
+	u32 link, tctl;
+	s32 ret_val;
 
 	ret_val = e1000_check_for_link(&adapter->hw);
 	if ((ret_val == E1000_ERR_PHY) &&
@@ -2630,7 +2630,7 @@ e1000_watchdog(unsigned long data)
 
 	if (link) {
 		if (!netif_carrier_ok(netdev)) {
-			uint32_t ctrl;
+			u32 ctrl;
 			bool txb2b = true;
 			e1000_get_speed_and_duplex(&adapter->hw,
 			                           &adapter->link_speed,
@@ -2667,7 +2667,7 @@ e1000_watchdog(unsigned long data)
 			if ((adapter->hw.mac_type == e1000_82571 ||
 			     adapter->hw.mac_type == e1000_82572) &&
 			    !txb2b) {
-				uint32_t tarc0;
+				u32 tarc0;
 				tarc0 = E1000_READ_REG(&adapter->hw, TARC0);
 				tarc0 &= ~(1 << 21);
 				E1000_WRITE_REG(&adapter->hw, TARC0, tarc0);
@@ -2709,7 +2709,7 @@ e1000_watchdog(unsigned long data)
 			/* make sure the receive unit is started */
 			if (adapter->hw.rx_needs_kicking) {
 				struct e1000_hw *hw = &adapter->hw;
-				uint32_t rctl = E1000_READ_REG(hw, RCTL);
+				u32 rctl = E1000_READ_REG(hw, RCTL);
 				E1000_WRITE_REG(hw, RCTL, rctl | E1000_RCTL_EN);
 			}
 		}
@@ -2799,7 +2799,7 @@ enum latency_range {
  * @bytes: the number of bytes during this measurement interval
  **/
 static unsigned int e1000_update_itr(struct e1000_adapter *adapter,
-                                   uint16_t itr_setting,
+                                   u16 itr_setting,
                                    int packets,
                                    int bytes)
 {
@@ -2851,8 +2851,8 @@ update_itr_done:
 static void e1000_set_itr(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	uint16_t current_itr;
-	uint32_t new_itr = adapter->itr;
+	u16 current_itr;
+	u32 new_itr = adapter->itr;
 
 	if (unlikely(hw->mac_type < e1000_82540))
 		return;
@@ -2926,9 +2926,9 @@ e1000_tso(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 	struct e1000_context_desc *context_desc;
 	struct e1000_buffer *buffer_info;
 	unsigned int i;
-	uint32_t cmd_length = 0;
-	uint16_t ipcse = 0, tucse, mss;
-	uint8_t ipcss, ipcso, tucss, tucso, hdr_len;
+	u32 cmd_length = 0;
+	u16 ipcse = 0, tucse, mss;
+	u8 ipcss, ipcso, tucss, tucso, hdr_len;
 	int err;
 
 	if (skb_is_gso(skb)) {
@@ -2999,7 +2999,7 @@ e1000_tx_csum(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 	struct e1000_context_desc *context_desc;
 	struct e1000_buffer *buffer_info;
 	unsigned int i;
-	uint8_t css;
+	u8 css;
 
 	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		css = skb_transport_offset(skb);
@@ -3144,7 +3144,7 @@ e1000_tx_queue(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 {
 	struct e1000_tx_desc *tx_desc = NULL;
 	struct e1000_buffer *buffer_info;
-	uint32_t txd_upper = 0, txd_lower = E1000_TXD_CMD_IFCS;
+	u32 txd_upper = 0, txd_lower = E1000_TXD_CMD_IFCS;
 	unsigned int i;
 
 	if (likely(tx_flags & E1000_TX_FLAGS_TSO)) {
@@ -3208,8 +3208,8 @@ e1000_tx_queue(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 static int
 e1000_82547_fifo_workaround(struct e1000_adapter *adapter, struct sk_buff *skb)
 {
-	uint32_t fifo_space = adapter->tx_fifo_size - adapter->tx_fifo_head;
-	uint32_t skb_fifo_len = skb->len + E1000_FIFO_HDR;
+	u32 fifo_space = adapter->tx_fifo_size - adapter->tx_fifo_head;
+	u32 skb_fifo_len = skb->len + E1000_FIFO_HDR;
 
 	skb_fifo_len = ALIGN(skb_fifo_len, E1000_FIFO_HDR);
 
@@ -3236,7 +3236,7 @@ static int
 e1000_transfer_dhcp_info(struct e1000_adapter *adapter, struct sk_buff *skb)
 {
 	struct e1000_hw *hw =  &adapter->hw;
-	uint16_t length, offset;
+	u16 length, offset;
 	if (vlan_tx_tag_present(skb)) {
 		if (!((vlan_tx_tag_get(skb) == adapter->hw.mng_cookie.vlan_id) &&
 			( adapter->hw.mng_cookie.status &
@@ -3247,17 +3247,17 @@ e1000_transfer_dhcp_info(struct e1000_adapter *adapter, struct sk_buff *skb)
 		struct ethhdr *eth = (struct ethhdr *) skb->data;
 		if ((htons(ETH_P_IP) == eth->h_proto)) {
 			const struct iphdr *ip =
-				(struct iphdr *)((uint8_t *)skb->data+14);
+				(struct iphdr *)((u8 *)skb->data+14);
 			if (IPPROTO_UDP == ip->protocol) {
 				struct udphdr *udp =
-					(struct udphdr *)((uint8_t *)ip +
+					(struct udphdr *)((u8 *)ip +
 						(ip->ihl << 2));
 				if (ntohs(udp->dest) == 67) {
-					offset = (uint8_t *)udp + 8 - skb->data;
+					offset = (u8 *)udp + 8 - skb->data;
 					length = skb->len - offset;
 
 					return e1000_mng_write_dhcp_info(hw,
-							(uint8_t *)udp + 8,
+							(u8 *)udp + 8,
 							length);
 				}
 			}
@@ -3337,7 +3337,7 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	 * overrun the FIFO, adjust the max buffer len if mss
 	 * drops. */
 	if (mss) {
-		uint8_t hdr_len;
+		u8 hdr_len;
 		max_per_txd = min(mss << 2, max_per_txd);
 		max_txd_pwr = fls(max_per_txd) - 1;
 
@@ -3524,7 +3524,7 @@ e1000_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int max_frame = new_mtu + ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
-	uint16_t eeprom_data = 0;
+	u16 eeprom_data = 0;
 
 	if ((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
@@ -3619,7 +3619,7 @@ e1000_update_stats(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned long flags;
-	uint16_t phy_tmp;
+	u16 phy_tmp;
 
 #define PHY_IDLE_ERROR_COUNT_MASK 0x00FF
 
@@ -3796,7 +3796,7 @@ e1000_intr_msi(int irq, void *data)
 #ifndef CONFIG_E1000_NAPI
 	int i;
 #endif
-	uint32_t icr = E1000_READ_REG(hw, ICR);
+	u32 icr = E1000_READ_REG(hw, ICR);
 
 	/* in NAPI mode read ICR disables interrupts using IAM */
 
@@ -3808,7 +3808,7 @@ e1000_intr_msi(int irq, void *data)
 		if (netif_carrier_ok(netdev) &&
 		    (adapter->hw.mac_type == e1000_80003es2lan)) {
 			/* disable receives */
-			uint32_t rctl = E1000_READ_REG(hw, RCTL);
+			u32 rctl = E1000_READ_REG(hw, RCTL);
 			E1000_WRITE_REG(hw, RCTL, rctl & ~E1000_RCTL_EN);
 		}
 		/* guard against interrupt when we're going down */
@@ -3855,7 +3855,7 @@ e1000_intr(int irq, void *data)
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	uint32_t rctl, icr = E1000_READ_REG(hw, ICR);
+	u32 rctl, icr = E1000_READ_REG(hw, ICR);
 #ifndef CONFIG_E1000_NAPI
 	int i;
 #endif
@@ -4106,11 +4106,11 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
 
 static void
 e1000_rx_checksum(struct e1000_adapter *adapter,
-		  uint32_t status_err, uint32_t csum,
+		  u32 status_err, u32 csum,
 		  struct sk_buff *skb)
 {
-	uint16_t status = (uint16_t)status_err;
-	uint8_t errors = (uint8_t)(status_err >> 24);
+	u16 status = (u16)status_err;
+	u8 errors = (u8)(status_err >> 24);
 	skb->ip_summed = CHECKSUM_NONE;
 
 	/* 82543 or newer only */
@@ -4167,8 +4167,8 @@ e1000_clean_rx_irq(struct e1000_adapter *adapter,
 	struct e1000_rx_desc *rx_desc, *next_rxd;
 	struct e1000_buffer *buffer_info, *next_buffer;
 	unsigned long flags;
-	uint32_t length;
-	uint8_t last_byte;
+	u32 length;
+	u8 last_byte;
 	unsigned int i;
 	int cleaned_count = 0;
 	bool cleaned = false;
@@ -4268,8 +4268,8 @@ e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		/* Receive Checksum Offload */
 		e1000_rx_checksum(adapter,
-				  (uint32_t)(status) |
-				  ((uint32_t)(rx_desc->errors) << 24),
+				  (u32)(status) |
+				  ((u32)(rx_desc->errors) << 24),
 				  le16_to_cpu(rx_desc->csum), skb);
 
 		skb->protocol = eth_type_trans(skb, netdev);
@@ -4343,7 +4343,7 @@ e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 	struct e1000_ps_page_dma *ps_page_dma;
 	struct sk_buff *skb;
 	unsigned int i, j;
-	uint32_t length, staterr;
+	u32 length, staterr;
 	int cleaned_count = 0;
 	bool cleaned = false;
 	unsigned int total_rx_bytes=0, total_rx_packets=0;
@@ -4726,8 +4726,8 @@ no_buffers:
 static void
 e1000_smartspeed(struct e1000_adapter *adapter)
 {
-	uint16_t phy_status;
-	uint16_t phy_ctrl;
+	u16 phy_status;
+	u16 phy_ctrl;
 
 	if ((adapter->hw.phy_type != e1000_phy_igp) || !adapter->hw.autoneg ||
 	   !(adapter->hw.autoneg_advertised & ADVERTISE_1000_FULL))
@@ -4806,8 +4806,8 @@ e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct mii_ioctl_data *data = if_mii(ifr);
 	int retval;
-	uint16_t mii_reg;
-	uint16_t spddplx;
+	u16 mii_reg;
+	u16 spddplx;
 	unsigned long flags;
 
 	if (adapter->hw.media_type != e1000_media_type_copper)
@@ -4926,11 +4926,11 @@ e1000_pcix_set_mmrbc(struct e1000_hw *hw, int mmrbc)
 	pcix_set_mmrbc(adapter->pdev, mmrbc);
 }
 
-int32_t
-e1000_read_pcie_cap_reg(struct e1000_hw *hw, uint32_t reg, uint16_t *value)
+s32
+e1000_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
 {
     struct e1000_adapter *adapter = hw->back;
-    uint16_t cap_offset;
+    u16 cap_offset;
 
     cap_offset = pci_find_capability(adapter->pdev, PCI_CAP_ID_EXP);
     if (!cap_offset)
@@ -4942,7 +4942,7 @@ e1000_read_pcie_cap_reg(struct e1000_hw *hw, uint32_t reg, uint16_t *value)
 }
 
 void
-e1000_io_write(struct e1000_hw *hw, unsigned long port, uint32_t value)
+e1000_io_write(struct e1000_hw *hw, unsigned long port, u32 value)
 {
 	outl(value, port);
 }
@@ -4951,7 +4951,7 @@ static void
 e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	uint32_t ctrl, rctl;
+	u32 ctrl, rctl;
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_disable(adapter);
@@ -4983,7 +4983,7 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 			rctl &= ~E1000_RCTL_VFE;
 			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
 			if (adapter->mng_vlan_id !=
-			    (uint16_t)E1000_MNG_VLAN_NONE) {
+			    (u16)E1000_MNG_VLAN_NONE) {
 				e1000_vlan_rx_kill_vid(netdev,
 				                       adapter->mng_vlan_id);
 				adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
@@ -4996,10 +4996,10 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 }
 
 static void
-e1000_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid)
+e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	uint32_t vfta, index;
+	u32 vfta, index;
 
 	if ((adapter->hw.mng_cookie.status &
 	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) &&
@@ -5013,10 +5013,10 @@ e1000_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid)
 }
 
 static void
-e1000_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid)
+e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	uint32_t vfta, index;
+	u32 vfta, index;
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_disable(adapter);
@@ -5045,7 +5045,7 @@ e1000_restore_vlan(struct e1000_adapter *adapter)
 	e1000_vlan_rx_register(adapter->netdev, adapter->vlgrp);
 
 	if (adapter->vlgrp) {
-		uint16_t vid;
+		u16 vid;
 		for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
 			if (!vlan_group_get_device(adapter->vlgrp, vid))
 				continue;
@@ -5055,7 +5055,7 @@ e1000_restore_vlan(struct e1000_adapter *adapter)
 }
 
 int
-e1000_set_spd_dplx(struct e1000_adapter *adapter, uint16_t spddplx)
+e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 {
 	adapter->hw.autoneg = 0;
 
@@ -5096,8 +5096,8 @@ e1000_suspend(struct pci_dev *pdev, pm_message_t state)
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
@@ -5194,7 +5194,7 @@ e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	uint32_t err;
+	u32 err;
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
