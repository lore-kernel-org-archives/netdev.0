From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/15] netfilter: nft_hash: indent rhashtable parameters
Date: Thu, 26 Mar 2015 13:06:55 +0100
Message-ID: <1427371622-4466-9-git-send-email-pablo@netfilter.org>
References: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38354 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752600AbbCZMDd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2015 08:03:33 -0400
In-Reply-To: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Improve readability by indenting the parameter initialization.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_hash.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index a517f84..e35f0b2 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -173,10 +173,10 @@ static unsigned int nft_hash_privsize(const struct nlattr * const nla[])
 }
 
 static const struct rhashtable_params nft_hash_params = {
-	.head_offset = offsetof(struct nft_hash_elem, node),
-	.key_offset = offsetof(struct nft_hash_elem, key),
-	.hashfn = jhash,
-	.automatic_shrinking = true,
+	.head_offset		= offsetof(struct nft_hash_elem, node),
+	.key_offset		= offsetof(struct nft_hash_elem, key),
+	.hashfn			= jhash,
+	.automatic_shrinking	= true,
 };
 
 static int nft_hash_init(const struct nft_set *set,
@@ -187,7 +187,7 @@ static int nft_hash_init(const struct nft_set *set,
 	struct rhashtable_params params = nft_hash_params;
 
 	params.nelem_hint = desc->size ?: NFT_HASH_ELEMENT_HINT;
-	params.key_len = set->klen;
+	params.key_len	  = set->klen;
 
 	return rhashtable_init(&priv->ht, &params);
 }
-- 
1.7.10.4
