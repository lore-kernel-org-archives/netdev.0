From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] af_key: Replace comma with semicolon
Date: Fri, 30 May 2014 21:18:12 +0530
Message-ID: <20140530154812.GA4119@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:57343 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753685AbaE3Ps2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 11:48:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces a comma between expression statements by a semicolon.

A simplified version of the semantic patch that performs this
transformation is as follows:

// <smpl>
@r@
expression e1,e2,e;
type T;
identifier i;
@@

 e1
-,
+;
 e2;
// </smpl>

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
 net/key/af_key.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index b47f8e5..ba2a2f9 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -2541,7 +2541,7 @@ static int pfkey_migrate(struct sock *sk, struct sk_buff *skb,
 		sel.sport_mask = htons(0xffff);
 
 	/* set destination address info of selector */
-	sa = ext_hdrs[SADB_EXT_ADDRESS_DST - 1],
+	sa = ext_hdrs[SADB_EXT_ADDRESS_DST - 1];
 	pfkey_sadb_addr2xfrm_addr(sa, &sel.daddr);
 	sel.prefixlen_d = sa->sadb_address_prefixlen;
 	sel.proto = pfkey_proto_to_xfrm(sa->sadb_address_proto);
-- 
1.9.1
