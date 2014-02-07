From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/18] netfilter: nft_ct: fix missing NFT_CT_L3PROTOCOL key in validity checks
Date: Fri,  7 Feb 2014 18:41:35 +0100
Message-ID: <1391794904-4017-10-git-send-email-pablo@netfilter.org>
References: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1391794904-4017-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

The key was missing in the list of valid keys, add it.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_ct.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index feaf0f3..46e2754 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -226,6 +226,7 @@ static int nft_ct_init_validate_get(const struct nft_expr *expr,
 		if (tb[NFTA_CT_DIRECTION] != NULL)
 			return -EINVAL;
 		break;
+	case NFT_CT_L3PROTOCOL:
 	case NFT_CT_PROTOCOL:
 	case NFT_CT_SRC:
 	case NFT_CT_DST:
-- 
1.7.10.4

