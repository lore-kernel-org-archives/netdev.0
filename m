From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH net-next] netfilter: remove dead code
Date: Tue, 29 Sep 2015 21:25:00 -0300
Message-ID: <1443572700-29705-1-git-send-email-fbl@redhat.com>
Cc: Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34234 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbbI3AZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2015 20:25:05 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id 16B4AC0A147F
	for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 00:25:05 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove __nf_conntrack_find() from headers.
Fixes: dcd93ed4cd1 ("netfilter: nf_conntrack: remove dead code"

Signed-off-by: Flavio Leitner <fbl@redhat.com>
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
2.4.3
