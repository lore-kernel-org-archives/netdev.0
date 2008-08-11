From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-next-2.6 [PATCH 1/1] skbuff: Small NiT
Date: Mon, 11 Aug 2008 19:48:27 +0200
Message-ID: <20080811174827.GC5065@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:48246 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751177AbYHKRsm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2008 13:48:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skbuff: Code readability NiT

Inserting a space between the `-' improved the C readability (some languages
allow hyphens within functions and variable names, which is confusing).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
--
 include/linux/skbuff.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -901,7 +901,7 @@ extern unsigned char *__pskb_pull_tail(struct sk_buff *skb, int delta);
 static inline unsigned char *__pskb_pull(struct sk_buff *skb, unsigned int len)
 {
 	if (len > skb_headlen(skb) &&
-	    !__pskb_pull_tail(skb, len-skb_headlen(skb)))
+	    !__pskb_pull_tail(skb, len - skb_headlen(skb)))
 		return NULL;
 	skb->len -= len;
 	return skb->data += len;
@@ -918,7 +918,7 @@ static inline int pskb_may_pull(struct sk_buff *skb, unsigned int len)
 		return 1;
 	if (unlikely(len > skb->len))
 		return 0;
-	return __pskb_pull_tail(skb, len-skb_headlen(skb)) != NULL;
+	return __pskb_pull_tail(skb, len - skb_headlen(skb)) != NULL;
 }
 
 /**
@@ -1321,7 +1321,7 @@ static inline int skb_padto(struct sk_buff *skb, unsigned int len)
 	unsigned int size = skb->len;
 	if (likely(size >= len))
 		return 0;
-	return skb_pad(skb, len-size);
+	return skb_pad(skb, len - size);
 }
 
 static inline int skb_add_data(struct sk_buff *skb,
-- 
