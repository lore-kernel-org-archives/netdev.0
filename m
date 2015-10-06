From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 14/14] rocker: return -EOPNOTSUPP for undefined world ops
Date: Tue,  6 Oct 2015 09:51:53 +0200
Message-ID: <1444117913-10386-15-git-send-email-jiri@resnulli.us>
References: <1444117913-10386-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com,
	David.Laight@ACULAB.COM, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38711 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbbJFHwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 03:52:16 -0400
Received: by wiclk2 with SMTP id lk2so146694896wic.1
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 00:52:15 -0700 (PDT)
In-Reply-To: <1444117913-10386-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suggested-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker_main.c | 32 +++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index a2fd7a6..451964b 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1649,7 +1649,7 @@ static int rocker_world_port_attr_stp_state_set(struct rocker_port *rocker_port,
 	struct rocker_world *world = rocker_port->world;
 
 	if (!world->ops->port_attr_stp_state_set)
-		return 0;
+		return -EOPNOTSUPP;
 	return world->ops->port_attr_stp_state_set(rocker_port->world_port_priv,
 						   state, trans);
 }
@@ -1662,7 +1662,7 @@ rocker_world_port_attr_bridge_flags_set(struct rocker_port *rocker_port,
 	struct rocker_world *world = rocker_port->world;
 
 	if (!world->ops->port_attr_bridge_flags_set)
-		return 0;
+		return -EOPNOTSUPP;
 	return world->ops->port_attr_bridge_flags_set(rocker_port->world_port_priv,
 						      brport_flags, trans);
 }
@@ -1674,7 +1674,7 @@ rocker_world_port_attr_bridge_flags_get(const struct rocker_port *rocker_port,
 	struct rocker_world *world = rocker_port->world;
 
 	if (!world->ops->port_attr_bridge_flags_get)
-		return 0;
+		return -EOPNOTSUPP;
 	return world->ops->port_attr_bridge_flags_get(rocker_port->world_port_priv,
 						      p_brport_flags);
 }
@@ -1687,7 +1687,7 @@ rocker_world_port_obj_vlan_add(struct rocker_port *rocker_port,
 	struct rocker_world *world = rocker_port->world;
 
 	if (!world->ops->port_obj_vlan_add)
-		return 0;
+		return -EOPNOTSUPP;
 	return world->ops->port_obj_vlan_add(rocker_port->world_port_priv,
 					     vlan, trans);
 }
@@ -1699,7 +1699,7 @@ rocker_world_port_obj_vlan_del(struct rocker_port *rocker_port,
 	struct rocker_world *world = rocker_port->world;
 
 	if (!world->ops->port_obj_vlan_del)
-		return 0;
+		return -EOPNOTSUPP;
 	return world->ops->port_obj_vlan_del(rocker_port->world_port_priv,
 					     vlan);
 }
@@ -1712,7 +1712,7 @@ rocker_world_port_obj_vlan_dump(const struct rocker_port *rocker_port,
 	struct rocker_world *world = rocker_port->world;
 
 	if (!world->ops->port_obj_vlan_dump)
-		return 0;
+		return -EOPNOTSUPP;
 	return world->ops->port_obj_vlan_dump(rocker_port->world_port_priv,
 					      vlan, cb);
 }
@@ -1725,7 +1725,7 @@ rocker_world_port_obj_fib4_add(struct rocker_port *rocker_port,
 	struct rocker_world *world = rocker_port->world;
 
 	if (!world->ops->port_obj_fib4_add)
-		return 0;
+		return -EOPNOTSUPP;
 	return world->ops->port_obj_fib4_add(rocker_port->world_port_priv,
 					     fib4, trans);
 }
@@ -1737,7 +1737,7 @@ rocker_world_port_obj_fib4_del(struct rocker_port *rocker_port,
 	struct rocker_world *world = rocker_port->world;
 
 	if (!world->ops->port_obj_fib4_del)
-		return 0;
+		return -EOPNOTSUPP;
 	return world->ops->port_obj_fib4_del(rocker_port->world_port_priv,
 					     fib4);
 }
@@ -1750,7 +1750,7 @@ rocker_world_port_obj_fdb_add(struct rocker_port *rocker_port,
 	struct rocker_world *world = rocker_port->world;
 
 	if (!world->ops->port_obj_fdb_add)
-		return 0;
+		return -EOPNOTSUPP;
 	return world->ops->port_obj_fdb_add(rocker_port->world_port_priv,
 					    fdb, trans);
 }
@@ -1762,7 +1762,7 @@ rocker_world_port_obj_fdb_del(struct rocker_port *rocker_port,
 	struct rocker_world *world = rocker_port->world;
 
 	if (!world->ops->port_obj_fdb_del)
-		return 0;
+		return -EOPNOTSUPP;
 	return world->ops->port_obj_fdb_del(rocker_port->world_port_priv,
 					    fdb);
 }
@@ -1775,7 +1775,7 @@ rocker_world_port_obj_fdb_dump(const struct rocker_port *rocker_port,
 	struct rocker_world *world = rocker_port->world;
 
 	if (!world->ops->port_obj_fdb_dump)
-		return 0;
+		return -EOPNOTSUPP;
 	return world->ops->port_obj_fdb_dump(rocker_port->world_port_priv,
 					     fdb, cb);
 }
@@ -1786,7 +1786,7 @@ static int rocker_world_port_master_linked(struct rocker_port *rocker_port,
 	struct rocker_world *world = rocker_port->world;
 
 	if (!world->ops->port_master_linked)
-		return 0;
+		return -EOPNOTSUPP;
 	return world->ops->port_master_linked(rocker_port->world_port_priv,
 					      master);
 }
@@ -1797,7 +1797,7 @@ static int rocker_world_port_master_unlinked(struct rocker_port *rocker_port,
 	struct rocker_world *world = rocker_port->world;
 
 	if (!world->ops->port_master_unlinked)
-		return 0;
+		return -EOPNOTSUPP;
 	return world->ops->port_master_unlinked(rocker_port->world_port_priv,
 						master);
 }
@@ -1808,7 +1808,7 @@ static int rocker_world_port_neigh_update(struct rocker_port *rocker_port,
 	struct rocker_world *world = rocker_port->world;
 
 	if (!world->ops->port_neigh_update)
-		return 0;
+		return -EOPNOTSUPP;
 	return world->ops->port_neigh_update(rocker_port->world_port_priv, n);
 }
 
@@ -1818,7 +1818,7 @@ static int rocker_world_port_neigh_destroy(struct rocker_port *rocker_port,
 	struct rocker_world *world = rocker_port->world;
 
 	if (!world->ops->port_neigh_destroy)
-		return 0;
+		return -EOPNOTSUPP;
 	return world->ops->port_neigh_destroy(rocker_port->world_port_priv, n);
 }
 
@@ -1829,7 +1829,7 @@ static int rocker_world_port_ev_mac_vlan_seen(struct rocker_port *rocker_port,
 	struct rocker_world *world = rocker_port->world;
 
 	if (!world->ops->port_ev_mac_vlan_seen)
-		return 0;
+		return -EOPNOTSUPP;
 	return world->ops->port_ev_mac_vlan_seen(rocker_port->world_port_priv,
 						 addr, vlan_id);
 }
-- 
1.9.3
