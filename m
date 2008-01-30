From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] unexport ip6_find_1stfragopt
Date: Wed, 30 Jan 2008 22:02:33 +0200
Message-ID: <20080130200233.GV29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:40704 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758711AbYA3UB7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 15:01:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the no longer used 
EXPORT_SYMBOL_GPL(ip6_find_1stfragopt).

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
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

