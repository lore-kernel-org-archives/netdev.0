From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/29] netfilter: nft_hash: fix non static symbol warning
Date: Mon,  5 Sep 2016 12:58:29 +0200
Message-ID: <1473073124-5015-15-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35246 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933530AbcIEK7K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 06:59:10 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 13BB82EFEC6
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:09 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id F31DC1153FB
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:08 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 010251150C6
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:04 +0200 (CEST)
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>

Fixes the following sparse warning:

net/netfilter/nft_hash.c:40:25: warning:
 symbol 'nft_hash_policy' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
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
-- 
2.1.4
