From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] neighbour: reduce exports
Date: Tue, 15 Aug 2006 12:56:30 -0700
Message-ID: <20060815125630.42ca9451@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:44932 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932656AbWHOT4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 15:56:33 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There are several symbols only used by rtnetlink and since it can
not be a module, there is no reason to export them.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 net/core/neighbour.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

--- net-2.6.19.orig/net/core/neighbour.c
+++ net-2.6.19/net/core/neighbour.c
@@ -889,7 +889,7 @@ out_unlock_bh:
 	return rc;
 }
 
-static __inline__ void neigh_update_hhs(struct neighbour *neigh)
+static void neigh_update_hhs(struct neighbour *neigh)
 {
 	struct hh_cache *hh;
 	void (*update)(struct hh_cache*, struct net_device*, unsigned char *) =
@@ -2721,7 +2721,6 @@ void neigh_sysctl_unregister(struct neig
 #endif	/* CONFIG_SYSCTL */
 
 EXPORT_SYMBOL(__neigh_event_send);
-EXPORT_SYMBOL(neigh_add);
 EXPORT_SYMBOL(neigh_changeaddr);
 EXPORT_SYMBOL(neigh_compat_output);
 EXPORT_SYMBOL(neigh_connected_output);
@@ -2741,11 +2740,8 @@ EXPORT_SYMBOL(neigh_table_clear);
 EXPORT_SYMBOL(neigh_table_init);
 EXPORT_SYMBOL(neigh_table_init_no_netlink);
 EXPORT_SYMBOL(neigh_update);
-EXPORT_SYMBOL(neigh_update_hhs);
 EXPORT_SYMBOL(pneigh_enqueue);
 EXPORT_SYMBOL(pneigh_lookup);
-EXPORT_SYMBOL(neightbl_dump_info);
-EXPORT_SYMBOL(neightbl_set);
 
 #ifdef CONFIG_ARPD
 EXPORT_SYMBOL(neigh_app_ns);
