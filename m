From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 03/16] batman-adv: Fix names in kerneldoc of functions
Date: Wed,  3 Feb 2016 10:18:24 +0800
Message-ID: <1454465917-13332-4-git-send-email-a__3593.62278036333$1454467275$gmane$org@unstable.cc>
References: <1454465917-13332-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:33739 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932451AbcBCClG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 21:41:06 -0500
In-Reply-To: <1454465917-13332-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/originator.c        | 4 ++--
 net/batman-adv/packet.h            | 2 +-
 net/batman-adv/send.c              | 2 +-
 net/batman-adv/soft-interface.c    | 2 +-
 net/batman-adv/translation-table.c | 4 ++--
 5 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index fe578f75c391..dfeebc89ed9a 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -375,7 +375,7 @@ out:
 
 /**
  * batadv_neigh_ifinfo_get - find the ifinfo from an neigh_node
- * @neigh_node: the neigh node to be queried
+ * @neigh: the neigh node to be queried
  * @if_outgoing: the interface for which the ifinfo should be acquired
  *
  * The object is returned with refcounter increased by 1.
@@ -408,7 +408,7 @@ batadv_neigh_ifinfo_get(struct batadv_neigh_node *neigh,
 
 /**
  * batadv_neigh_ifinfo_new - search and possibly create an neigh_ifinfo object
- * @neigh_node: the neigh node to be queried
+ * @neigh: the neigh node to be queried
  * @if_outgoing: the interface for which the ifinfo should be acquired
  *
  * Returns NULL in case of failure or the neigh_ifinfo object for the
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 6d5b17841ff5..72fd5b0a4183 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -494,7 +494,7 @@ struct batadv_tvlv_gateway_data {
  * struct batadv_tvlv_tt_data - tt data propagated through the tt tvlv container
  * @flags: translation table flags (see batadv_tt_data_flags)
  * @ttvn: translation table version number
- * @vlan_num: number of announced VLANs. In the TVLV this struct is followed by
+ * @num_vlan: number of announced VLANs. In the TVLV this struct is followed by
  *  one batadv_tvlv_tt_vlan_data object per announced vlan
  */
 struct batadv_tvlv_tt_data {
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 782fa33ec296..3fbf7910c4d1 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -211,7 +211,7 @@ static bool batadv_send_skb_prepare_unicast(struct sk_buff *skb,
  *  unicast 4addr header
  * @bat_priv: the bat priv with all the soft interface information
  * @skb: the skb containing the payload to encapsulate
- * @orig_node: the destination node
+ * @orig: the destination node
  * @packet_subtype: the unicast 4addr packet subtype to use
  *
  * Returns false if the payload could not be encapsulated or true otherwise.
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index ac4d08de5df4..c923e3c7b6ac 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -480,7 +480,7 @@ out:
 /**
  * batadv_softif_vlan_free_ref - decrease the vlan object refcounter and
  *  possibly free it
- * @softif_vlan: the vlan object to release
+ * @vlan: the vlan object to release
  */
 void batadv_softif_vlan_free_ref(struct batadv_softif_vlan *vlan)
 {
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 3ccede59c842..7d8fc90c9e38 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -3366,8 +3366,8 @@ out:
  * batadv_tt_update_orig - update global translation table with new tt
  *  information received via ogms
  * @bat_priv: the bat priv with all the soft interface information
- * @orig: the orig_node of the ogm
- * @tt_vlan: pointer to the first tvlv VLAN entry
+ * @orig_node: the orig_node of the ogm
+ * @tt_buff: pointer to the first tvlv VLAN entry
  * @tt_num_vlan: number of tvlv VLAN entries
  * @tt_change: pointer to the first entry in the TT buffer
  * @tt_num_changes: number of tt changes inside the tt buffer
-- 
2.7.0
