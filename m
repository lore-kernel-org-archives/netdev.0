From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/13] netfilter: nft_hash: add missing NFTA_HASH_OFFSET's nla_policy
Date: Fri, 21 Oct 2016 12:12:16 +0200
Message-ID: <1477044743-18948-7-git-send-email-pablo@netfilter.org>
References: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

Missing the nla_policy description will also miss the validation check
in kernel.

Fixes: 70ca767ea1b2 ("netfilter: nft_hash: Add hash offset value")
Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_hash.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index 09473b415b95..baf694de3935 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -44,6 +44,7 @@ static const struct nla_policy nft_hash_policy[NFTA_HASH_MAX + 1] = {
 	[NFTA_HASH_LEN]		= { .type = NLA_U32 },
 	[NFTA_HASH_MODULUS]	= { .type = NLA_U32 },
 	[NFTA_HASH_SEED]	= { .type = NLA_U32 },
+	[NFTA_HASH_OFFSET]	= { .type = NLA_U32 },
 };
 
 static int nft_hash_init(const struct nft_ctx *ctx,
-- 
2.1.4

