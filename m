From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 02/47] vlan: finish removing vlan_find_dev from public header
Date: Wed, 20 Jul 2011 16:54:04 +0200
Message-ID: <1311173689-17419-3-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57156 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541Ab1GTOzA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:00 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

else case remained forgotten.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/if_vlan.h |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index bc03e40..cfb0cf2 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -135,12 +135,6 @@ vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
 	       unsigned int vlan_tci);
 
 #else
-static inline struct net_device *vlan_find_dev(struct net_device *real_dev,
-					       u16 vlan_id)
-{
-	return NULL;
-}
-
 static inline struct net_device *vlan_dev_real_dev(const struct net_device *dev)
 {
 	BUG();
-- 
1.7.6

