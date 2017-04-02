From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH 3/4] net: ipv4: Remove exceptional & on function name
Date: Sun,  2 Apr 2017 14:52:14 +0530
Message-ID: <20170402092215.22792-3-arushisinghal19971997@gmail.com>
References: <20170402092215.22792-1-arushisinghal19971997@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Arushi Singhal <arushisinghal19971997@gmail.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34221 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751457AbdDBJWd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 05:22:33 -0400
In-Reply-To: <20170402092215.22792-1-arushisinghal19971997@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove & from function pointers to conform to the style found elsewhere
in the file. Done using the following semantic patch

// <smpl>
@r@
identifier f;
@@

f(...) { ... }
@@
identifier r.f;
@@

- &f
+ f
// </smpl>

Signed-off-by: Arushi Singhal <arushisinghal19971997@gmail.com>
---
 net/ipv4/netfilter/nft_fib_ipv4.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/netfilter/nft_fib_ipv4.c b/net/ipv4/netfilter/nft_fib_ipv4.c
index 2981291910dd..cc4f9da97677 100644
--- a/net/ipv4/netfilter/nft_fib_ipv4.c
+++ b/net/ipv4/netfilter/nft_fib_ipv4.c
@@ -212,7 +212,7 @@ nft_fib4_select_ops(const struct nft_ctx *ctx,
 
 static struct nft_expr_type nft_fib4_type __read_mostly = {
 	.name		= "fib",
-	.select_ops	= &nft_fib4_select_ops,
+	.select_ops	= nft_fib4_select_ops,
 	.policy		= nft_fib_policy,
 	.maxattr	= NFTA_FIB_MAX,
 	.family		= NFPROTO_IPV4,
-- 
2.11.0
