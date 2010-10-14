From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 5/8] tg3: Cleanup tg3_alloc_rx_skb()
Date: Thu, 14 Oct 2010 13:37:42 -0700
Message-ID: <1287088665-22135-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2061 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756016Ab0JNUiG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Oct 2010 16:38:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

src_map is no longer used in tg3_alloc_rx_skb().  Remove it.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f2d96dd..84530d9 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4573,12 +4573,11 @@ static int tg3_alloc_rx_skb(struct tg3 *tp, struct tg3_rx_prodring_set *tpr,
 			    u32 opaque_key, u32 dest_idx_unmasked)
 {
 	struct tg3_rx_buffer_desc *desc;
-	struct ring_info *map, *src_map;
+	struct ring_info *map;
 	struct sk_buff *skb;
 	dma_addr_t mapping;
 	int skb_size, dest_idx;
 
-	src_map = NULL;
 	switch (opaque_key) {
 	case RXD_OPAQUE_RING_STD:
 		dest_idx = dest_idx_unmasked & tp->rx_std_ring_mask;
-- 
1.7.2.2


