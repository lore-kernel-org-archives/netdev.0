From: David Lamparter <equinox@diac24.net>
Subject: [PATCH 2/2] net: vlan: remove unused struct vlan_group->hlist
Date: Sat,  5 Nov 2011 17:54:15 +0100
Message-ID: <1320512055-1231037-3-git-send-email-equinox@diac24.net>
References: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
Cc: David Lamparter <equinox@diac24.net>,
	Patrick McHardy <kaber@trash.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:38704 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753716Ab1KERDU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Nov 2011 13:03:20 -0400
In-Reply-To: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"hlist" in struct vlan_group has no reference in the entire kernel code.
just remove it.

Signed-off-by: David Lamparter <equinox@diac24.net>
Cc: Patrick McHardy <kaber@trash.net>
---
 include/linux/if_vlan.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 522b464..bb604bf 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -96,7 +96,6 @@ struct vlan_group {
 					    * the vlan is attached to.
 					    */
 	unsigned int		nr_vlans;
-	struct hlist_node	hlist;	/* linked list */
 	struct net_device **vlan_devices_arrays[VLAN_N_PROTOCOL]
 						[VLAN_GROUP_ARRAY_SPLIT_PARTS];
 	struct rcu_head		rcu;
-- 
1.7.7
