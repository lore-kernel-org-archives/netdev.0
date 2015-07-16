From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] net: remove skb_frag_add_head
Date: Thu, 16 Jul 2015 21:50:50 +0200
Message-ID: <ff65957de15c76dc2e3a939d513bfe50c8b52855.1437076234.git.jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49626 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755404AbbGPTvR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2015 15:51:17 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id 7D9038AE72
	for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 19:51:17 +0000 (UTC)
Received: from griffin.upir.cz (ovpn-204-45.brq.redhat.com [10.40.204.45])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t6GJpG8F022357
	for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 15:51:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's not used anywhere.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/linux/skbuff.h | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d6cdd6e87d53..a5395be9fe7b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2671,12 +2671,6 @@ static inline void skb_frag_list_init(struct sk_buff *skb)
 	skb_shinfo(skb)->frag_list = NULL;
 }
 
-static inline void skb_frag_add_head(struct sk_buff *skb, struct sk_buff *frag)
-{
-	frag->next = skb_shinfo(skb)->frag_list;
-	skb_shinfo(skb)->frag_list = frag;
-}
-
 #define skb_walk_frags(skb, iter)	\
 	for (iter = skb_shinfo(skb)->frag_list; iter; iter = iter->next)
 
-- 
1.8.3.1
