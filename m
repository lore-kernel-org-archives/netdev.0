From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/2] netfilter: nft_lookup: add missing attribute validation for NFTA_LOOKUP_SET_ID
Date: Tue, 10 Feb 2015 06:34:34 +0100
Message-ID: <1423546474-3539-3-git-send-email-pablo@netfilter.org>
References: <1423546474-3539-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1423546474-3539-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_lookup.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nft_lookup.c b/net/netfilter/nft_lookup.c
index 6404a72..9615b8b 100644
--- a/net/netfilter/nft_lookup.c
+++ b/net/netfilter/nft_lookup.c
@@ -39,6 +39,7 @@ static void nft_lookup_eval(const struct nft_expr *expr,
 
 static const struct nla_policy nft_lookup_policy[NFTA_LOOKUP_MAX + 1] = {
 	[NFTA_LOOKUP_SET]	= { .type = NLA_STRING },
+	[NFTA_LOOKUP_SET_ID]	= { .type = NLA_U32 },
 	[NFTA_LOOKUP_SREG]	= { .type = NLA_U32 },
 	[NFTA_LOOKUP_DREG]	= { .type = NLA_U32 },
 };
-- 
1.7.10.4

