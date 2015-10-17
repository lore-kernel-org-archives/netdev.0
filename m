From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/35] netfilter: remove dead code
Date: Sat, 17 Oct 2015 13:32:40 +0200
Message-ID: <1445081590-2924-6-git-send-email-pablo@netfilter.org>
References: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48349 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752564AbbJQL0R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 07:26:17 -0400
In-Reply-To: <1445081590-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@sysclose.org>

Remove __nf_conntrack_find() from headers.

Fixes: dcd93ed4cd1 ("netfilter: nf_conntrack: remove dead code")
Signed-off-by: Flavio Leitner <fbl@sysclose.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index d642f68..fde4068 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -183,10 +183,6 @@ void *nf_ct_alloc_hashtable(unsigned int *sizep, int nulls);
 
 void nf_ct_free_hashtable(void *hash, unsigned int size);
 
-struct nf_conntrack_tuple_hash *
-__nf_conntrack_find(struct net *net, u16 zone,
-		    const struct nf_conntrack_tuple *tuple);
-
 int nf_conntrack_hash_check_insert(struct nf_conn *ct);
 bool nf_ct_delete(struct nf_conn *ct, u32 pid, int report);
 
-- 
2.1.4
