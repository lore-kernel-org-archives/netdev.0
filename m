From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH] net-timestamp: Update skb_complete_tx_timestamp comment
Date: Fri,  7 Aug 2015 09:32:21 -0700
Message-ID: <1438965141-26099-1-git-send-email-bpoirier@suse.com>
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36231 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932143AbbHGQdP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Aug 2015 12:33:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After "62bccb8 net-timestamp: Make the clone operation stand-alone from phy
timestamping" the hwtstamps parameter of skb_complete_tx_timestamp() may no
longer be NULL.

Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/linux/skbuff.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d6cdd6e..22b6d9c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2884,11 +2884,11 @@ static inline bool skb_defer_rx_timestamp(struct sk_buff *skb)
  *
  * PHY drivers may accept clones of transmitted packets for
  * timestamping via their phy_driver.txtstamp method. These drivers
- * must call this function to return the skb back to the stack, with
- * or without a timestamp.
+ * must call this function to return the skb back to the stack with a
+ * timestamp.
  *
  * @skb: clone of the the original outgoing packet
- * @hwtstamps: hardware time stamps, may be NULL if not available
+ * @hwtstamps: hardware time stamps
  *
  */
 void skb_complete_tx_timestamp(struct sk_buff *skb,
-- 
2.4.3
