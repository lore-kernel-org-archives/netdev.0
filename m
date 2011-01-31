From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 4/9] batman-adv: Remove dangling declaration of hash_remove_element
Date: Mon, 31 Jan 2011 16:20:46 +0100
Message-ID: <1296487251-12552-5-git-send-email-sven@narfation.org>
References: <1296487251-12552-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:42655 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755997Ab1AaPVP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 10:21:15 -0500
In-Reply-To: <1296487251-12552-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/hash.h |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/hash.h b/net/batman-adv/hash.h
index 09216ad..2f508e6 100644
--- a/net/batman-adv/hash.h
+++ b/net/batman-adv/hash.h
@@ -49,11 +49,6 @@ struct hashtable_t {
 /* allocates and clears the hash */
 struct hashtable_t *hash_new(int size);
 
-/* remove element if you already found the element you want to delete and don't
- * need the overhead to find it again with hash_remove().  But usually, you
- * don't want to use this function, as it fiddles with hash-internals. */
-void *hash_remove_element(struct hashtable_t *hash, struct element_t *elem);
-
 /* free only the hashtable and the hash itself. */
 void hash_destroy(struct hashtable_t *hash);
 
-- 
1.7.2.3

