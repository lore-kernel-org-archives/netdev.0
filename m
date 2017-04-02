From: Arushi Singhal <arushisinghal19971997@gmail.com>
Subject: [PATCH 2/4] net: bridge: Remove exceptional & on function name
Date: Sun,  2 Apr 2017 14:52:13 +0530
Message-ID: <20170402092215.22792-2-arushisinghal19971997@gmail.com>
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
 net/bridge/netfilter/nft_meta_bridge.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/netfilter/nft_meta_bridge.c b/net/bridge/netfilter/nft_meta_bridge.c
index 5974dbc1ea24..bb63c9aed55d 100644
--- a/net/bridge/netfilter/nft_meta_bridge.c
+++ b/net/bridge/netfilter/nft_meta_bridge.c
@@ -111,7 +111,7 @@ nft_meta_bridge_select_ops(const struct nft_ctx *ctx,
 static struct nft_expr_type nft_meta_bridge_type __read_mostly = {
 	.family         = NFPROTO_BRIDGE,
 	.name           = "meta",
-	.select_ops     = &nft_meta_bridge_select_ops,
+	.select_ops     = nft_meta_bridge_select_ops,
 	.policy         = nft_meta_policy,
 	.maxattr        = NFTA_META_MAX,
 	.owner          = THIS_MODULE,
-- 
2.11.0
