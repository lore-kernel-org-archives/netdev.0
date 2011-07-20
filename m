From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 25/47] vlan: kill vlan_hwaccel_receive_skb
Date: Wed, 20 Jul 2011 16:54:27 +0200
Message-ID: <1311173689-17419-26-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21529 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418Ab1GTOzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:43 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/if_vlan.h |   13 -------------
 1 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 69391cc..3996713 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -203,19 +203,6 @@ static inline int vlan_hwaccel_rx(struct sk_buff *skb,
 }
 
 /**
- * vlan_hwaccel_receive_skb - netif_receive_skb wrapper for VLAN RX acceleration
- * @skb: buffer
- * @grp: vlan group
- * @vlan_tci: VLAN TCI as received from the card
- */
-static inline int vlan_hwaccel_receive_skb(struct sk_buff *skb,
-					   struct vlan_group *grp,
-					   u16 vlan_tci)
-{
-	return __vlan_hwaccel_rx(skb, grp, vlan_tci, 1);
-}
-
-/**
  * vlan_insert_tag - regular VLAN tag inserting
  * @skb: skbuff to tag
  * @vlan_tci: VLAN TCI to insert
-- 
1.7.6

