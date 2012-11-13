From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 02/11] batman-adv: fix wrong spinlock inline comment
Date: Tue, 13 Nov 2012 10:15:30 +0100
Message-ID: <1352798139-19458-3-git-send-email-ordex@autistici.org>
References: <1352798139-19458-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:52574 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752959Ab2KMJQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 04:16:32 -0500
In-Reply-To: <1352798139-19458-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/types.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 8ce16c1..e8a1b18 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -303,7 +303,7 @@ struct batadv_priv {
 	struct hlist_head forw_bcast_list;
 	struct batadv_hashtable *orig_hash;
 	spinlock_t forw_bat_list_lock; /* protects forw_bat_list */
-	spinlock_t forw_bcast_list_lock; /* protects  */
+	spinlock_t forw_bcast_list_lock; /* protects forw_bcast_list */
 	struct delayed_work orig_work;
 	struct batadv_hard_iface __rcu *primary_if;  /* rcu protected pointer */
 	struct batadv_algo_ops *bat_algo_ops;
-- 
1.8.0
