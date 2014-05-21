From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/25] netfilter: nf_tables: relax string validation of NFTA_CHAIN_TYPE
Date: Wed, 21 May 2014 11:43:08 +0200
Message-ID: <1400665402-5835-11-git-send-email-pablo@netfilter.org>
References: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1400665402-5835-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira <pablo@netfilter.org>

Use NLA_STRING for consistency with other string attributes in
nf_tables.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 1d0c174..a5ca900 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -541,7 +541,7 @@ static const struct nla_policy nft_chain_policy[NFTA_CHAIN_MAX + 1] = {
 				    .len = NFT_CHAIN_MAXNAMELEN - 1 },
 	[NFTA_CHAIN_HOOK]	= { .type = NLA_NESTED },
 	[NFTA_CHAIN_POLICY]	= { .type = NLA_U32 },
-	[NFTA_CHAIN_TYPE]	= { .type = NLA_NUL_STRING },
+	[NFTA_CHAIN_TYPE]	= { .type = NLA_STRING },
 	[NFTA_CHAIN_COUNTERS]	= { .type = NLA_NESTED },
 };
 
-- 
1.7.10.4

