From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] unexport ip6_find_1stfragopt
Date: Fri, 22 Feb 2008 21:58:11 +0200
Message-ID: <20080222195811.GC1409@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:52678 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762145AbYBVT67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2008 14:58:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the no longer used 
EXPORT_SYMBOL_GPL(ip6_find_1stfragopt).

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

This patch has been sent on:
- 30 Jan 2008

961bcbf7370019e35920a75d2d34c91b71708dfe 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 15c4f6c..ca707c0 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -595,7 +595,6 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
 
 	return offset;
 }
-EXPORT_SYMBOL_GPL(ip6_find_1stfragopt);
 
 static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 {


