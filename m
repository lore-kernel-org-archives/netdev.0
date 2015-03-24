From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/5 net-next] rhashtable: Mark internal/private inline functions as such
Date: Tue, 24 Mar 2015 14:18:18 +0100
Message-ID: <a3b4d5eb5faa88c62ff79f8e85b39c729c2bb2e0.1427202823.git.tgraf@suug.ch>
References: <cover.1427202823.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34697 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbbCXNS3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 09:18:29 -0400
In-Reply-To: <cover.1427202823.git.tgraf@suug.ch>
In-Reply-To: <cover.1427202823.git.tgraf@suug.ch>
References: <cover.1427202823.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index f89cda0..0e1f975 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -539,6 +539,7 @@ restart:
 	return NULL;
 }
 
+/* Internal function, please use rhashtable_insert_fast() instead */
 static inline int __rhashtable_insert_fast(
 	struct rhashtable *ht, const void *key, struct rhash_head *obj,
 	const struct rhashtable_params params)
@@ -711,6 +712,7 @@ static inline int rhashtable_lookup_insert_key(
 	return __rhashtable_insert_fast(ht, key, obj, params);
 }
 
+/* Internal function, please use rhashtable_remove_fast() instead */
 static inline int __rhashtable_remove_fast(
 	struct rhashtable *ht, struct bucket_table *tbl,
 	struct rhash_head *obj, const struct rhashtable_params params)
-- 
1.9.3
