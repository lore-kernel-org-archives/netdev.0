From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next] switchdev: Put export declaration in the right place
Date: Mon, 15 Aug 2016 14:51:54 +0300
Message-ID: <1471261914-32183-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37520 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752850AbcHOLwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 07:52:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move exporting of switchdev_port_same_parent_id to be right
below it and not elsewhere.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reported-by: Ido Schimmel <idosch@mellanox.com>
---
 net/switchdev/switchdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index a5fc9dd..9e90129 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -1306,6 +1306,7 @@ bool switchdev_port_same_parent_id(struct net_device *a,
 
 	return netdev_phys_item_id_same(&a_attr.u.ppid, &b_attr.u.ppid);
 }
+EXPORT_SYMBOL_GPL(switchdev_port_same_parent_id);
 
 static u32 switchdev_port_fwd_mark_get(struct net_device *dev,
 				       struct net_device *group_dev)
@@ -1323,7 +1324,6 @@ static u32 switchdev_port_fwd_mark_get(struct net_device *dev,
 
 	return dev->ifindex;
 }
-EXPORT_SYMBOL_GPL(switchdev_port_same_parent_id);
 
 static void switchdev_port_fwd_mark_reset(struct net_device *group_dev,
 					  u32 old_mark, u32 *reset_mark)
-- 
2.3.7
