From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 45/50] netfilter: nf_tables: constify struct nft_ctx * parameter in nft_trans_alloc()
Date: Wed,  7 Dec 2016 22:52:51 +0100
Message-ID: <1481147576-5690-46-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60342 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933463AbcLGVx6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:58 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 02EF252B94
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:57 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id E7B1FDA865
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:56 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DAB4EDA843
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:54 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Context is not modified by nft_trans_alloc(), so constify it.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_tables_api.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index b04d4ee1d533..b42059795819 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -111,8 +111,8 @@ static void nft_ctx_init(struct nft_ctx *ctx,
 	ctx->seq	= nlh->nlmsg_seq;
 }
 
-static struct nft_trans *nft_trans_alloc(struct nft_ctx *ctx, int msg_type,
-					 u32 size)
+static struct nft_trans *nft_trans_alloc(const struct nft_ctx *ctx,
+					 int msg_type, u32 size)
 {
 	struct nft_trans *trans;
 
-- 
2.1.4
