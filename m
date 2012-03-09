From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/4] net: Use bool in skbuff.h helper functions.
Date: Fri, 09 Mar 2012 14:36:27 -0800 (PST)
Message-ID: <20120309.143627.781339523401035125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51119 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755822Ab2CIWg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 17:36:28 -0500
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q29MaRbt018623
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 9 Mar 2012 14:36:28 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In particular do this for skb_is_nonlinear(), skb_is_gso(), and
skb_is_gso_v6().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 79ef820..8dc8257 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1173,7 +1173,7 @@ static inline struct sk_buff *__skb_dequeue_tail(struct sk_buff_head *list)
 }
 
 
-static inline int skb_is_nonlinear(const struct sk_buff *skb)
+static inline bool skb_is_nonlinear(const struct sk_buff *skb)
 {
 	return skb->data_len;
 }
@@ -2469,12 +2469,12 @@ static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
 }
 #endif
 
-static inline int skb_is_gso(const struct sk_buff *skb)
+static inline bool skb_is_gso(const struct sk_buff *skb)
 {
 	return skb_shinfo(skb)->gso_size;
 }
 
-static inline int skb_is_gso_v6(const struct sk_buff *skb)
+static inline bool skb_is_gso_v6(const struct sk_buff *skb)
 {
 	return skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6;
 }
-- 
1.7.6.5
