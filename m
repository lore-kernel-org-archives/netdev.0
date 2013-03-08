From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] e1000e: cleanup SPACING checkpatch checks
Date: Fri,  8 Mar 2013 02:07:10 -0800
Message-ID: <1362737237-13363-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27095 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933981Ab3CHKHb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 05:07:31 -0500
In-Reply-To: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

CHECK:SPACING: No space is necessary after a cast
CHECK:SPACING: space prohibited before semicolon

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c | 16 ++++++++--------
 drivers/net/ethernet/intel/e1000e/ich8lan.c |  4 ++--
 drivers/net/ethernet/intel/e1000e/netdev.c  | 10 +++++-----
 drivers/net/ethernet/intel/e1000e/phy.c     |  2 +-
 4 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index b328943..07ef74e 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -925,7 +925,7 @@ static int e1000_eeprom_test(struct e1000_adapter *adapter, u64 *data)
 	}
 
 	/* If Checksum is not Correct return error else test passed */
-	if ((checksum != (u16) NVM_SUM) && !(*data))
+	if ((checksum != (u16)NVM_SUM) && !(*data))
 		*data = 2;
 
 	return *data;
@@ -933,7 +933,7 @@ static int e1000_eeprom_test(struct e1000_adapter *adapter, u64 *data)
 
 static irqreturn_t e1000_test_intr(int __always_unused irq, void *data)
 {
-	struct net_device *netdev = (struct net_device *) data;
+	struct net_device *netdev = (struct net_device *)data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
@@ -1158,8 +1158,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
 
-	ew32(TDBAL(0), ((u64) tx_ring->dma & 0x00000000FFFFFFFF));
-	ew32(TDBAH(0), ((u64) tx_ring->dma >> 32));
+	ew32(TDBAL(0), ((u64)tx_ring->dma & 0x00000000FFFFFFFF));
+	ew32(TDBAH(0), ((u64)tx_ring->dma >> 32));
 	ew32(TDLEN(0), tx_ring->count * sizeof(struct e1000_tx_desc));
 	ew32(TDH(0), 0);
 	ew32(TDT(0), 0);
@@ -1222,8 +1222,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	rctl = er32(RCTL);
 	if (!(adapter->flags2 & FLAG2_NO_DISABLE_RX))
 		ew32(RCTL, rctl & ~E1000_RCTL_EN);
-	ew32(RDBAL(0), ((u64) rx_ring->dma & 0xFFFFFFFF));
-	ew32(RDBAH(0), ((u64) rx_ring->dma >> 32));
+	ew32(RDBAL(0), ((u64)rx_ring->dma & 0xFFFFFFFF));
+	ew32(RDBAH(0), ((u64)rx_ring->dma >> 32));
 	ew32(RDLEN(0), rx_ring->size);
 	ew32(RDH(0), 0);
 	ew32(RDT(0), 0);
@@ -1986,11 +1986,11 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
 	for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
 		switch (e1000_gstrings_stats[i].type) {
 		case NETDEV_STATS:
-			p = (char *) &net_stats +
+			p = (char *)&net_stats +
 			    e1000_gstrings_stats[i].stat_offset;
 			break;
 		case E1000_STATS:
-			p = (char *) adapter +
+			p = (char *)adapter +
 			    e1000_gstrings_stats[i].stat_offset;
 			break;
 		default:
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index a18dd1c..dd67cb6 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -3150,7 +3150,7 @@ static s32 e1000_erase_flash_bank_ich8lan(struct e1000_hw *hw, u32 bank)
 	flash_linear_addr = hw->nvm.flash_base_addr;
 	flash_linear_addr += (bank) ? flash_bank_size : 0;
 
-	for (j = 0; j < iteration ; j++) {
+	for (j = 0; j < iteration; j++) {
 		do {
 			u32 timeout = ICH_FLASH_ERASE_COMMAND_TIMEOUT;
 
@@ -3501,7 +3501,7 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 	if (mac->type == e1000_ich8lan)
 		snoop = PCIE_ICH8_SNOOP_ALL;
 	else
-		snoop = (u32) ~(PCIE_NO_SNOOP_ALL);
+		snoop = (u32)~(PCIE_NO_SNOOP_ALL);
 	e1000e_set_pcie_no_snoop(hw, snoop);
 
 	ctrl_ext = er32(CTRL_EXT);
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 9d76edc..ca1c10e 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4452,7 +4452,7 @@ static void e1000e_update_phy_task(struct work_struct *work)
  **/
 static void e1000_update_phy_info(unsigned long data)
 {
-	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
+	struct e1000_adapter *adapter = (struct e1000_adapter *)data;
 
 	if (test_bit(__E1000_DOWN, &adapter->state))
 		return;
@@ -4784,7 +4784,7 @@ static void e1000e_check_82574_phy_workaround(struct e1000_adapter *adapter)
  **/
 static void e1000_watchdog(unsigned long data)
 {
-	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
+	struct e1000_adapter *adapter = (struct e1000_adapter *)data;
 
 	/* Do the rest outside of interrupt context */
 	schedule_work(&adapter->watchdog_task);
@@ -5350,7 +5350,7 @@ static int e1000_transfer_dhcp_info(struct e1000_adapter *adapter,
 	if (skb->len <= MINIMUM_DHCP_PACKET_SIZE)
 		return 0;
 
-	if (((struct ethhdr *) skb->data)->h_proto != htons(ETH_P_IP))
+	if (((struct ethhdr *)skb->data)->h_proto != htons(ETH_P_IP))
 		return 0;
 
 	{
@@ -6727,11 +6727,11 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	init_timer(&adapter->watchdog_timer);
 	adapter->watchdog_timer.function = e1000_watchdog;
-	adapter->watchdog_timer.data = (unsigned long) adapter;
+	adapter->watchdog_timer.data = (unsigned long)adapter;
 
 	init_timer(&adapter->phy_info_timer);
 	adapter->phy_info_timer.function = e1000_update_phy_info;
-	adapter->phy_info_timer.data = (unsigned long) adapter;
+	adapter->phy_info_timer.data = (unsigned long)adapter;
 
 	INIT_WORK(&adapter->reset_task, e1000_reset_task);
 	INIT_WORK(&adapter->watchdog_task, e1000_watchdog_task);
diff --git a/drivers/net/ethernet/intel/e1000e/phy.c b/drivers/net/ethernet/intel/e1000e/phy.c
index 8ff0060..50e84ed 100644
--- a/drivers/net/ethernet/intel/e1000e/phy.c
+++ b/drivers/net/ethernet/intel/e1000e/phy.c
@@ -175,7 +175,7 @@ s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 		e_dbg("MDI Error\n");
 		return -E1000_ERR_PHY;
 	}
-	*data = (u16) mdic;
+	*data = (u16)mdic;
 
 	/* Allow some time after each MDIC transaction to avoid
 	 * reading duplicate data in the next MDIC transaction.
-- 
1.7.11.7
