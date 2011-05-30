From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 10/17] batman-adv: Remove casts from type x
	to type x
Date: Mon, 30 May 2011 09:22:55 +0200
Message-ID: <1306740182-2665-11-git-send-email-sven@narfation.org>
References: <1306740182-2665-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1306740182-2665-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Casting from pointer like 'struct orig_node*' to 'struct orig_node *'
doesn't provide any additional functionality and can be savely removed.

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/unicast.c |    2 +-
 net/batman-adv/vis.c     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index e2deb44..82717fd 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -295,7 +295,7 @@ int unicast_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv)
 
 	/* get routing information */
 	if (is_multicast_ether_addr(ethhdr->h_dest)) {
-		orig_node = (struct orig_node *)gw_get_selected_orig(bat_priv);
+		orig_node = gw_get_selected_orig(bat_priv);
 		if (orig_node)
 			goto find_router;
 	}
diff --git a/net/batman-adv/vis.c b/net/batman-adv/vis.c
index adb0327..b48954c 100644
--- a/net/batman-adv/vis.c
+++ b/net/batman-adv/vis.c
@@ -621,7 +621,7 @@ static int generate_vis_packet(struct bat_priv *bat_priv)
 	struct hlist_head *head;
 	struct orig_node *orig_node;
 	struct neigh_node *router;
-	struct vis_info *info = (struct vis_info *)bat_priv->my_vis_info;
+	struct vis_info *info = bat_priv->my_vis_info;
 	struct vis_packet *packet = (struct vis_packet *)info->skb_packet->data;
 	struct vis_info_entry *entry;
 	struct tt_local_entry *tt_local_entry;
-- 
1.7.5.3
