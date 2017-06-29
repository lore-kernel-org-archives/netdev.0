From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/29] netfilter: nft_rt: make local functions static
Date: Fri, 30 Jun 2017 00:53:02 +0200
Message-ID: <1498776807-11124-5-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: stephen hemminger <stephen@networkplumber.org>

Resolves warnings:
net/netfilter/nft_rt.c:26:6: warning: no previous prototype for ‘nft_rt_get_eval’ [-Wmissing-prototypes]
net/netfilter/nft_rt.c:75:5: warning: no previous prototype for ‘nft_rt_get_init’ [-Wmissing-prototypes]
net/netfilter/nft_rt.c:106:5: warning: no previous prototype for ‘nft_rt_get_dump’ [-Wmissing-prototypes]

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_rt.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nft_rt.c b/net/netfilter/nft_rt.c
index d3eb640bc784..c7383d8f88d0 100644
--- a/net/netfilter/nft_rt.c
+++ b/net/netfilter/nft_rt.c
@@ -23,9 +23,9 @@ struct nft_rt {
 	enum nft_registers	dreg:8;
 };
 
-void nft_rt_get_eval(const struct nft_expr *expr,
-		     struct nft_regs *regs,
-		     const struct nft_pktinfo *pkt)
+static void nft_rt_get_eval(const struct nft_expr *expr,
+			    struct nft_regs *regs,
+			    const struct nft_pktinfo *pkt)
 {
 	const struct nft_rt *priv = nft_expr_priv(expr);
 	const struct sk_buff *skb = pkt->skb;
@@ -72,9 +72,9 @@ const struct nla_policy nft_rt_policy[NFTA_RT_MAX + 1] = {
 	[NFTA_RT_KEY]		= { .type = NLA_U32 },
 };
 
-int nft_rt_get_init(const struct nft_ctx *ctx,
-		    const struct nft_expr *expr,
-		    const struct nlattr * const tb[])
+static int nft_rt_get_init(const struct nft_ctx *ctx,
+			   const struct nft_expr *expr,
+			   const struct nlattr * const tb[])
 {
 	struct nft_rt *priv = nft_expr_priv(expr);
 	unsigned int len;
@@ -103,8 +103,8 @@ int nft_rt_get_init(const struct nft_ctx *ctx,
 					   NFT_DATA_VALUE, len);
 }
 
-int nft_rt_get_dump(struct sk_buff *skb,
-		    const struct nft_expr *expr)
+static int nft_rt_get_dump(struct sk_buff *skb,
+			   const struct nft_expr *expr)
 {
 	const struct nft_rt *priv = nft_expr_priv(expr);
 
-- 
2.1.4

