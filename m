From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH 4/4] net: ipv6: Remove exceptional & on function name
Date: Sun,  2 Apr 2017 14:52:15 +0530
Message-ID: <20170402092215.22792-4-arushisinghal19971997@gmail.com>
References: <20170402092215.22792-1-arushisinghal19971997@gmail.com>
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Arushi Singhal <arushisinghal19971997@gmail.com>
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170402092215.22792-1-arushisinghal19971997@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 net/ipv6/netfilter/nft_fib_ipv6.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/nft_fib_ipv6.c b/net/ipv6/netfilter/nft_fib_ipv6.c
index 765facf03d45..8cb8d79bab79 100644
--- a/net/ipv6/netfilter/nft_fib_ipv6.c
+++ b/net/ipv6/netfilter/nft_fib_ipv6.c
@@ -246,7 +246,7 @@ nft_fib6_select_ops(const struct nft_ctx *ctx,
 
 static struct nft_expr_type nft_fib6_type __read_mostly = {
 	.name		= "fib",
-	.select_ops	= &nft_fib6_select_ops,
+	.select_ops	= nft_fib6_select_ops,
 	.policy		= nft_fib_policy,
 	.maxattr	= NFTA_FIB_MAX,
 	.family		= NFPROTO_IPV6,
-- 
2.11.0
