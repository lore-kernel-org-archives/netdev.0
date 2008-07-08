From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 18/25] ixgb: trivial fix space after for
Date: Tue, 08 Jul 2008 15:52:33 -0700
Message-ID: <20080708225233.6925.16772.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7402 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754130AbYGHWwe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:52:34 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_ee.c      |   10 +++++-----
 drivers/net/ixgb/ixgb_ethtool.c |   14 ++++++--------
 drivers/net/ixgb/ixgb_hw.c      |   21 ++++++++++-----------
 drivers/net/ixgb/ixgb_main.c    |   12 ++++++------
 drivers/net/ixgb/ixgb_param.c   |    2 +-
 5 files changed, 28 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
index aa71b9b..4a9e52f 100644
--- a/drivers/net/ixgb/ixgb_ee.c
+++ b/drivers/net/ixgb/ixgb_ee.c
@@ -152,7 +152,7 @@ ixgb_shift_in_bits(struct ixgb_hw *hw)
 	eecd_reg &= ~(IXGB_EECD_DO | IXGB_EECD_DI);
 	data = 0;
 
-	for(i = 0; i < 16; i++) {
+	for (i = 0; i < 16; i++) {
 		data = data << 1;
 		ixgb_raise_clock(hw, &eecd_reg);
 
@@ -297,7 +297,7 @@ ixgb_wait_eeprom_command(struct ixgb_hw *hw)
 	 * signal that the command has been completed by raising the DO signal.
 	 * If DO does not go high in 10 milliseconds, then error out.
 	 */
-	for(i = 0; i < 200; i++) {
+	for (i = 0; i < 200; i++) {
 		eecd_reg = IXGB_READ_REG(hw, EECD);
 
 		if (eecd_reg & IXGB_EECD_DO)
@@ -328,7 +328,7 @@ ixgb_validate_eeprom_checksum(struct ixgb_hw *hw)
 	u16 checksum = 0;
 	u16 i;
 
-	for(i = 0; i < (EEPROM_CHECKSUM_REG + 1); i++)
+	for (i = 0; i < (EEPROM_CHECKSUM_REG + 1); i++)
 		checksum += ixgb_read_eeprom(hw, i);
 
 	if (checksum == (u16) EEPROM_SUM)
@@ -351,7 +351,7 @@ ixgb_update_eeprom_checksum(struct ixgb_hw *hw)
 	u16 checksum = 0;
 	u16 i;
 
-	for(i = 0; i < EEPROM_CHECKSUM_REG; i++)
+	for (i = 0; i < EEPROM_CHECKSUM_REG; i++)
 		checksum += ixgb_read_eeprom(hw, i);
 
 	checksum = (u16) EEPROM_SUM - checksum;
@@ -472,7 +472,7 @@ ixgb_get_eeprom_data(struct ixgb_hw *hw)
 	ee_map = (struct ixgb_ee_map_type *)hw->eeprom;
 
 	DEBUGOUT("ixgb_ee: Reading eeprom data\n");
-	for(i = 0; i < IXGB_EEPROM_SIZE ; i++) {
+	for (i = 0; i < IXGB_EEPROM_SIZE ; i++) {
 		u16 ee_data;
 		ee_data = ixgb_read_eeprom(hw, i);
 		checksum += ee_data;
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 5b354e3..e1836c1 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -301,7 +301,7 @@ ixgb_get_regs(struct net_device *netdev,
 	*reg++ = IXGB_READ_REG(hw, RXCSUM);	/*  20 */
 
 	/* there are 16 RAR entries in hardware, we only use 3 */
-	for(i = 0; i < IXGB_ALL_RAR_ENTRIES; i++) {
+	for (i = 0; i < IXGB_ALL_RAR_ENTRIES; i++) {
 		*reg++ = IXGB_READ_REG_ARRAY(hw, RAL, (i << 1)); /*21,...,51 */
 		*reg++ = IXGB_READ_REG_ARRAY(hw, RAH, (i << 1)); /*22,...,52 */
 	}
@@ -441,12 +441,10 @@ ixgb_get_eeprom(struct net_device *netdev,
 		return -ENOMEM;
 
 	/* note the eeprom was good because the driver loaded */
-	for(i = 0; i <= (last_word - first_word); i++) {
+	for (i = 0; i <= (last_word - first_word); i++)
 		eeprom_buff[i] = ixgb_get_eeprom_word(hw, (first_word + i));
-	}
 
-	memcpy(bytes, (u8 *)eeprom_buff + (eeprom->offset & 1),
-			eeprom->len);
+	memcpy(bytes, (u8 *)eeprom_buff + (eeprom->offset & 1), eeprom->len);
 	kfree(eeprom_buff);
 
 geeprom_error:
@@ -500,7 +498,7 @@ ixgb_set_eeprom(struct net_device *netdev,
 	}
 
 	memcpy(ptr, bytes, eeprom->len);
-	for(i = 0; i <= (last_word - first_word); i++)
+	for (i = 0; i <= (last_word - first_word); i++)
 		ixgb_write_eeprom(hw, first_word + i, eeprom_buff[i]);
 
 	/* Update the checksum over the first part of the EEPROM if needed */
@@ -666,7 +664,7 @@ ixgb_get_ethtool_stats(struct net_device *netdev,
 	int i;
 
 	ixgb_update_stats(adapter);
-	for(i = 0; i < IXGB_STATS_LEN; i++) {
+	for (i = 0; i < IXGB_STATS_LEN; i++) {
 		char *p = (char *)adapter+ixgb_gstrings_stats[i].stat_offset;
 		data[i] = (ixgb_gstrings_stats[i].sizeof_stat ==
 			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
@@ -680,7 +678,7 @@ ixgb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 
 	switch(stringset) {
 	case ETH_SS_STATS:
-		for(i=0; i < IXGB_STATS_LEN; i++) {
+		for (i = 0; i < IXGB_STATS_LEN; i++) {
 			memcpy(data + i * ETH_GSTRING_LEN,
 			ixgb_gstrings_stats[i].stat_string,
 			ETH_GSTRING_LEN);
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index 3694e8c..9cc75ce 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -347,7 +347,7 @@ ixgb_init_hw(struct ixgb_hw *hw)
 
 	/* Zero out the Multicast HASH table */
 	DEBUGOUT("Zeroing the MTA\n");
-	for(i = 0; i < IXGB_MC_TBL_SIZE; i++)
+	for (i = 0; i < IXGB_MC_TBL_SIZE; i++)
 		IXGB_WRITE_REG_ARRAY(hw, MTA, i, 0);
 
 	/* Zero out the VLAN Filter Table Array */
@@ -413,7 +413,7 @@ ixgb_init_rx_addrs(struct ixgb_hw *hw)
 
 	/* Zero out the other 15 receive addresses. */
 	DEBUGOUT("Clearing RAR[1-15]\n");
-	for(i = 1; i < IXGB_RAR_ENTRIES; i++) {
+	for (i = 1; i < IXGB_RAR_ENTRIES; i++) {
 		/* Write high reg first to disable the AV bit first */
 		IXGB_WRITE_REG_ARRAY(hw, RA, ((i << 1) + 1), 0);
 		IXGB_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
@@ -452,19 +452,18 @@ ixgb_mc_addr_list_update(struct ixgb_hw *hw,
 
 	/* Clear RAR[1-15] */
 	DEBUGOUT(" Clearing RAR[1-15]\n");
-	for(i = rar_used_count; i < IXGB_RAR_ENTRIES; i++) {
+	for (i = rar_used_count; i < IXGB_RAR_ENTRIES; i++) {
 		IXGB_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
 		IXGB_WRITE_REG_ARRAY(hw, RA, ((i << 1) + 1), 0);
 	}
 
 	/* Clear the MTA */
 	DEBUGOUT(" Clearing MTA\n");
-	for(i = 0; i < IXGB_MC_TBL_SIZE; i++) {
+	for (i = 0; i < IXGB_MC_TBL_SIZE; i++)
 		IXGB_WRITE_REG_ARRAY(hw, MTA, i, 0);
-	}
 
 	/* Add the new addresses */
-	for(i = 0; i < mc_addr_count; i++) {
+	for (i = 0; i < mc_addr_count; i++) {
 		DEBUGOUT(" Adding the multicast addresses:\n");
 		DEBUGOUT7(" MC Addr #%d =%.2X %.2X %.2X %.2X %.2X %.2X\n", i,
 			  mc_addr_list[i * (IXGB_ETH_LENGTH_OF_ADDRESS + pad)],
@@ -649,7 +648,7 @@ ixgb_clear_vfta(struct ixgb_hw *hw)
 {
 	u32 offset;
 
-	for(offset = 0; offset < IXGB_VLAN_FILTER_TBL_SIZE; offset++)
+	for (offset = 0; offset < IXGB_VLAN_FILTER_TBL_SIZE; offset++)
 		IXGB_WRITE_REG_ARRAY(hw, VFTA, offset, 0);
 	return;
 }
@@ -790,7 +789,7 @@ ixgb_read_phy_reg(struct ixgb_hw *hw,
     ** from the CPU Write to the Ready bit assertion.
     **************************************************************/
 
-	for(i = 0; i < 10; i++)
+	for (i = 0; i < 10; i++)
 	{
 		udelay(10);
 
@@ -817,7 +816,7 @@ ixgb_read_phy_reg(struct ixgb_hw *hw,
     ** from the CPU Write to the Ready bit assertion.
     **************************************************************/
 
-	for(i = 0; i < 10; i++)
+	for (i = 0; i < 10; i++)
 	{
 		udelay(10);
 
@@ -886,7 +885,7 @@ ixgb_write_phy_reg(struct ixgb_hw *hw,
 	** from the CPU Write to the Ready bit assertion.
 	**************************************************************/
 
-	for(i = 0; i < 10; i++)
+	for (i = 0; i < 10; i++)
 	{
 		udelay(10);
 
@@ -913,7 +912,7 @@ ixgb_write_phy_reg(struct ixgb_hw *hw,
 	** from the CPU Write to the Ready bit assertion.
 	**************************************************************/
 
-	for(i = 0; i < 10; i++)
+	for (i = 0; i < 10; i++)
 	{
 		udelay(10);
 
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 796f011..c1dde79 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -398,7 +398,7 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_ioremap;
 	}
 
-	for(i = BAR_1; i <= BAR_5; i++) {
+	for (i = BAR_1; i <= BAR_5; i++) {
 		if (pci_resource_len(pdev, i) == 0)
 			continue;
 		if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
@@ -923,7 +923,7 @@ ixgb_clean_tx_ring(struct ixgb_adapter *adapter)
 
 	/* Free all the Tx ring sk_buffs */
 
-	for(i = 0; i < tx_ring->count; i++) {
+	for (i = 0; i < tx_ring->count; i++) {
 		buffer_info = &tx_ring->buffer_info[i];
 		ixgb_unmap_and_free_tx_resource(adapter, buffer_info);
 	}
@@ -981,7 +981,7 @@ ixgb_clean_rx_ring(struct ixgb_adapter *adapter)
 
 	/* Free all the Rx ring sk_buffs */
 
-	for(i = 0; i < rx_ring->count; i++) {
+	for (i = 0; i < rx_ring->count; i++) {
 		buffer_info = &rx_ring->buffer_info[i];
 		if (buffer_info->skb) {
 
@@ -1298,7 +1298,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 		if (++i == tx_ring->count) i = 0;
 	}
 
-	for(f = 0; f < nr_frags; f++) {
+	for (f = 0; f < nr_frags; f++) {
 		struct skb_frag_struct *frag;
 
 		frag = &skb_shinfo(skb)->frags[f];
@@ -1727,7 +1727,7 @@ ixgb_intr(int irq, void *data)
 	 * every pass through this for loop checks both receive and
 	 * transmit queues for completed descriptors, intended to
 	 * avoid starvation issues and assist tx/rx fairness. */
-	for(i = 0; i < IXGB_MAX_INTR; i++)
+	for (i = 0; i < IXGB_MAX_INTR; i++)
 		if (!ixgb_clean_rx_irq(adapter) &
 		   !ixgb_clean_tx_irq(adapter))
 			break;
@@ -2196,7 +2196,7 @@ ixgb_restore_vlan(struct ixgb_adapter *adapter)
 
 	if (adapter->vlgrp) {
 		u16 vid;
-		for(vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
+		for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
 			if (!vlan_group_get_device(adapter->vlgrp, vid))
 				continue;
 			ixgb_vlan_rx_add_vid(adapter->netdev, vid);
diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_param.c
index 07a6980..107ef48 100644
--- a/drivers/net/ixgb/ixgb_param.c
+++ b/drivers/net/ixgb/ixgb_param.c
@@ -226,7 +226,7 @@ ixgb_validate_option(unsigned int *value, const struct ixgb_option *opt)
 		int i;
 		struct ixgb_opt_list *ent;
 
-		for(i = 0; i < opt->arg.l.nr; i++) {
+		for (i = 0; i < opt->arg.l.nr; i++) {
 			ent = &opt->arg.l.p[i];
 			if (*value == ent->i) {
 				if (ent->str[0] != '\0')

