From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] xfrm4_beet_input(): fix an if()
Date: Sat, 2 Feb 2008 23:16:35 +0200
Message-ID: <20080202211635.GF9375@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:55264 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763962AbYBBVQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Feb 2008 16:16:22 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A bug every C programmer makes at some point in time...

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
3125760a05c6e97097882a810dc1c5342296aae9 
diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index e093a7b..b47030b 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -102,7 +102,7 @@ static int xfrm4_beet_input(struct xfrm_state *x, struct sk_buff *skb)
 
 		XFRM_MODE_SKB_CB(skb)->protocol = ph->nexthdr;
 
-		if (!pskb_may_pull(skb, phlen));
+		if (!pskb_may_pull(skb, phlen))
 			goto out;
 		__skb_pull(skb, phlen);
 	}

