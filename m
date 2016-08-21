From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] netfilter: nft_hash: fix non static symbol warning
Date: Sun, 21 Aug 2016 15:21:10 +0000
Message-ID: <1471792870-16895-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyj.lk@gmail.com>, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        Wei Yongjun <weiyongjun1@huawei.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35351 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753198AbcHUPVg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 Aug 2016 11:21:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes the following sparse warning:

net/netfilter/nft_hash.c:40:25: warning:
 symbol 'nft_hash_policy' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 net/netfilter/nft_hash.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index b82ff29..e090aee 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -37,7 +37,7 @@ static void nft_hash_eval(const struct nft_expr *expr,
 				 priv->modulus);
 }
 
-const struct nla_policy nft_hash_policy[NFTA_HASH_MAX + 1] = {
+static const struct nla_policy nft_hash_policy[NFTA_HASH_MAX + 1] = {
 	[NFTA_HASH_SREG]	= { .type = NLA_U32 },
 	[NFTA_HASH_DREG]	= { .type = NLA_U32 },
 	[NFTA_HASH_LEN]		= { .type = NLA_U32 },
