From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 15/25] ixgb: cleanup space after while
Date: Tue, 08 Jul 2008 15:52:18 -0700
Message-ID: <20080708225218.6925.9524.stgit@localhost.localdomain>
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
	id S1754130AbYGHWwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:52:25 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgb/ixgb_ee.c   |    2 +-
 drivers/net/ixgb/ixgb_main.c |   12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
index ba41d2a..8bc9716 100644
--- a/drivers/net/ixgb/ixgb_ee.c
+++ b/drivers/net/ixgb/ixgb_ee.c
@@ -120,7 +120,7 @@ ixgb_shift_out_bits(struct ixgb_hw *hw,
 
 		mask = mask >> 1;
 
-	} while(mask);
+	} while (mask);
 
 	/* We leave the "DI" bit set to "0" when we leave this routine. */
 	eecd_reg &= ~IXGB_EECD_DI;
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index f7dda04..dffb853 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1274,7 +1274,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 
 	i = tx_ring->next_to_use;
 
-	while(len) {
+	while (len) {
 		buffer_info = &tx_ring->buffer_info[i];
 		size = min(len, IXGB_MAX_DATA_PER_TXD);
 		/* Workaround for premature desc write-backs
@@ -1305,7 +1305,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 		len = frag->size;
 		offset = 0;
 
-		while(len) {
+		while (len) {
 			buffer_info = &tx_ring->buffer_info[i];
 			size = min(len, IXGB_MAX_DATA_PER_TXD);
 
@@ -1362,7 +1362,7 @@ ixgb_tx_queue(struct ixgb_adapter *adapter, int count, int vlan_id,int tx_flags)
 
 	i = tx_ring->next_to_use;
 
-	while(count--) {
+	while (count--) {
 		buffer_info = &tx_ring->buffer_info[i];
 		tx_desc = IXGB_TX_DESC(*tx_ring, i);
 		tx_desc->buff_addr = cpu_to_le64(buffer_info->dma);
@@ -1781,7 +1781,7 @@ ixgb_clean_tx_irq(struct ixgb_adapter *adapter)
 	eop = tx_ring->buffer_info[i].next_to_watch;
 	eop_desc = IXGB_TX_DESC(*tx_ring, eop);
 
-	while(eop_desc->status & IXGB_TX_DESC_STATUS_DD) {
+	while (eop_desc->status & IXGB_TX_DESC_STATUS_DD) {
 
 		for (cleaned = false; !cleaned; ) {
 			tx_desc = IXGB_TX_DESC(*tx_ring, i);
@@ -1912,7 +1912,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 	rx_desc = IXGB_RX_DESC(*rx_ring, i);
 	buffer_info = &rx_ring->buffer_info[i];
 
-	while(rx_desc->status & IXGB_RX_DESC_STATUS_DD) {
+	while (rx_desc->status & IXGB_RX_DESC_STATUS_DD) {
 		struct sk_buff *skb, *next_skb;
 		u8 status;
 
@@ -2053,7 +2053,7 @@ ixgb_alloc_rx_buffers(struct ixgb_adapter *adapter)
 
 
 	/* leave three descriptors unused */
-	while(--cleancount > 2) {
+	while (--cleancount > 2) {
 		/* recycle! its good for you */
 		skb = buffer_info->skb;
 		if (skb) {

