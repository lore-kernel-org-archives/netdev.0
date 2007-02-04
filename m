From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH netdev#atl1 1/3] atl1: remove whitespace damage
Date: Sat, 3 Feb 2007 20:23:58 -0600
Message-ID: <20070204022358.GB4063@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf25aec.mail.bellsouth.net ([205.152.59.73]:33185 "EHLO
	imf25aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751927AbXBDCYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Feb 2007 21:24:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jay Cliburn <jacliburn@bellsouth.net>

atl1: fix whitespace damage

Remove trailing whitespace and spaces preceding tabs.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---

 drivers/net/atl1/atl1.h         |    8 +-
 drivers/net/atl1/atl1_ethtool.c |   42 ++++++------
 drivers/net/atl1/atl1_hw.h      |   14 ++--
 drivers/net/atl1/atl1_main.c    |  130 +++++++++++++++++++-------------------
 drivers/net/atl1/atl1_param.c   |   22 +++---
 5 files changed, 108 insertions(+), 108 deletions(-)

diff --git a/drivers/net/atl1/atl1.h b/drivers/net/atl1/atl1.h
index da4bf87..3ff978b 100644
--- a/drivers/net/atl1/atl1.h
+++ b/drivers/net/atl1/atl1.h
@@ -2,20 +2,20 @@
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
  * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
  * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
- * 
+ *
  * Derived from Intel e1000 driver
  * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the Free
  * Software Foundation; either version 2 of the License, or (at your option)
  * any later version.
- * 
+ *
  * This program is distributed in the hope that it will be useful, but WITHOUT
  * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
- * 
+ *
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, write to the Free Software Foundation, Inc., 59
  * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
diff --git a/drivers/net/atl1/atl1_ethtool.c b/drivers/net/atl1/atl1_ethtool.c
index b7cd7b3..01c2348 100644
--- a/drivers/net/atl1/atl1_ethtool.c
+++ b/drivers/net/atl1/atl1_ethtool.c
@@ -2,20 +2,20 @@
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
  * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
  * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
- * 
+ *
  * Derived from Intel e1000 driver
  * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the Free
  * Software Foundation; either version 2 of the License, or (at your option)
  * any later version.
- * 
+ *
  * This program is distributed in the hope that it will be useful, but WITHOUT
  * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
- * 
+ *
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, write to the Free Software Foundation, Inc., 59
  * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
@@ -93,7 +93,7 @@ static int atl1_get_stats_count(struct net_device *netdev)
 	return ARRAY_SIZE(atl1_gstrings_stats);
 }
 
-static int atl1_get_settings(struct net_device *netdev, 
+static int atl1_get_settings(struct net_device *netdev,
 				struct ethtool_cmd *ecmd)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
@@ -142,11 +142,11 @@ static int atl1_get_settings(struct net_device *netdev,
 		ecmd->autoneg = AUTONEG_ENABLE;
 	else
 		ecmd->autoneg = AUTONEG_DISABLE;
-	
+
 	return 0;
 }
 
-static int atl1_set_settings(struct net_device *netdev, 
+static int atl1_set_settings(struct net_device *netdev,
 				struct ethtool_cmd *ecmd)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
@@ -156,7 +156,7 @@ static int atl1_set_settings(struct net_device *netdev,
 	u16 old_media_type = hw->media_type;
 
 	if (netif_running(adapter->netdev)) {
-		printk(KERN_DEBUG "%s: ethtool shutting down adapter\n", 
+		printk(KERN_DEBUG "%s: ethtool shutting down adapter\n",
 			atl1_driver_name);
 		atl1_down(adapter);
 	}
@@ -176,7 +176,7 @@ static int atl1_set_settings(struct net_device *netdev,
 		} else if (ecmd->speed == SPEED_100) {
 			if (ecmd->duplex == DUPLEX_FULL) {
 				hw->media_type = MEDIA_TYPE_100M_FULL;
-			} else 
+			} else
 				hw->media_type = MEDIA_TYPE_100M_HALF;
 		} else {
 			if (ecmd->duplex == DUPLEX_FULL)
@@ -206,8 +206,8 @@ static int atl1_set_settings(struct net_device *netdev,
 	}
 	if (atl1_phy_setup_autoneg_adv(hw)) {
 		ret_val = -EINVAL;
-		printk(KERN_WARNING 
-			"%s: invalid ethtool speed/duplex setting\n", 
+		printk(KERN_WARNING
+			"%s: invalid ethtool speed/duplex setting\n",
 			atl1_driver_name);
 		goto exit_sset;
 	}
@@ -237,13 +237,13 @@ static int atl1_set_settings(struct net_device *netdev,
 exit_sset:
 	if (ret_val)
 		hw->media_type = old_media_type;
-	
+
 	if (netif_running(adapter->netdev)) {
-		printk(KERN_DEBUG "%s: ethtool starting adapter\n", 
+		printk(KERN_DEBUG "%s: ethtool starting adapter\n",
 			atl1_driver_name);
 		atl1_up(adapter);
 	} else if (!ret_val) {
-		printk(KERN_DEBUG "%s: ethtool resetting adapter\n", 
+		printk(KERN_DEBUG "%s: ethtool resetting adapter\n",
 			atl1_driver_name);
 		atl1_reset(adapter);
 	}
@@ -256,10 +256,10 @@ static void atl1_get_drvinfo(struct net_device *netdev,
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 
 	strncpy(drvinfo->driver, atl1_driver_name, sizeof(drvinfo->driver));
-	strncpy(drvinfo->version, atl1_driver_version, 
+	strncpy(drvinfo->version, atl1_driver_version,
 		sizeof(drvinfo->version));
 	strncpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 
+	strncpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
 	drvinfo->eedump_len = ATL1_EEDUMP_LEN;
 }
@@ -428,10 +428,10 @@ static int atl1_set_pauseparam(struct net_device *netdev,
 
 static u32 atl1_get_rx_csum(struct net_device *netdev)
 {
-	return 1;	
+	return 1;
 }
 
-static void atl1_get_strings(struct net_device *netdev, u32 stringset, 
+static void atl1_get_strings(struct net_device *netdev, u32 stringset,
 				u8 *data)
 {
 	u8 *p = data;
@@ -451,8 +451,8 @@ static void atl1_get_strings(struct net_device *netdev, u32 stringset,
 static int atl1_nway_reset(struct net_device *netdev)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
-	struct atl1_hw *hw = &adapter->hw;	
-	
+	struct atl1_hw *hw = &adapter->hw;
+
 	if (netif_running(netdev)) {
 		u16 phy_data;
 		atl1_down(adapter);
@@ -468,7 +468,7 @@ static int atl1_nway_reset(struct net_device *netdev)
 				break;
 			case MEDIA_TYPE_100M_HALF:
 				phy_data = MII_CR_SPEED_100 | MII_CR_RESET;
-				break;	
+				break;
 			case MEDIA_TYPE_10M_FULL:
 				phy_data = MII_CR_FULL_DUPLEX |
 					MII_CR_SPEED_10 | MII_CR_RESET;
diff --git a/drivers/net/atl1/atl1_hw.c b/drivers/net/atl1/atl1_hw.c
diff --git a/drivers/net/atl1/atl1_hw.h b/drivers/net/atl1/atl1_hw.h
index 41f3ca7..100c09c 100644
--- a/drivers/net/atl1/atl1_hw.h
+++ b/drivers/net/atl1/atl1_hw.h
@@ -2,26 +2,26 @@
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
  * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
  * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
- * 
+ *
  * Derived from Intel e1000 driver
  * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the Free
  * Software Foundation; either version 2 of the License, or (at your option)
  * any later version.
- * 
+ *
  * This program is distributed in the hope that it will be useful, but WITHOUT
  * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
- * 
+ *
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, write to the Free Software Foundation, Inc., 59
  * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
- * 
- * There are a lot of defines in here that are unused and/or have cryptic 
- * names.  Please leave them alone, as they're the closest thing we have 
+ *
+ * There are a lot of defines in here that are unused and/or have cryptic
+ * names.  Please leave them alone, as they're the closest thing we have
  * to a spec from Attansic at present. *ahem* -- CHS
  */
 
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 793c43b..b037ebc 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -2,39 +2,39 @@
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
  * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
  * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
- * 
+ *
  * Derived from Intel e1000 driver
  * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the Free
  * Software Foundation; either version 2 of the License, or (at your option)
  * any later version.
- * 
+ *
  * This program is distributed in the hope that it will be useful, but WITHOUT
  * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
- * 
+ *
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, write to the Free Software Foundation, Inc., 59
  * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
- * 
+ *
  * The full GNU General Public License is included in this distribution in the
  * file called COPYING.
- * 
+ *
  * Contact Information:
  * Xiong Huang <xiong_huang@attansic.com>
  * Attansic Technology Corp. 3F 147, Xianzheng 9th Road, Zhubei,
  * Xinzhu  302, TAIWAN, REPUBLIC OF CHINA
- * 
+ *
  * Chris Snook <csnook@redhat.com>
  * Jay Cliburn <jcliburn@gmail.com>
- * 
+ *
  * This version is adapted from the Attansic reference driver for
  * inclusion in the Linux kernel.  It is currently under heavy development.
  * A very incomplete list of things that need to be dealt with:
- * 
+ *
  * TODO:
  * Fix TSO; tx performance is horrible with TSO enabled.
  * Wake on LAN.
@@ -173,7 +173,7 @@ static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 }
 
 /*
- * atl1_setup_mem_resources - allocate Tx / RX descriptor resources 
+ * atl1_setup_mem_resources - allocate Tx / RX descriptor resources
  * @adapter: board private structure
  *
  * Return 0 on success, negative on failure
@@ -191,7 +191,7 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 	size = sizeof(struct atl1_buffer) * (tpd_ring->count + rfd_ring->count);
 	tpd_ring->buffer_info = kzalloc(size, GFP_KERNEL);
 	if (unlikely(!tpd_ring->buffer_info)) {
-		printk(KERN_WARNING "%s: kzalloc failed , size = D%d\n", 
+		printk(KERN_WARNING "%s: kzalloc failed , size = D%d\n",
 			atl1_driver_name, size);
 		goto err_nomem;
 	}
@@ -199,7 +199,7 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 	    (struct atl1_buffer *)(tpd_ring->buffer_info + tpd_ring->count);
 
 	/* real ring DMA buffer */
-	ring_header->size = size = sizeof(struct tx_packet_desc) * 
+	ring_header->size = size = sizeof(struct tx_packet_desc) *
 					tpd_ring->count
 	    + sizeof(struct rx_free_desc) * rfd_ring->count
 	    + sizeof(struct rx_return_desc) * rrd_ring->count
@@ -207,11 +207,11 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 	    + sizeof(struct stats_msg_block)
 	    + 40;		/* "40: for 8 bytes align" huh? -- CHS */
 
-	ring_header->desc = pci_alloc_consistent(pdev, ring_header->size, 
+	ring_header->desc = pci_alloc_consistent(pdev, ring_header->size,
 						&ring_header->dma);
 	if (unlikely(!ring_header->desc)) {
-		printk(KERN_WARNING 
-			"%s: pci_alloc_consistent failed, size = D%d\n", 
+		printk(KERN_WARNING
+			"%s: pci_alloc_consistent failed, size = D%d\n",
 			atl1_driver_name, size);
 		goto err_nomem;
 	}
@@ -367,16 +367,16 @@ static void atl1_inc_smb(struct atl1_adapter *adapter)
 }
 
 static void atl1_rx_checksum(struct atl1_adapter *adapter,
-				  	struct rx_return_desc *rrd, 
+					struct rx_return_desc *rrd,
 					struct sk_buff *skb)
 {
 	skb->ip_summed = CHECKSUM_NONE;
 
 	if (unlikely(rrd->pkt_flg & PACKET_FLAG_ERR)) {
-		if (rrd->err_flg & (ERR_FLAG_CRC | ERR_FLAG_TRUNC | 
+		if (rrd->err_flg & (ERR_FLAG_CRC | ERR_FLAG_TRUNC |
 					ERR_FLAG_CODE | ERR_FLAG_OV)) {
 			adapter->hw_csum_err++;
-			printk(KERN_DEBUG "%s: rx checksum error\n", 
+			printk(KERN_DEBUG "%s: rx checksum error\n",
 				atl1_driver_name);
 			return;
 		}
@@ -388,7 +388,7 @@ static void atl1_rx_checksum(struct atl1_adapter *adapter,
 		return;
 
 	/* IPv4 packet */
-	if (likely(!(rrd->err_flg & 
+	if (likely(!(rrd->err_flg &
 		(ERR_FLAG_IP_CHKSUM | ERR_FLAG_L4_CHKSUM)))) {
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 		adapter->hw_csum_good++;
@@ -396,7 +396,7 @@ static void atl1_rx_checksum(struct atl1_adapter *adapter,
 	}
 
 	/* IPv4, but hardware thinks its checksum is wrong */
-	printk(KERN_DEBUG "%s: hw csum wrong pkt_flag:%x, err_flag:%x\n", 
+	printk(KERN_DEBUG "%s: hw csum wrong pkt_flag:%x, err_flag:%x\n",
 		atl1_driver_name, rrd->pkt_flg, rrd->err_flg);
 	skb->ip_summed = CHECKSUM_COMPLETE;
 	skb->csum = htons(rrd->xsz.xsum_sz.rx_chksum);
@@ -444,7 +444,7 @@ static u16 atl1_alloc_rx_buffers(struct atl1_adapter *adapter)
 		/*
 		 * Make buffer alignment 2 beyond a 16 byte boundary
 		 * this will result in a 16 byte aligned IP header after
-		 * the 14 byte MAC header is removed 
+		 * the 14 byte MAC header is removed
 		 */
 		skb_reserve(skb, NET_IP_ALIGN);
 		skb->dev = netdev;
@@ -487,7 +487,7 @@ next:
 static void atl1_intr_rx(struct atl1_adapter *adapter)
 {
 	int i, count;
-	u16 length; 
+	u16 length;
 	u16 rrd_next_to_clean;
 	u32 value;
 	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
@@ -510,10 +510,10 @@ chk_rrd:
 				goto rrd_ok;
 
 			/* rrd seems to be bad */
-			if (unlikely(i-- > 0)) { 
+			if (unlikely(i-- > 0)) {
 				/* rrd may not be DMAed completely */
-				printk(KERN_DEBUG 
-					"%s: RRD may not be DMAed completely\n", 
+				printk(KERN_DEBUG
+					"%s: RRD may not be DMAed completely\n",
 					atl1_driver_name);
 				udelay(1);
 				goto chk_rrd;
@@ -571,7 +571,7 @@ rrd_ok:
 		count++;
 
 		if (unlikely(rrd->pkt_flg & PACKET_FLAG_ERR)) {
-			if (!(rrd->err_flg & 
+			if (!(rrd->err_flg &
 				(ERR_FLAG_IP_CHKSUM | ERR_FLAG_L4_CHKSUM
 				| ERR_FLAG_LEN))) {
 				/* packet error, don't need upstream */
@@ -595,7 +595,7 @@ rrd_ok:
 
 		if (adapter->vlgrp && (rrd->pkt_flg & PACKET_FLAG_VLAN_INS)) {
 			u16 vlan_tag = (rrd->vlan_tag >> 4) |
-			    		((rrd->vlan_tag & 7) << 13) | 
+					((rrd->vlan_tag & 7) << 13) |
 					((rrd->vlan_tag & 8) << 9);
 			vlan_hwaccel_rx(skb, adapter->vlgrp, vlan_tag);
 		} else
@@ -626,11 +626,11 @@ rrd_ok:
 		    atomic_read(&adapter->rfd_ring.next_to_use);
 		rrd_next_to_clean =
 		    atomic_read(&adapter->rrd_ring.next_to_clean);
-		value = ((rfd_next_to_use & MB_RFD_PROD_INDX_MASK) << 
+		value = ((rfd_next_to_use & MB_RFD_PROD_INDX_MASK) <<
 			MB_RFD_PROD_INDX_SHIFT) |
-                        ((rrd_next_to_clean & MB_RRD_CONS_INDX_MASK) << 
+                        ((rrd_next_to_clean & MB_RRD_CONS_INDX_MASK) <<
 			MB_RRD_CONS_INDX_SHIFT) |
-                        ((tpd_next_to_use & MB_TPD_PROD_INDX_MASK) << 
+                        ((tpd_next_to_use & MB_TPD_PROD_INDX_MASK) <<
 			MB_TPD_PROD_INDX_SHIFT);
 		iowrite32(value, adapter->hw.hw_addr + REG_MAILBOX);
 		spin_unlock(&adapter->mb_lock);
@@ -736,7 +736,7 @@ static irqreturn_t atl1_intr(int irq, void *data)
 
 		/* check if PCIE PHY Link down */
 		if (status & ISR_PHY_LINKDOWN) {
-			printk(KERN_DEBUG "%s: pcie phy link down %x\n", 
+			printk(KERN_DEBUG "%s: pcie phy link down %x\n",
 				atl1_driver_name, status);
 			if (netif_running(adapter->netdev)) {	/* reset MAC */
 				iowrite32(0, adapter->hw.hw_addr + REG_IMR);
@@ -747,8 +747,8 @@ static irqreturn_t atl1_intr(int irq, void *data)
 
 		/* check if DMA read/write error ? */
 		if (status & (ISR_DMAR_TO_RST | ISR_DMAW_TO_RST)) {
-			printk(KERN_DEBUG 
-				"%s: pcie DMA r/w error (status = 0x%x)\n", 
+			printk(KERN_DEBUG
+				"%s: pcie DMA r/w error (status = 0x%x)\n",
 				atl1_driver_name, status);
 			iowrite32(0, adapter->hw.hw_addr + REG_IMR);
 			schedule_work(&adapter->pcie_dma_to_rst_task);
@@ -766,15 +766,15 @@ static irqreturn_t atl1_intr(int irq, void *data)
 			atl1_intr_tx(adapter);
 
 		/* rx exception */
-		if (unlikely(status & (ISR_RXF_OV | ISR_RFD_UNRUN | 
-				ISR_RRD_OV | ISR_HOST_RFD_UNRUN | 
+		if (unlikely(status & (ISR_RXF_OV | ISR_RFD_UNRUN |
+				ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
 				ISR_HOST_RRD_OV | ISR_CMB_RX))) {
 			if (status &
 			    (ISR_RXF_OV | ISR_RFD_UNRUN | ISR_RRD_OV |
 			     ISR_HOST_RFD_UNRUN | ISR_HOST_RRD_OV))
 				printk(KERN_INFO
 					"%s: rx exception: status = 0x%x\n",
- 					atl1_driver_name, status);
+					atl1_driver_name, status);
 			atl1_intr_rx(adapter);
 		}
 
@@ -819,7 +819,7 @@ static void atl1_set_multi(struct net_device *netdev)
 
 	/* clear the old settings from the multicast hash table */
 	iowrite32(0, hw->hw_addr + REG_RX_HASH_TABLE);
-	iowrite32(0, (hw->hw_addr + REG_RX_HASH_TABLE) + (1 << 2)); 
+	iowrite32(0, (hw->hw_addr + REG_RX_HASH_TABLE) + (1 << 2));
 
 	/* compute mc addresses' hash value ,and put it into hash table */
 	for (mc_ptr = netdev->mc_list; mc_ptr; mc_ptr = mc_ptr->next) {
@@ -879,7 +879,7 @@ static u32 atl1_check_link(struct atl1_adapter *adapter)
 	atl1_read_phy_reg(hw, MII_BMSR, &phy_data);
 	if (!(phy_data & BMSR_LSTATUS)) {	/* link down */
 		if (netif_carrier_ok(netdev)) {	/* old link state: Up */
-			printk(KERN_INFO "%s: link is down\n", 
+			printk(KERN_INFO "%s: link is down\n",
 				atl1_driver_name);
 			adapter->link_speed = SPEED_0;
 			netif_carrier_off(netdev);
@@ -1349,7 +1349,7 @@ static int atl1_tx_csum(struct atl1_adapter *adapter, struct sk_buff *skb,
 	return true;
 }
 
-static void atl1_tx_map(struct atl1_adapter *adapter, 
+static void atl1_tx_map(struct atl1_adapter *adapter,
 				struct sk_buff *skb, bool tcp_seg)
 {
 	/* We enter this function holding a spinlock. */
@@ -1401,8 +1401,8 @@ static void atl1_tx_map(struct atl1_adapter *adapter,
 						 (proto_hdr_len +
 						  i * MAX_TX_BUF_LEN));
 				offset = (unsigned long)(skb->data +
-						    	(proto_hdr_len +
-						     	i * MAX_TX_BUF_LEN)) &
+							(proto_hdr_len +
+							i * MAX_TX_BUF_LEN)) &
 							~PAGE_MASK;
 				buffer_info->dma =
 				    pci_map_page(adapter->pdev, page, offset,
@@ -1513,11 +1513,11 @@ static void atl1_update_mailbox(struct atl1_adapter *adapter)
 	rfd_next_to_use = atomic_read(&adapter->rfd_ring.next_to_use);
 	rrd_next_to_clean = atomic_read(&adapter->rrd_ring.next_to_clean);
 
-	value = ((rfd_next_to_use & MB_RFD_PROD_INDX_MASK) << 
+	value = ((rfd_next_to_use & MB_RFD_PROD_INDX_MASK) <<
 		MB_RFD_PROD_INDX_SHIFT) |
-		((rrd_next_to_clean & MB_RRD_CONS_INDX_MASK) << 
+		((rrd_next_to_clean & MB_RRD_CONS_INDX_MASK) <<
 		MB_RRD_CONS_INDX_SHIFT) |
-		((tpd_next_to_use & MB_TPD_PROD_INDX_MASK) << 
+		((tpd_next_to_use & MB_TPD_PROD_INDX_MASK) <<
 		MB_TPD_PROD_INDX_SHIFT);
 	iowrite32(value, adapter->hw.hw_addr + REG_MAILBOX);
 
@@ -1567,7 +1567,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	mss = skb_shinfo(skb)->gso_size;
 	if (mss) {
 		if (skb->protocol == ntohs(ETH_P_IP)) {
-			proto_hdr_len = ((skb->h.raw - skb->data) + 
+			proto_hdr_len = ((skb->h.raw - skb->data) +
 					 (skb->h.th->doff << 2));
 			if (unlikely(proto_hdr_len > len)) {
 				dev_kfree_skb_any(skb);
@@ -1575,7 +1575,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			}
 			/* need additional TPD ? */
 			if (proto_hdr_len != len)
-				count += (len - proto_hdr_len + 
+				count += (len - proto_hdr_len +
 					MAX_TX_BUF_LEN - 1) / MAX_TX_BUF_LEN;
 		}
 	}
@@ -1600,10 +1600,10 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
 		vlan_tag = vlan_tx_tag_get(skb);
-		vlan_tag = (vlan_tag << 4) | (vlan_tag >> 13) | 
+		vlan_tag = (vlan_tag << 4) | (vlan_tag >> 13) |
 			((vlan_tag >> 9) & 0x8);
 		param.csum.csumpl |= 1 << CSUM_PARAM_INSVLAG_SHIFT;
-		param.csum.csumpu |= (vlan_tag & CSUM_PARAM_VALANTAG_MASK) << 
+		param.csum.csumpu |= (vlan_tag & CSUM_PARAM_VALANTAG_MASK) <<
 			CSUM_PARAM_VALAN_SHIFT;
 	}
 
@@ -1663,9 +1663,9 @@ static void atl1_clean_rx_ring(struct atl1_adapter *adapter)
 	for (i = 0; i < rfd_ring->count; i++) {
 		buffer_info = &rfd_ring->buffer_info[i];
 		if (buffer_info->dma) {
-			pci_unmap_page(pdev, 
+			pci_unmap_page(pdev,
 					buffer_info->dma,
-					buffer_info->length, 
+					buffer_info->length,
 					PCI_DMA_FROMDEVICE);
 			buffer_info->dma = 0;
 		}
@@ -1785,7 +1785,7 @@ s32 atl1_up(struct atl1_adapter *adapter)
 			"Unable to enable MSI: %d\n", err);
 		irq_flags |= IRQF_SHARED;
 	}
-	
+
 	err = request_irq(adapter->pdev->irq, &atl1_intr, irq_flags,
 			netdev->name, netdev);
 	if (unlikely(err))
@@ -1846,7 +1846,7 @@ static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
 
 	if ((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		printk(KERN_WARNING "%s: invalid MTU setting\n", 
+		printk(KERN_WARNING "%s: invalid MTU setting\n",
 			atl1_driver_name);
 		return -EINVAL;
 	}
@@ -1911,14 +1911,14 @@ static int mdio_read(struct net_device *netdev, int phy_id, int reg_num)
 
 	return result;
 }
- 
+
 static void mdio_write(struct net_device *netdev, int phy_id, int reg_num, int val)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 
 	atl1_write_phy_reg(&adapter->hw, reg_num, val);
 }
- 
+
 /*
  * atl1_mii_ioctl -
  * @netdev:
@@ -2052,14 +2052,14 @@ static int atl1_close(struct net_device *netdev)
 
 /*
  * If TPD Buffer size equal to 0, PCIE DMAR_TO_INT
- * will assert. We do soft reset <0x1400=1> according 
- * with the SPEC. BUT, it seemes that PCIE or DMA 
+ * will assert. We do soft reset <0x1400=1> according
+ * with the SPEC. BUT, it seemes that PCIE or DMA
  * state-machine will not be reset. DMAR_TO_INT will
  * assert again and again.
  */
 static void atl1_tx_timeout_task(struct work_struct *work)
 {
-	struct atl1_adapter *adapter = 
+	struct atl1_adapter *adapter =
 		container_of(work, struct atl1_adapter, tx_timeout_task);
 	struct net_device *netdev = adapter->netdev;
 
@@ -2074,7 +2074,7 @@ static void atl1_tx_timeout_task(struct work_struct *work)
  */
 static void atl1_link_chg_task(struct work_struct *work)
 {
-	struct atl1_adapter *adapter = 
+	struct atl1_adapter *adapter =
                container_of(work, struct atl1_adapter, link_chg_task);
 	unsigned long flags;
 
@@ -2141,21 +2141,21 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	if (err) {
 		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (err) {
-			printk(KERN_DEBUG 
+			printk(KERN_DEBUG
 				"%s: no usable DMA configuration, aborting\n",
- 				atl1_driver_name);
+				atl1_driver_name);
 			goto err_dma;
 		}
 		pci_using_64 = false;
 	}
-	/* Mark all PCI regions associated with PCI device 
+	/* Mark all PCI regions associated with PCI device
 	 * pdev as being reserved by owner atl1_driver_name
 	 */
 	err = pci_request_regions(pdev, atl1_driver_name);
 	if (err)
 		goto err_request_regions;
 
-	/* Enables bus-mastering on the device and calls 
+	/* Enables bus-mastering on the device and calls
 	 * pcibios_set_master to do the needed arch specific settings
 	 */
 	pci_set_master(pdev);
@@ -2219,7 +2219,7 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	netdev->features |= (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
 
 	/*
-	 * FIXME - Until tso performance gets fixed, disable the feature. 
+	 * FIXME - Until tso performance gets fixed, disable the feature.
 	 * Enable it with ethtool -K if desired.
 	 */
 	/* netdev->features |= NETIF_F_TSO; */
@@ -2232,14 +2232,14 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	/*
 	 * patch for some L1 of old version,
 	 * the final version of L1 may not need these
-	 * patches 
+	 * patches
 	 */
 	/* atl1_pcie_patch(adapter); */
 
 	/* really reset GPHY core */
 	iowrite16(0, adapter->hw.hw_addr + REG_GPHY_ENABLE);
 
-	/* 
+	/*
 	 * reset the controller to
 	 * put the device in a known good starting state
 	 */
diff --git a/drivers/net/atl1/atl1_param.c b/drivers/net/atl1/atl1_param.c
index d9aabfa..c407214 100644
--- a/drivers/net/atl1/atl1_param.c
+++ b/drivers/net/atl1/atl1_param.c
@@ -2,20 +2,20 @@
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
  * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
  * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
- * 
+ *
  * Derived from Intel e1000 driver
  * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
- * 
+ *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License as published by the Free
  * Software Foundation; either version 2 of the License, or (at your option)
  * any later version.
- * 
+ *
  * This program is distributed in the hope that it will be useful, but WITHOUT
  * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
  * more details.
- * 
+ *
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, write to the Free Software Foundation, Inc., 59
  * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
@@ -105,18 +105,18 @@ static int __devinit atl1_validate_option(int *value, struct atl1_option *opt)
 	case enable_option:
 		switch (*value) {
 		case OPTION_ENABLED:
-			printk(KERN_INFO "%s: %s Enabled\n", atl1_driver_name, 
+			printk(KERN_INFO "%s: %s Enabled\n", atl1_driver_name,
 				opt->name);
 			return 0;
 		case OPTION_DISABLED:
-			printk(KERN_INFO "%s: %s Disabled\n", atl1_driver_name, 
+			printk(KERN_INFO "%s: %s Disabled\n", atl1_driver_name,
 				opt->name);
 			return 0;
 		}
 		break;
 	case range_option:
 		if (*value >= opt->arg.r.min && *value <= opt->arg.r.max) {
-			printk(KERN_INFO "%s: %s set to %i\n", 
+			printk(KERN_INFO "%s: %s set to %i\n",
 				atl1_driver_name, opt->name, *value);
 			return 0;
 		}
@@ -160,16 +160,16 @@ void __devinit atl1_check_options(struct atl1_adapter *adapter)
 {
 	int bd = adapter->bd_number;
 	if (bd >= ATL1_MAX_NIC) {
-		printk(KERN_NOTICE "%s: warning: no configuration for board #%i\n", 
+		printk(KERN_NOTICE "%s: warning: no configuration for board #%i\n",
 			atl1_driver_name, bd);
-		printk(KERN_NOTICE "%s: using defaults for all values\n", 
+		printk(KERN_NOTICE "%s: using defaults for all values\n",
 			atl1_driver_name);
 	}
 	{			/* Interrupt Moderate Timer */
 		struct atl1_option opt = {
 			.type = range_option,
 			.name = "Interrupt Moderator Timer",
-			.err = "using default of " 
+			.err = "using default of "
 				__MODULE_STRING(DEFAULT_INT_MOD_CNT),
 			.def = DEFAULT_INT_MOD_CNT,
 			.arg = {.r =
@@ -189,7 +189,7 @@ void __devinit atl1_check_options(struct atl1_adapter *adapter)
 			.type = range_option,
 			.name = "SPI Flash Vendor",
 			.err = "using default of "
-			    	__MODULE_STRING(FLASH_VENDOR_DEFAULT),
+				__MODULE_STRING(FLASH_VENDOR_DEFAULT),
 			.def = DEFAULT_INT_MOD_CNT,
 			.arg = {.r =
 				{.min = FLASH_VENDOR_MIN,.max =
