From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/17] netfilter: fix spelling errors
Date: Mon, 24 Nov 2014 14:27:44 +0100
Message-ID: <1416835674-11871-8-git-send-email-pablo@netfilter.org>
References: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44863 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932100AbaKXNZz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2014 08:25:55 -0500
In-Reply-To: <1416835674-11871-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: stephen hemminger <stephen@networkplumber.org>

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_helper.c |    2 +-
 net/netfilter/nf_tables_api.c       |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 5b3eae7..bd9d315 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -250,7 +250,7 @@ out:
 }
 EXPORT_SYMBOL_GPL(__nf_ct_try_assign_helper);
 
-/* appropiate ct lock protecting must be taken by caller */
+/* appropriate ct lock protecting must be taken by caller */
 static inline int unhelp(struct nf_conntrack_tuple_hash *i,
 			 const struct nf_conntrack_helper *me)
 {
diff --git a/net/netfilter/nf_tables_api.c b/net/netfilter/nf_tables_api.c
index 65eb2a1..1ffb253 100644
--- a/net/netfilter/nf_tables_api.c
+++ b/net/netfilter/nf_tables_api.c
@@ -2477,7 +2477,7 @@ static int nf_tables_getset(struct sock *nlsk, struct sk_buff *skb,
 	const struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	int err;
 
-	/* Verify existance before starting dump */
+	/* Verify existence before starting dump */
 	err = nft_ctx_init_from_setattr(&ctx, skb, nlh, nla);
 	if (err < 0)
 		return err;
-- 
1.7.10.4
