From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 03/17] batman-adv: Close two alignment holes in batadv_hard_iface
Date: Wed,  9 Nov 2016 23:25:52 +0100
Message-ID: <20161109222606.29039-4-sw@simonwunderlich.de>
References: <20161109222606.29039-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven.eckelmann@open-mesh.com>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:55489 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752796AbcKIW0a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 17:26:30 -0500
In-Reply-To: <20161109222606.29039-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven.eckelmann@open-mesh.com>

Signed-off-by: Sven Eckelmann <sven.eckelmann@open-mesh.com>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/types.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 673a22e..c9db184 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -123,8 +123,8 @@ struct batadv_hard_iface_bat_v {
  * @list: list node for batadv_hardif_list
  * @if_num: identificator of the interface
  * @if_status: status of the interface for batman-adv
- * @net_dev: pointer to the net_device
  * @num_bcasts: number of payload re-broadcasts on this interface (ARQ)
+ * @net_dev: pointer to the net_device
  * @hardif_obj: kobject of the per interface sysfs "mesh" directory
  * @refcount: number of contexts the object is used
  * @batman_adv_ptype: packet type describing packets that should be processed by
@@ -141,8 +141,8 @@ struct batadv_hard_iface {
 	struct list_head list;
 	s16 if_num;
 	char if_status;
-	struct net_device *net_dev;
 	u8 num_bcasts;
+	struct net_device *net_dev;
 	struct kobject *hardif_obj;
 	struct kref refcount;
 	struct packet_type batman_adv_ptype;
-- 
2.10.1
