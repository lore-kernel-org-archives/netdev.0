From: <zyjzyj2000@gmail.com>
Subject: [PATCH 1/1] igb: adjust indent and remove unnecessary parentheses
Date: Thu, 4 Feb 2016 17:38:20 +0800
Message-ID: <1454578701-2173-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <zyjzyj2000@gmail.com>, <netdev@vger.kernel.org>,
	<jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:48048 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755527AbcBDJgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 04:36:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

Adjust indent and remove unnecessary parentheses in igb driver.

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 31e5f39..744cfc2 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2128,10 +2128,10 @@ void igb_set_fw_version(struct igb_adapter *adapter)
 			    "%d.%d, 0x%08x",
 			    fw.eep_major, fw.eep_minor, fw.etrack_id);
 		} else {
-		snprintf(adapter->fw_version,
-		    sizeof(adapter->fw_version),
-		    "%d.%d.%d",
-		    fw.eep_major, fw.eep_minor, fw.eep_build);
+			snprintf(adapter->fw_version,
+			    sizeof(adapter->fw_version),
+			    "%d.%d.%d",
+			    fw.eep_major, fw.eep_minor, fw.eep_build);
 		}
 		break;
 	}
@@ -2593,8 +2593,8 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			  "Width x1" : "unknown"), netdev->dev_addr);
 	}
 
-	if ((hw->mac.type >= e1000_i210 ||
-	     igb_get_flash_presence_i210(hw))) {
+	if (hw->mac.type >= e1000_i210 ||
+	     igb_get_flash_presence_i210(hw)) {
 		ret_val = igb_read_part_string(hw, part_str,
 					       E1000_PBANUM_LENGTH);
 	} else {
@@ -4538,7 +4538,7 @@ static void igb_update_itr(struct igb_q_vector *q_vector,
 				itrval = bulk_latency;
 			else if ((packets < 10) || ((bytes/packets) > 1200))
 				itrval = bulk_latency;
-			else if ((packets > 35))
+			else if (packets > 35)
 				itrval = lowest_latency;
 		} else if (bytes/packets > 2000) {
 			itrval = bulk_latency;
@@ -6165,7 +6165,7 @@ static void igb_rcv_msg_from_vf(struct igb_adapter *adapter, u32 vf)
 		goto out;
 	}
 
-	switch ((msgbuf[0] & 0xFFFF)) {
+	switch (msgbuf[0] & 0xFFFF) {
 	case E1000_VF_SET_MAC_ADDR:
 		retval = -EINVAL;
 		if (!(vf_data->flags & IGB_VF_FLAG_PF_SET_MAC))
@@ -6859,8 +6859,8 @@ static bool igb_cleanup_headers(struct igb_ring *rx_ring,
 				union e1000_adv_rx_desc *rx_desc,
 				struct sk_buff *skb)
 {
-	if (unlikely((igb_test_staterr(rx_desc,
-				       E1000_RXDEXT_ERR_FRAME_ERR_MASK)))) {
+	if (unlikely(igb_test_staterr(rx_desc,
+				       E1000_RXDEXT_ERR_FRAME_ERR_MASK))) {
 		struct net_device *netdev = rx_ring->netdev;
 		if (!(netdev->features & NETIF_F_RXALL)) {
 			dev_kfree_skb_any(skb);
-- 
1.7.9.5
