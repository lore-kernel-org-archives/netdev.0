From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 14/20] batman-adv: Prefix hash local static functions with batadv_
Date: Mon, 25 Jun 2012 08:54:38 +0200
Message-ID: <1340607284-29950-15-git-send-email-ordex@autistici.org>
References: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:30470 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754751Ab2FYGyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 02:54:49 -0400
In-Reply-To: <1340607284-29950-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

All non-static symbols of batman-adv were prefixed with batadv_ to avoid
collisions with other symbols of the kernel. Other symbols of batman-adv
should use the same prefix to keep the naming scheme consistent.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/hash.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/hash.c b/net/batman-adv/hash.c
index e39f8f4..1fb961c 100644
--- a/net/batman-adv/hash.c
+++ b/net/batman-adv/hash.c
@@ -21,7 +21,7 @@
 #include "hash.h"
 
 /* clears the hash */
-static void hash_init(struct hashtable_t *hash)
+static void batadv_hash_init(struct hashtable_t *hash)
 {
 	uint32_t i;
 
@@ -58,7 +58,7 @@ struct hashtable_t *batadv_hash_new(uint32_t size)
 		goto free_table;
 
 	hash->size = size;
-	hash_init(hash);
+	batadv_hash_init(hash);
 	return hash;
 
 free_table:
-- 
1.7.9.4
