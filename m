From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 10/11] ixgb: clean up whitespace
Date: Fri, 21 Apr 2006 18:00:53 -0700
Message-ID: <20060422010052.24255.65609.stgit@jk-desktop.jf.intel.com>
References: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Cc: John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:36269 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750821AbWDVA5r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 20:57:47 -0400
To: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
In-Reply-To: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


- remove trailing whitespace

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb.h         |   28 ++++++++--------
 drivers/net/ixgb/ixgb_ethtool.c |   68 ++++++++++++++++++++-------------------
 drivers/net/ixgb/ixgb_main.c    |   62 ++++++++++++++++++------------------
 drivers/net/ixgb/ixgb_osdep.h   |   26 +++++++--------
 4 files changed, 92 insertions(+), 92 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index f23e04f..e968f64 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -1,25 +1,25 @@
 /*******************************************************************************
 
-  
+
   Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
-  
-  This program is free software; you can redistribute it and/or modify it 
-  under the terms of the GNU General Public License as published by the Free 
-  Software Foundation; either version 2 of the License, or (at your option) 
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms of the GNU General Public License as published by the Free
+  Software Foundation; either version 2 of the License, or (at your option)
   any later version.
-  
-  This program is distributed in the hope that it will be useful, but WITHOUT 
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
+
+  This program is distributed in the hope that it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
-  
+
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc., 59 
+  this program; if not, write to the Free Software Foundation, Inc., 59
   Temple Place - Suite 330, Boston, MA  02111-1307, USA.
-  
+
   The full GNU General Public License is included in this distribution in the
   file called LICENSE.
-  
+
   Contact Information:
   Linux NICS <linux.nics@intel.com>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
@@ -97,7 +97,7 @@ struct ixgb_adapter;
 #define MIN_TXD	  64
 
 /* hardware cannot reliably support more than 512 descriptors owned by
- * hardware descrioptor cache otherwise an unreliable ring under heavy 
+ * hardware descrioptor cache otherwise an unreliable ring under heavy
  * recieve load may result */
 /* #define DEFAULT_RXD	   1024 */
 /* #define MAX_RXD	   4096 */
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 1e06f26..2388021 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -1,25 +1,25 @@
 /*******************************************************************************
 
-  
+
   Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
-  
-  This program is free software; you can redistribute it and/or modify it 
-  under the terms of the GNU General Public License as published by the Free 
-  Software Foundation; either version 2 of the License, or (at your option) 
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms of the GNU General Public License as published by the Free
+  Software Foundation; either version 2 of the License, or (at your option)
   any later version.
-  
-  This program is distributed in the hope that it will be useful, but WITHOUT 
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
+
+  This program is distributed in the hope that it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
-  
+
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc., 59 
+  this program; if not, write to the Free Software Foundation, Inc., 59
   Temple Place - Suite 330, Boston, MA  02111-1307, USA.
-  
+
   The full GNU General Public License is included in this distribution in the
   file called LICENSE.
-  
+
   Contact Information:
   Linux NICS <linux.nics@intel.com>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
@@ -138,7 +138,7 @@ ixgb_set_settings(struct net_device *net
 	if(ecmd->autoneg == AUTONEG_ENABLE ||
 	   ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL)
 		return -EINVAL;
-	
+
 	if(netif_running(adapter->netdev)) {
 		ixgb_down(adapter, TRUE);
 		ixgb_reset(adapter);
@@ -156,9 +156,9 @@ ixgb_get_pauseparam(struct net_device *n
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
-	
+
 	pause->autoneg = AUTONEG_DISABLE;
-		
+
 	if(hw->fc.type == ixgb_fc_rx_pause)
 		pause->rx_pause = 1;
 	else if(hw->fc.type == ixgb_fc_tx_pause)
@@ -175,7 +175,7 @@ ixgb_set_pauseparam(struct net_device *n
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
-	
+
 	if(pause->autoneg == AUTONEG_ENABLE)
 		return -EINVAL;
 
@@ -194,7 +194,7 @@ ixgb_set_pauseparam(struct net_device *n
 		ixgb_set_speed_duplex(netdev);
 	} else
 		ixgb_reset(adapter);
-		
+
 	return 0;
 }
 
@@ -221,7 +221,7 @@ ixgb_set_rx_csum(struct net_device *netd
 		ixgb_reset(adapter);
 	return 0;
 }
-	
+
 static uint32_t
 ixgb_get_tx_csum(struct net_device *netdev)
 {
@@ -248,7 +248,7 @@ ixgb_set_tso(struct net_device *netdev, 
 	else
 		netdev->features &= ~NETIF_F_TSO;
 	return 0;
-} 
+}
 #endif /* NETIF_F_TSO */
 
 static uint32_t
@@ -267,7 +267,7 @@ ixgb_set_msglevel(struct net_device *net
 
 #define IXGB_GET_STAT(_A_, _R_) _A_->stats._R_
 
-static int 
+static int
 ixgb_get_regs_len(struct net_device *netdev)
 {
 #define IXGB_REG_DUMP_LEN  136*sizeof(uint32_t)
@@ -511,7 +511,7 @@ ixgb_set_eeprom(struct net_device *netde
 	if((eeprom->offset + eeprom->len) & 1) {
 		/* need read/modify/write of last changed EEPROM word */
 		/* only the first byte of the word is being modified */
-		eeprom_buff[last_word - first_word] 
+		eeprom_buff[last_word - first_word]
 			= ixgb_read_eeprom(hw, last_word);
 	}
 
@@ -550,7 +550,7 @@ ixgb_get_ringparam(struct net_device *ne
 	struct ixgb_desc_ring *txdr = &adapter->tx_ring;
 	struct ixgb_desc_ring *rxdr = &adapter->rx_ring;
 
-	ring->rx_max_pending = MAX_RXD; 
+	ring->rx_max_pending = MAX_RXD;
 	ring->tx_max_pending = MAX_TXD;
 	ring->rx_mini_max_pending = 0;
 	ring->rx_jumbo_max_pending = 0;
@@ -560,7 +560,7 @@ ixgb_get_ringparam(struct net_device *ne
 	ring->rx_jumbo_pending = 0;
 }
 
-static int 
+static int
 ixgb_set_ringparam(struct net_device *netdev,
 		struct ethtool_ringparam *ring)
 {
@@ -573,7 +573,7 @@ ixgb_set_ringparam(struct net_device *ne
 	tx_old = adapter->tx_ring;
 	rx_old = adapter->rx_ring;
 
-	if((ring->rx_mini_pending) || (ring->rx_jumbo_pending)) 
+	if((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
 		return -EINVAL;
 
 	if(netif_running(adapter->netdev))
@@ -581,11 +581,11 @@ ixgb_set_ringparam(struct net_device *ne
 
 	rxdr->count = max(ring->rx_pending,(uint32_t)MIN_RXD);
 	rxdr->count = min(rxdr->count,(uint32_t)MAX_RXD);
-	IXGB_ROUNDUP(rxdr->count, IXGB_REQ_RX_DESCRIPTOR_MULTIPLE); 
+	IXGB_ROUNDUP(rxdr->count, IXGB_REQ_RX_DESCRIPTOR_MULTIPLE);
 
 	txdr->count = max(ring->tx_pending,(uint32_t)MIN_TXD);
 	txdr->count = min(txdr->count,(uint32_t)MAX_TXD);
-	IXGB_ROUNDUP(txdr->count, IXGB_REQ_TX_DESCRIPTOR_MULTIPLE); 
+	IXGB_ROUNDUP(txdr->count, IXGB_REQ_TX_DESCRIPTOR_MULTIPLE);
 
 	if(netif_running(adapter->netdev)) {
 		/* Try to get new resources before deleting old */
@@ -667,14 +667,14 @@ ixgb_phys_id(struct net_device *netdev, 
 	return 0;
 }
 
-static int 
+static int
 ixgb_get_stats_count(struct net_device *netdev)
 {
 	return IXGB_STATS_LEN;
 }
 
-static void 
-ixgb_get_ethtool_stats(struct net_device *netdev, 
+static void
+ixgb_get_ethtool_stats(struct net_device *netdev,
 		struct ethtool_stats *stats, uint64_t *data)
 {
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
@@ -682,13 +682,13 @@ ixgb_get_ethtool_stats(struct net_device
 
 	ixgb_update_stats(adapter);
 	for(i = 0; i < IXGB_STATS_LEN; i++) {
-		char *p = (char *)adapter+ixgb_gstrings_stats[i].stat_offset;	
-		data[i] = (ixgb_gstrings_stats[i].sizeof_stat == 
+		char *p = (char *)adapter+ixgb_gstrings_stats[i].stat_offset;
+		data[i] = (ixgb_gstrings_stats[i].sizeof_stat ==
 			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
 	}
 }
 
-static void 
+static void
 ixgb_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
 {
 	int i;
@@ -696,7 +696,7 @@ ixgb_get_strings(struct net_device *netd
 	switch(stringset) {
 	case ETH_SS_STATS:
 		for(i=0; i < IXGB_STATS_LEN; i++) {
-			memcpy(data + i * ETH_GSTRING_LEN, 
+			memcpy(data + i * ETH_GSTRING_LEN,
 			ixgb_gstrings_stats[i].stat_string,
 			ETH_GSTRING_LEN);
 		}
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 443d675..26cb0d5 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1,25 +1,25 @@
 /*******************************************************************************
 
-  
+
   Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
-  
-  This program is free software; you can redistribute it and/or modify it 
-  under the terms of the GNU General Public License as published by the Free 
-  Software Foundation; either version 2 of the License, or (at your option) 
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms of the GNU General Public License as published by the Free
+  Software Foundation; either version 2 of the License, or (at your option)
   any later version.
-  
-  This program is distributed in the hope that it will be useful, but WITHOUT 
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
+
+  This program is distributed in the hope that it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
-  
+
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc., 59 
+  this program; if not, write to the Free Software Foundation, Inc., 59
   Temple Place - Suite 330, Boston, MA  02111-1307, USA.
-  
+
   The full GNU General Public License is included in this distribution in the
   file called LICENSE.
-  
+
   Contact Information:
   Linux NICS <linux.nics@intel.com>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
@@ -71,7 +71,7 @@ static struct pci_device_id ixgb_pci_tbl
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_SR,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_LR,  
+	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_LR,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 
 	/* required last entry */
@@ -249,7 +249,7 @@ ixgb_up(struct ixgb_adapter *adapter)
 
 #ifdef CONFIG_PCI_MSI
 	{
-	boolean_t pcix = (IXGB_READ_REG(&adapter->hw, STATUS) & 
+	boolean_t pcix = (IXGB_READ_REG(&adapter->hw, STATUS) &
 						  IXGB_STATUS_PCIX_MODE) ? TRUE : FALSE;
 	adapter->have_msi = TRUE;
 
@@ -266,7 +266,7 @@ ixgb_up(struct ixgb_adapter *adapter)
 	if ((err = request_irq(adapter->pdev->irq, &ixgb_intr,
 		 SA_SHIRQ | SA_SAMPLE_RANDOM, netdev->name, netdev))) {
 		DPRINTK(PROBE, ERR,
-		 "Unable to allocate interrupt Error: %d\n", err);		 
+		 "Unable to allocate interrupt Error: %d\n", err);
 		return err;
 	}
 
@@ -717,8 +717,8 @@ ixgb_configure_tx(struct ixgb_adapter *a
 	uint32_t tctl;
 	struct ixgb_hw *hw = &adapter->hw;
 
-	/* Setup the Base and Length of the Tx Descriptor Ring 
-	 * tx_ring.dma can be either a 32 or 64 bit value 
+	/* Setup the Base and Length of the Tx Descriptor Ring
+	 * tx_ring.dma can be either a 32 or 64 bit value
 	 */
 
 	IXGB_WRITE_REG(hw, TDBAL, (tdba & 0x00000000ffffffffULL));
@@ -744,7 +744,7 @@ ixgb_configure_tx(struct ixgb_adapter *a
 
 	/* Setup Transmit Descriptor Settings for this adapter */
 	adapter->tx_cmd_type =
-		IXGB_TX_DESC_TYPE 
+		IXGB_TX_DESC_TYPE
 		| (adapter->tx_int_delay_enable ? IXGB_TX_DESC_CMD_IDE : 0);
 }
 
@@ -807,8 +807,8 @@ ixgb_setup_rctl(struct ixgb_adapter *ada
 	rctl &= ~(3 << IXGB_RCTL_MO_SHIFT);
 
 	rctl |=
-		IXGB_RCTL_BAM | IXGB_RCTL_RDMTS_1_2 | 
-		IXGB_RCTL_RXEN | IXGB_RCTL_CFF | 
+		IXGB_RCTL_BAM | IXGB_RCTL_RDMTS_1_2 |
+		IXGB_RCTL_RXEN | IXGB_RCTL_CFF |
 		(adapter->hw.mc_filter_type << IXGB_RCTL_MO_SHIFT);
 
 	rctl |= IXGB_RCTL_SECRC;
@@ -1222,7 +1222,7 @@ ixgb_tso(struct ixgb_adapter *adapter, s
 		context_desc->hdr_len = hdr_len;
 		context_desc->status = 0;
 		context_desc->cmd_type_len = cpu_to_le32(
-						  IXGB_CONTEXT_DESC_TYPE 
+						  IXGB_CONTEXT_DESC_TYPE
 						| IXGB_CONTEXT_DESC_CMD_TSE
 						| IXGB_CONTEXT_DESC_CMD_IP
 						| IXGB_CONTEXT_DESC_CMD_TCP
@@ -1395,7 +1395,7 @@ ixgb_tx_queue(struct ixgb_adapter *adapt
 		if(++i == tx_ring->count) i = 0;
 	}
 
-	tx_desc->cmd_type_len |= cpu_to_le32(IXGB_TX_DESC_CMD_EOP 
+	tx_desc->cmd_type_len |= cpu_to_le32(IXGB_TX_DESC_CMD_EOP
 				| IXGB_TX_DESC_CMD_RS );
 
 	/* Force memory writes to complete before letting h/w
@@ -1444,7 +1444,7 @@ ixgb_xmit_frame(struct sk_buff *skb, str
 	}
 
 	first = adapter->tx_ring.next_to_use;
-	
+
 	tso = ixgb_tso(adapter, skb);
 	if (tso < 0) {
 		dev_kfree_skb_any(skb);
@@ -1566,16 +1566,16 @@ ixgb_update_stats(struct ixgb_adapter *a
 		u64 multi = IXGB_READ_REG(&adapter->hw, MPRCL);
 		u32 bcast_l = IXGB_READ_REG(&adapter->hw, BPRCL);
 		u32 bcast_h = IXGB_READ_REG(&adapter->hw, BPRCH);
-		u64 bcast = ((u64)bcast_h << 32) | bcast_l; 
+		u64 bcast = ((u64)bcast_h << 32) | bcast_l;
 
 		multi |= ((u64)IXGB_READ_REG(&adapter->hw, MPRCH) << 32);
 		/* fix up multicast stats by removing broadcasts */
 		if(multi >= bcast)
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
@@ -1705,7 +1705,7 @@ ixgb_intr(int irq, void *data, struct pt
 #ifdef CONFIG_IXGB_NAPI
 	if(netif_rx_schedule_prep(netdev)) {
 
-		/* Disable interrupts and register for poll. The flush 
+		/* Disable interrupts and register for poll. The flush
 		  of the posted write is intentionally left out.
 		*/
 
@@ -1722,7 +1722,7 @@ ixgb_intr(int irq, void *data, struct pt
 		if(!ixgb_clean_rx_irq(adapter) &
 		   !ixgb_clean_tx_irq(adapter))
 			break;
-#endif 
+#endif
 	return IRQ_HANDLED;
 }
 
@@ -2053,7 +2053,7 @@ ixgb_alloc_rx_buffers(struct ixgb_adapte
 
 		rx_desc->buff_addr = cpu_to_le64(buffer_info->dma);
 		/* guarantee DD bit not set now before h/w gets descriptor
-		 * this is the rest of the workaround for h/w double 
+		 * this is the rest of the workaround for h/w double
 		 * writeback. */
 		rx_desc->status = 0;
 
@@ -2076,7 +2076,7 @@ ixgb_alloc_rx_buffers(struct ixgb_adapte
 
 /**
  * ixgb_vlan_rx_register - enables or disables vlan tagging/stripping.
- * 
+ *
  * @param netdev network interface device structure
  * @param grp indicates to enable or disable tagging/stripping
  **/
diff --git a/drivers/net/ixgb/ixgb_osdep.h b/drivers/net/ixgb/ixgb_osdep.h
index dba2048..d96d13f 100644
--- a/drivers/net/ixgb/ixgb_osdep.h
+++ b/drivers/net/ixgb/ixgb_osdep.h
@@ -1,25 +1,25 @@
 /*******************************************************************************
 
-  
+
   Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
-  
-  This program is free software; you can redistribute it and/or modify it 
-  under the terms of the GNU General Public License as published by the Free 
-  Software Foundation; either version 2 of the License, or (at your option) 
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms of the GNU General Public License as published by the Free
+  Software Foundation; either version 2 of the License, or (at your option)
   any later version.
-  
-  This program is distributed in the hope that it will be useful, but WITHOUT 
-  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
-  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
+
+  This program is distributed in the hope that it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
-  
+
   You should have received a copy of the GNU General Public License along with
-  this program; if not, write to the Free Software Foundation, Inc., 59 
+  this program; if not, write to the Free Software Foundation, Inc., 59
   Temple Place - Suite 330, Boston, MA  02111-1307, USA.
-  
+
   The full GNU General Public License is included in this distribution in the
   file called LICENSE.
-  
+
   Contact Information:
   Linux NICS <linux.nics@intel.com>
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497

