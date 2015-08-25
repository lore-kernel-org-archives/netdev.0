From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 06/15] batman-adv: Remove batadv_ types forward declarations
Date: Tue, 25 Aug 2015 13:02:30 +0200
Message-ID: <1440500559-28368-7-git-send-email-antonio@meshcoding.com>
References: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:48005 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755388AbbHYLD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Aug 2015 07:03:56 -0400
In-Reply-To: <1440500559-28368-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

main.h is included in every file and is the only way to access types.h.
This makes forward declarations for all types defined in types.h
unnecessary.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/bridge_loop_avoidance.h | 3 ---
 net/batman-adv/debugfs.h               | 1 -
 net/batman-adv/gateway_common.h        | 1 -
 net/batman-adv/icmp_socket.h           | 1 -
 net/batman-adv/multicast.h             | 2 --
 net/batman-adv/network-coding.h        | 4 ----
 net/batman-adv/routing.h               | 4 ----
 net/batman-adv/send.h                  | 3 ---
 net/batman-adv/soft-interface.h        | 4 ----
 net/batman-adv/sysfs.h                 | 2 --
 net/batman-adv/translation-table.h     | 2 --
 11 files changed, 27 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index 449f2f1..025152b 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -22,9 +22,6 @@
 
 #include <linux/types.h>
 
-struct batadv_hard_iface;
-struct batadv_orig_node;
-struct batadv_priv;
 struct seq_file;
 struct sk_buff;
 
diff --git a/net/batman-adv/debugfs.h b/net/batman-adv/debugfs.h
index 187acdc..80ab8d6 100644
--- a/net/batman-adv/debugfs.h
+++ b/net/batman-adv/debugfs.h
@@ -22,7 +22,6 @@
 
 #include <linux/kconfig.h>
 
-struct batadv_hard_iface;
 struct net_device;
 
 #define BATADV_DEBUGFS_SUBDIR "batman_adv"
diff --git a/net/batman-adv/gateway_common.h b/net/batman-adv/gateway_common.h
index bd5c812..ab893e3 100644
--- a/net/batman-adv/gateway_common.h
+++ b/net/batman-adv/gateway_common.h
@@ -22,7 +22,6 @@
 
 #include <linux/types.h>
 
-struct batadv_priv;
 struct net_device;
 
 enum batadv_gw_modes {
diff --git a/net/batman-adv/icmp_socket.h b/net/batman-adv/icmp_socket.h
index 7de7fce..e937143 100644
--- a/net/batman-adv/icmp_socket.h
+++ b/net/batman-adv/icmp_socket.h
@@ -23,7 +23,6 @@
 #include <linux/types.h>
 
 struct batadv_icmp_header;
-struct batadv_priv;
 
 #define BATADV_ICMP_SOCKET "socket"
 
diff --git a/net/batman-adv/multicast.h b/net/batman-adv/multicast.h
index beb6e56..8f3cb04 100644
--- a/net/batman-adv/multicast.h
+++ b/net/batman-adv/multicast.h
@@ -20,8 +20,6 @@
 
 #include "main.h"
 
-struct batadv_orig_node;
-struct batadv_priv;
 struct sk_buff;
 
 /**
diff --git a/net/batman-adv/network-coding.h b/net/batman-adv/network-coding.h
index 5b79aa8..8f6d4ad 100644
--- a/net/batman-adv/network-coding.h
+++ b/net/batman-adv/network-coding.h
@@ -22,11 +22,7 @@
 
 #include <linux/types.h>
 
-struct batadv_nc_node;
-struct batadv_neigh_node;
 struct batadv_ogm_packet;
-struct batadv_orig_node;
-struct batadv_priv;
 struct net_device;
 struct seq_file;
 struct sk_buff;
diff --git a/net/batman-adv/routing.h b/net/batman-adv/routing.h
index 3c185a1f..204bbe4 100644
--- a/net/batman-adv/routing.h
+++ b/net/batman-adv/routing.h
@@ -22,10 +22,6 @@
 
 #include <linux/types.h>
 
-struct batadv_hard_iface;
-struct batadv_neigh_node;
-struct batadv_orig_node;
-struct batadv_priv;
 struct sk_buff;
 
 bool batadv_check_management_packet(struct sk_buff *skb,
diff --git a/net/batman-adv/send.h b/net/batman-adv/send.h
index 33ef6fc..82059f2 100644
--- a/net/batman-adv/send.h
+++ b/net/batman-adv/send.h
@@ -25,9 +25,6 @@
 
 #include "packet.h"
 
-struct batadv_hard_iface;
-struct batadv_orig_node;
-struct batadv_priv;
 struct sk_buff;
 struct work_struct;
 
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-interface.h
index 578e8a6..8e82176 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -22,10 +22,6 @@
 
 #include <net/rtnetlink.h>
 
-struct batadv_hard_iface;
-struct batadv_orig_node;
-struct batadv_priv;
-struct batadv_softif_vlan;
 struct net_device;
 struct sk_buff;
 
diff --git a/net/batman-adv/sysfs.h b/net/batman-adv/sysfs.h
index 2294583..6197442 100644
--- a/net/batman-adv/sysfs.h
+++ b/net/batman-adv/sysfs.h
@@ -23,8 +23,6 @@
 #include <linux/sysfs.h>
 #include <linux/types.h>
 
-struct batadv_priv;
-struct batadv_softif_vlan;
 struct kobject;
 struct net_device;
 
diff --git a/net/batman-adv/translation-table.h b/net/batman-adv/translation-table.h
index 9b82d5d..abd8e11 100644
--- a/net/batman-adv/translation-table.h
+++ b/net/batman-adv/translation-table.h
@@ -22,8 +22,6 @@
 
 #include <linux/types.h>
 
-struct batadv_orig_node;
-struct batadv_priv;
 struct net_device;
 struct seq_file;
 
-- 
2.5.0
