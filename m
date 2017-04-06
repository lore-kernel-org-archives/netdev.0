From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 03/19] batman-adv: Fix unbalanced braces
	around else statement
Date: Thu,  6 Apr 2017 16:07:25 +0200
Message-ID: <20170406140741.30745-4-sw@simonwunderlich.de>
References: <20170406140741.30745-1-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20170406140741.30745-1-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 net/batman-adv/translation-table.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 6077a87d46f0..a75f0a640bcd 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -2253,12 +2253,13 @@ batadv_tt_global_del_roaming(struct batadv_priv *bat_priv,
 		/* its the last one, mark for roaming. */
 		tt_global_entry->common.flags |= BATADV_TT_CLIENT_ROAM;
 		tt_global_entry->roam_at = jiffies;
-	} else
+	} else {
 		/* there is another entry, we can simply delete this
 		 * one and can still use the other one.
 		 */
 		batadv_tt_global_del_orig_node(bat_priv, tt_global_entry,
 					       orig_node, message);
+	}
 }
 
 /**
@@ -2314,10 +2315,11 @@ static void batadv_tt_global_del(struct batadv_priv *bat_priv,
 		/* local entry exists, case 2: client roamed to us. */
 		batadv_tt_global_del_orig_list(tt_global_entry);
 		batadv_tt_global_free(bat_priv, tt_global_entry, message);
-	} else
+	} else {
 		/* no local entry exists, case 1: check for roaming */
 		batadv_tt_global_del_roaming(bat_priv, tt_global_entry,
 					     orig_node, message);
+	}
 
 out:
 	if (tt_global_entry)
-- 
2.11.0
