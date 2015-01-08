From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 10/15] batman-adv: checkpatch - Please don't use multiple blank lines
Date: Thu,  8 Jan 2015 16:15:15 +0100
Message-ID: <1420730120-9844-11-git-send-email-antonio@meshcoding.com>
References: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:28897 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbbAHPZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 10:25:19 -0500
In-Reply-To: <1420730120-9844-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/bat_iv_ogm.c            | 2 --
 net/batman-adv/bitarray.c              | 1 -
 net/batman-adv/bridge_loop_avoidance.c | 7 -------
 net/batman-adv/fragmentation.c         | 1 -
 net/batman-adv/main.c                  | 1 -
 net/batman-adv/originator.c            | 1 -
 net/batman-adv/originator.h            | 1 -
 net/batman-adv/routing.c               | 1 -
 net/batman-adv/soft-interface.c        | 1 -
 net/batman-adv/sysfs.c                 | 1 -
 net/batman-adv/translation-table.c     | 1 -
 11 files changed, 18 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 73209f3..4dd7c40 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -26,7 +26,6 @@
 #include "bat_algo.h"
 #include "network-coding.h"
 
-
 /**
  * enum batadv_dup_status - duplicate status
  * @BATADV_NO_DUP: the packet is a duplicate
@@ -1362,7 +1361,6 @@ out:
 	return ret;
 }
 
-
 /**
  * batadv_iv_ogm_process_per_outif - process a batman iv OGM for an outgoing if
  * @skb: the skb containing the OGM
diff --git a/net/batman-adv/bitarray.c b/net/batman-adv/bitarray.c
index 9586750..e3da07a 100644
--- a/net/batman-adv/bitarray.c
+++ b/net/batman-adv/bitarray.c
@@ -29,7 +29,6 @@ static void batadv_bitmap_shift_left(unsigned long *seq_bits, int32_t n)
 	bitmap_shift_left(seq_bits, seq_bits, n, BATADV_TQ_LOCAL_WINDOW_SIZE);
 }
 
-
 /* receive and process one packet within the sequence number window.
  *
  * returns:
diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 0f0ca43..4fc6cab 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -69,7 +69,6 @@ static inline uint32_t batadv_choose_backbone_gw(const void *data,
 	return hash % size;
 }
 
-
 /* compares address and vid of two backbone gws */
 static int batadv_compare_backbone_gw(const struct hlist_node *node,
 				      const void *data2)
@@ -662,7 +661,6 @@ static int batadv_handle_announce(struct batadv_priv *bat_priv,
 	if (unlikely(!backbone_gw))
 		return 1;
 
-
 	/* handle as ANNOUNCE frame */
 	backbone_gw->lasttime = jiffies;
 	crc = ntohs(*((__be16 *)(&an_addr[4])));
@@ -849,7 +847,6 @@ static int batadv_check_claim_group(struct batadv_priv *bat_priv,
 	return 2;
 }
 
-
 /**
  * batadv_bla_process_claim
  * @bat_priv: the bat priv with all the soft interface information
@@ -1347,8 +1344,6 @@ out:
 	return ret;
 }
 
-
-
 /**
  * batadv_bla_is_backbone_gw_orig
  * @bat_priv: the bat priv with all the soft interface information
@@ -1390,7 +1385,6 @@ bool batadv_bla_is_backbone_gw_orig(struct batadv_priv *bat_priv, uint8_t *orig,
 	return false;
 }
 
-
 /**
  * batadv_bla_is_backbone_gw
  * @skb: the frame to be checked
@@ -1480,7 +1474,6 @@ int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb,
 	if (!atomic_read(&bat_priv->bridge_loop_avoidance))
 		goto allow;
 
-
 	if (unlikely(atomic_read(&bat_priv->bla.num_requests)))
 		/* don't allow broadcasts while requests are in flight */
 		if (is_multicast_ether_addr(ethhdr->h_dest) && is_bcast)
diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index 00f9e14..3d1dcaa 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -23,7 +23,6 @@
 #include "hard-interface.h"
 #include "soft-interface.h"
 
-
 /**
  * batadv_frag_clear_chain - delete entries in the fragment buffer chain
  * @head: head of chain with entries.
diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 2cdd25a..d4079cd 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -41,7 +41,6 @@
 #include "network-coding.h"
 #include "fragmentation.h"
 
-
 /* List manipulations on hardif_list have to be rtnl_lock()'ed,
  * list traversals just rcu-locked
  */
diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index bea8198..90e805a 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -797,7 +797,6 @@ batadv_purge_orig_ifinfo(struct batadv_priv *bat_priv,
 	return ifinfo_purged;
 }
 
-
 /**
  * batadv_purge_orig_neighbors - purges neighbors from originator
  * @bat_priv: the bat priv with all the soft interface information
diff --git a/net/batman-adv/originator.h b/net/batman-adv/originator.h
index db3a9ed..aa4a436 100644
--- a/net/batman-adv/originator.h
+++ b/net/batman-adv/originator.h
@@ -70,7 +70,6 @@ batadv_orig_node_vlan_get(struct batadv_orig_node *orig_node,
 			  unsigned short vid);
 void batadv_orig_node_vlan_free_ref(struct batadv_orig_node_vlan *orig_vlan);
 
-
 /* hashfunction to choose an entry in a hash table of given size
  * hash algorithm from http://en.wikipedia.org/wiki/Hash_table
  */
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 6648f32..139d2f6 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -292,7 +292,6 @@ out:
 	return ret;
 }
 
-
 int batadv_recv_icmp_packet(struct sk_buff *skb,
 			    struct batadv_hard_iface *recv_if)
 {
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 5467955..5ec31d7 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -36,7 +36,6 @@
 #include "bridge_loop_avoidance.h"
 #include "network-coding.h"
 
-
 static int batadv_get_settings(struct net_device *dev, struct ethtool_cmd *cmd);
 static void batadv_get_drvinfo(struct net_device *dev,
 			       struct ethtool_drvinfo *info);
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index f40cb04..a75dc12 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -151,7 +151,6 @@ ssize_t batadv_show_##_name(struct kobject *kobj,			\
 	static BATADV_ATTR(_name, _mode, batadv_show_##_name,		\
 			   batadv_store_##_name)
 
-
 #define BATADV_ATTR_SIF_STORE_UINT(_name, _min, _max, _post_func)	\
 ssize_t batadv_store_##_name(struct kobject *kobj,			\
 			     struct attribute *attr, char *buff,	\
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 38a804e..84e6f01 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1780,7 +1780,6 @@ static void batadv_tt_global_del(struct batadv_priv *bat_priv,
 		batadv_tt_global_del_roaming(bat_priv, tt_global_entry,
 					     orig_node, message);
 
-
 out:
 	if (tt_global_entry)
 		batadv_tt_global_entry_free_ref(tt_global_entry);
-- 
2.2.1
