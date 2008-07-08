From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 16/25] ixgb: whitespace fixups
Date: Tue, 08 Jul 2008 15:52:23 -0700
Message-ID: <20080708225223.6925.35829.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:18408 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753206AbYGHWwY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:52:24 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb.h         |    2 +
 drivers/net/ixgb/ixgb_ethtool.c |   36 +++++++++---------
 drivers/net/ixgb/ixgb_ids.h     |    8 ++--
 drivers/net/ixgb/ixgb_main.c    |   78 +++++++++++++++++++--------------------
 drivers/net/ixgb/ixgb_param.c   |    4 +-
 5 files changed, 63 insertions(+), 65 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 3cec7b9..69529ec 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -94,7 +94,7 @@ struct ixgb_adapter;
 #define MIN_TXD	  64
 
 /* hardware cannot reliably support more than 512 descriptors owned by
- * hardware descrioptor cache otherwise an unreliable ring under heavy 
+ * hardware descrioptor cache otherwise an unreliable ring under heavy
  * recieve load may result */
 /* #define DEFAULT_RXD	   1024 */
 /* #define MAX_RXD	   4096 */
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 7c9b35c..5b354e3 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -125,7 +125,7 @@ ixgb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	if (ecmd->autoneg == AUTONEG_ENABLE ||
 	   ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL)
 		return -EINVAL;
-	
+
 	if (netif_running(adapter->netdev)) {
 		ixgb_down(adapter, true);
 		ixgb_reset(adapter);
@@ -143,9 +143,9 @@ ixgb_get_pauseparam(struct net_device *netdev,
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
-	
+
 	pause->autoneg = AUTONEG_DISABLE;
-		
+
 	if (hw->fc.type == ixgb_fc_rx_pause)
 		pause->rx_pause = 1;
 	else if (hw->fc.type == ixgb_fc_tx_pause)
@@ -162,7 +162,7 @@ ixgb_set_pauseparam(struct net_device *netdev,
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
-	
+
 	if (pause->autoneg == AUTONEG_ENABLE)
 		return -EINVAL;
 
@@ -181,7 +181,7 @@ ixgb_set_pauseparam(struct net_device *netdev,
 		ixgb_set_speed_duplex(netdev);
 	} else
 		ixgb_reset(adapter);
-		
+
 	return 0;
 }
 
@@ -208,7 +208,7 @@ ixgb_set_rx_csum(struct net_device *netdev, u32 data)
 		ixgb_reset(adapter);
 	return 0;
 }
-	
+
 static u32
 ixgb_get_tx_csum(struct net_device *netdev)
 {
@@ -234,7 +234,7 @@ ixgb_set_tso(struct net_device *netdev, u32 data)
 	else
 		netdev->features &= ~NETIF_F_TSO;
 	return 0;
-} 
+}
 
 static u32
 ixgb_get_msglevel(struct net_device *netdev)
@@ -251,7 +251,7 @@ ixgb_set_msglevel(struct net_device *netdev, u32 data)
 }
 #define IXGB_GET_STAT(_A_, _R_) _A_->stats._R_
 
-static int 
+static int
 ixgb_get_regs_len(struct net_device *netdev)
 {
 #define IXGB_REG_DUMP_LEN  136*sizeof(u32)
@@ -495,7 +495,7 @@ ixgb_set_eeprom(struct net_device *netdev,
 	if ((eeprom->offset + eeprom->len) & 1) {
 		/* need read/modify/write of last changed EEPROM word */
 		/* only the first byte of the word is being modified */
-		eeprom_buff[last_word - first_word] 
+		eeprom_buff[last_word - first_word]
 			= ixgb_read_eeprom(hw, last_word);
 	}
 
@@ -534,7 +534,7 @@ ixgb_get_ringparam(struct net_device *netdev,
 	struct ixgb_desc_ring *txdr = &adapter->tx_ring;
 	struct ixgb_desc_ring *rxdr = &adapter->rx_ring;
 
-	ring->rx_max_pending = MAX_RXD; 
+	ring->rx_max_pending = MAX_RXD;
 	ring->tx_max_pending = MAX_TXD;
 	ring->rx_mini_max_pending = 0;
 	ring->rx_jumbo_max_pending = 0;
@@ -544,7 +544,7 @@ ixgb_get_ringparam(struct net_device *netdev,
 	ring->rx_jumbo_pending = 0;
 }
 
-static int 
+static int
 ixgb_set_ringparam(struct net_device *netdev,
 		struct ethtool_ringparam *ring)
 {
@@ -647,7 +647,7 @@ ixgb_phys_id(struct net_device *netdev, u32 data)
 	return 0;
 }
 
-static int 
+static int
 ixgb_get_sset_count(struct net_device *netdev, int sset)
 {
 	switch (sset) {
@@ -658,8 +658,8 @@ ixgb_get_sset_count(struct net_device *netdev, int sset)
 	}
 }
 
-static void 
-ixgb_get_ethtool_stats(struct net_device *netdev, 
+static void
+ixgb_get_ethtool_stats(struct net_device *netdev,
 		struct ethtool_stats *stats, u64 *data)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
@@ -667,13 +667,13 @@ ixgb_get_ethtool_stats(struct net_device *netdev,
 
 	ixgb_update_stats(adapter);
 	for(i = 0; i < IXGB_STATS_LEN; i++) {
-		char *p = (char *)adapter+ixgb_gstrings_stats[i].stat_offset;	
-		data[i] = (ixgb_gstrings_stats[i].sizeof_stat == 
+		char *p = (char *)adapter+ixgb_gstrings_stats[i].stat_offset;
+		data[i] = (ixgb_gstrings_stats[i].sizeof_stat ==
 			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
 	}
 }
 
-static void 
+static void
 ixgb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 {
 	int i;
@@ -681,7 +681,7 @@ ixgb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 	switch(stringset) {
 	case ETH_SS_STATS:
 		for(i=0; i < IXGB_STATS_LEN; i++) {
-			memcpy(data + i * ETH_GSTRING_LEN, 
+			memcpy(data + i * ETH_GSTRING_LEN,
 			ixgb_gstrings_stats[i].stat_string,
 			ETH_GSTRING_LEN);
 		}
diff --git a/drivers/net/ixgb/ixgb_ids.h b/drivers/net/ixgb/ixgb_ids.h
index 180d20e..4ba4d19 100644
--- a/drivers/net/ixgb/ixgb_ids.h
+++ b/drivers/net/ixgb/ixgb_ids.h
@@ -38,11 +38,11 @@
 #define SUN_VENDOR_ID               0x108E
 #define SUN_SUBVENDOR_ID            0x108E
 
-#define IXGB_DEVICE_ID_82597EX      0x1048   
-#define IXGB_DEVICE_ID_82597EX_SR   0x1A48   
+#define IXGB_DEVICE_ID_82597EX      0x1048
+#define IXGB_DEVICE_ID_82597EX_SR   0x1A48
 #define IXGB_DEVICE_ID_82597EX_LR   0x1B48
-#define IXGB_SUBDEVICE_ID_A11F      0xA11F   
-#define IXGB_SUBDEVICE_ID_A01F      0xA01F   
+#define IXGB_SUBDEVICE_ID_A11F      0xA11F
+#define IXGB_SUBDEVICE_ID_A01F      0xA01F
 
 #define IXGB_DEVICE_ID_82597EX_CX4   0x109E
 #define IXGB_SUBDEVICE_ID_A00C  0xA00C
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index dffb853..fc211a3 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -346,8 +346,7 @@ ixgb_reset(struct ixgb_adapter *adapter)
  **/
 
 static int __devinit
-ixgb_probe(struct pci_dev *pdev,
-		const struct pci_device_id *ent)
+ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev = NULL;
 	struct ixgb_adapter *adapter;
@@ -562,7 +561,7 @@ ixgb_sw_init(struct ixgb_adapter *adapter)
 	   || (hw->device_id == IXGB_DEVICE_ID_82597EX_CX4)
 	   || (hw->device_id == IXGB_DEVICE_ID_82597EX_LR)
 	   || (hw->device_id == IXGB_DEVICE_ID_82597EX_SR))
-			hw->mac_type = ixgb_82597;
+		hw->mac_type = ixgb_82597;
 	else {
 		/* should never have loaded on this device */
 		DPRINTK(PROBE, ERR, "unsupported device id\n");
@@ -702,8 +701,8 @@ ixgb_configure_tx(struct ixgb_adapter *adapter)
 	u32 tctl;
 	struct ixgb_hw *hw = &adapter->hw;
 
-	/* Setup the Base and Length of the Tx Descriptor Ring 
-	 * tx_ring.dma can be either a 32 or 64 bit value 
+	/* Setup the Base and Length of the Tx Descriptor Ring
+	 * tx_ring.dma can be either a 32 or 64 bit value
 	 */
 
 	IXGB_WRITE_REG(hw, TDBAL, (tdba & 0x00000000ffffffffULL));
@@ -729,8 +728,8 @@ ixgb_configure_tx(struct ixgb_adapter *adapter)
 
 	/* Setup Transmit Descriptor Settings for this adapter */
 	adapter->tx_cmd_type =
-		IXGB_TX_DESC_TYPE 
-		| (adapter->tx_int_delay_enable ? IXGB_TX_DESC_CMD_IDE : 0);
+		IXGB_TX_DESC_TYPE |
+		(adapter->tx_int_delay_enable ? IXGB_TX_DESC_CMD_IDE : 0);
 }
 
 /**
@@ -792,8 +791,8 @@ ixgb_setup_rctl(struct ixgb_adapter *adapter)
 	rctl &= ~(3 << IXGB_RCTL_MO_SHIFT);
 
 	rctl |=
-		IXGB_RCTL_BAM | IXGB_RCTL_RDMTS_1_2 | 
-		IXGB_RCTL_RXEN | IXGB_RCTL_CFF | 
+		IXGB_RCTL_BAM | IXGB_RCTL_RDMTS_1_2 |
+		IXGB_RCTL_RXEN | IXGB_RCTL_CFF |
 		(adapter->hw.mc_filter_type << IXGB_RCTL_MO_SHIFT);
 
 	rctl |= IXGB_RCTL_SECRC;
@@ -890,7 +889,7 @@ ixgb_free_tx_resources(struct ixgb_adapter *adapter)
 
 static void
 ixgb_unmap_and_free_tx_resource(struct ixgb_adapter *adapter,
-					struct ixgb_buffer *buffer_info)
+                                struct ixgb_buffer *buffer_info)
 {
 	struct pci_dev *pdev = adapter->pdev;
 
@@ -1076,10 +1075,11 @@ ixgb_set_multi(struct net_device *netdev)
 
 		IXGB_WRITE_REG(hw, RCTL, rctl);
 
-		for(i = 0, mc_ptr = netdev->mc_list; mc_ptr;
-			i++, mc_ptr = mc_ptr->next)
+		for (i = 0, mc_ptr = netdev->mc_list;
+		     mc_ptr;
+		     i++, mc_ptr = mc_ptr->next)
 			memcpy(&mta[i * IXGB_ETH_LENGTH_OF_ADDRESS],
-				   mc_ptr->dmi_addr, IXGB_ETH_LENGTH_OF_ADDRESS);
+			       mc_ptr->dmi_addr, IXGB_ETH_LENGTH_OF_ADDRESS);
 
 		ixgb_mc_addr_list_update(hw, mta, netdev->mc_count, 0);
 	}
@@ -1199,7 +1199,7 @@ ixgb_tso(struct ixgb_adapter *adapter, struct sk_buff *skb)
 		context_desc->hdr_len = hdr_len;
 		context_desc->status = 0;
 		context_desc->cmd_type_len = cpu_to_le32(
-						  IXGB_CONTEXT_DESC_TYPE 
+						  IXGB_CONTEXT_DESC_TYPE
 						| IXGB_CONTEXT_DESC_CMD_TSE
 						| IXGB_CONTEXT_DESC_CMD_IP
 						| IXGB_CONTEXT_DESC_CMD_TCP
@@ -1375,8 +1375,8 @@ ixgb_tx_queue(struct ixgb_adapter *adapter, int count, int vlan_id,int tx_flags)
 		if (++i == tx_ring->count) i = 0;
 	}
 
-	tx_desc->cmd_type_len |= cpu_to_le32(IXGB_TX_DESC_CMD_EOP 
-				| IXGB_TX_DESC_CMD_RS );
+	tx_desc->cmd_type_len |=
+		cpu_to_le32(IXGB_TX_DESC_CMD_EOP | IXGB_TX_DESC_CMD_RS);
 
 	/* Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
@@ -1455,7 +1455,7 @@ ixgb_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	first = adapter->tx_ring.next_to_use;
-	
+
 	tso = ixgb_tso(adapter, skb);
 	if (tso < 0) {
 		dev_kfree_skb_any(skb);
@@ -1577,16 +1577,16 @@ ixgb_update_stats(struct ixgb_adapter *adapter)
 		u64 multi = IXGB_READ_REG(&adapter->hw, MPRCL);
 		u32 bcast_l = IXGB_READ_REG(&adapter->hw, BPRCL);
 		u32 bcast_h = IXGB_READ_REG(&adapter->hw, BPRCH);
-		u64 bcast = ((u64)bcast_h << 32) | bcast_l; 
+		u64 bcast = ((u64)bcast_h << 32) | bcast_l;
 
 		multi |= ((u64)IXGB_READ_REG(&adapter->hw, MPRCH) << 32);
 		/* fix up multicast stats by removing broadcasts */
 		if (multi >= bcast)
 			multi -= bcast;
-		
+
 		adapter->stats.mprcl += (multi & 0xFFFFFFFF);
 		adapter->stats.mprch += (multi >> 32);
-		adapter->stats.bprcl += bcast_l; 
+		adapter->stats.bprcl += bcast_l;
 		adapter->stats.bprch += bcast_h;
 	} else {
 		adapter->stats.mprcl += IXGB_READ_REG(&adapter->hw, MPRCL);
@@ -1715,7 +1715,7 @@ ixgb_intr(int irq, void *data)
 #ifdef CONFIG_IXGB_NAPI
 	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
 
-		/* Disable interrupts and register for poll. The flush 
+		/* Disable interrupts and register for poll. The flush
 		  of the posted write is intentionally left out.
 		*/
 
@@ -1731,7 +1731,7 @@ ixgb_intr(int irq, void *data)
 		if (!ixgb_clean_rx_irq(adapter) &
 		   !ixgb_clean_tx_irq(adapter))
 			break;
-#endif 
+#endif
 	return IRQ_HANDLED;
 }
 
@@ -1787,9 +1787,9 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 			tx_desc = IXGB_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
 
-			if (tx_desc->popts
-			    & (IXGB_TX_DESC_POPTS_TXSM |
-			       IXGB_TX_DESC_POPTS_IXSM))
+			if (tx_desc->popts &
+			   (IXGB_TX_DESC_POPTS_TXSM |
+			    IXGB_TX_DESC_POPTS_IXSM))
 				adapter->hw_csum_tx_good++;
 
 			ixgb_unmap_and_free_tx_resource(adapter, buffer_info);
@@ -1862,8 +1862,8 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 
 static void
 ixgb_rx_checksum(struct ixgb_adapter *adapter,
-		 struct ixgb_rx_desc *rx_desc,
-		 struct sk_buff *skb)
+                 struct ixgb_rx_desc *rx_desc,
+                 struct sk_buff *skb)
 {
 	/* Ignore Checksum bit is set OR
 	 * TCP Checksum has not been calculated
@@ -1960,11 +1960,9 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 			goto rxdesc_done;
 		}
 
-		if (unlikely(rx_desc->errors
-			     & (IXGB_RX_DESC_ERRORS_CE | IXGB_RX_DESC_ERRORS_SE
-				| IXGB_RX_DESC_ERRORS_P |
-				IXGB_RX_DESC_ERRORS_RXE))) {
-
+		if (unlikely(rx_desc->errors &
+		    (IXGB_RX_DESC_ERRORS_CE | IXGB_RX_DESC_ERRORS_SE |
+		     IXGB_RX_DESC_ERRORS_P | IXGB_RX_DESC_ERRORS_RXE))) {
 			dev_kfree_skb_irq(skb);
 			goto rxdesc_done;
 		}
@@ -2000,14 +1998,14 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 #ifdef CONFIG_IXGB_NAPI
 		if (adapter->vlgrp && (status & IXGB_RX_DESC_STATUS_VP)) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->special));
+			                        le16_to_cpu(rx_desc->special));
 		} else {
 			netif_receive_skb(skb);
 		}
 #else /* CONFIG_IXGB_NAPI */
 		if (adapter->vlgrp && (status & IXGB_RX_DESC_STATUS_VP)) {
 			vlan_hwaccel_rx(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->special));
+			                le16_to_cpu(rx_desc->special));
 		} else {
 			netif_rx(skb);
 		}
@@ -2086,7 +2084,7 @@ map_skb:
 		rx_desc = IXGB_RX_DESC(*rx_ring, i);
 		rx_desc->buff_addr = cpu_to_le64(buffer_info->dma);
 		/* guarantee DD bit not set now before h/w gets descriptor
-		 * this is the rest of the workaround for h/w double 
+		 * this is the rest of the workaround for h/w double
 		 * writeback. */
 		rx_desc->status = 0;
 
@@ -2111,7 +2109,7 @@ map_skb:
 
 /**
  * ixgb_vlan_rx_register - enables or disables vlan tagging/stripping.
- * 
+ *
  * @param netdev network interface device structure
  * @param grp indicates to enable or disable tagging/stripping
  **/
@@ -2231,8 +2229,8 @@ static void ixgb_netpoll(struct net_device *dev)
  * This callback is called by the PCI subsystem whenever
  * a PCI bus error is detected.
  */
-static pci_ers_result_t ixgb_io_error_detected (struct pci_dev *pdev,
-			             enum pci_channel_state state)
+static pci_ers_result_t ixgb_io_error_detected(struct pci_dev *pdev,
+                                               enum pci_channel_state state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
@@ -2255,7 +2253,7 @@ static pci_ers_result_t ixgb_io_error_detected (struct pci_dev *pdev,
  * This is a shortened version of the device probe/discovery code,
  * it resembles the first-half of the ixgb_probe() routine.
  */
-static pci_ers_result_t ixgb_io_slot_reset (struct pci_dev *pdev)
+static pci_ers_result_t ixgb_io_slot_reset(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
@@ -2299,7 +2297,7 @@ static pci_ers_result_t ixgb_io_slot_reset (struct pci_dev *pdev)
  * normal operation. Implementation resembles the second-half
  * of the ixgb_probe() routine.
  */
-static void ixgb_io_resume (struct pci_dev *pdev)
+static void ixgb_io_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_param.c
index a23d2ff..07a6980 100644
--- a/drivers/net/ixgb/ixgb_param.c
+++ b/drivers/net/ixgb/ixgb_param.c
@@ -136,7 +136,7 @@ IXGB_PARAM(RxFCLowThresh, "Receive Flow Control Low Threshold");
 /* Flow control request timeout (how long to pause the link partner's tx)
  * (PAP 15:0)
  *
- * Valid Range: 1 - 65535 
+ * Valid Range: 1 - 65535
  *
  * Default Value:  65535 (0xffff) (we'll send an xon if we recover)
  */
@@ -412,7 +412,7 @@ ixgb_check_options(struct ixgb_adapter *adapter)
 		/* high must be greater than low */
 		if (adapter->hw.fc.high_water < (adapter->hw.fc.low_water + 8)) {
 			/* set defaults */
-			printk (KERN_INFO 
+			printk (KERN_INFO
 				"RxFCHighThresh must be >= (RxFCLowThresh + 8), "
 				"Using Defaults\n");
 			adapter->hw.fc.high_water = DEFAULT_FCRTH;

