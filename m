From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v3 3/6] openvswitch: add NETIF_F_HW_VLAN_STAG_TX to internal dev
Date: Fri,  7 Oct 2016 18:07:38 +0200
Message-ID: <7b35511358205011078613fb21cfef28aceb233e.1475855896.git.jbenc@redhat.com>
References: <cover.1475855896.git.jbenc@redhat.com>
Cc: pravin shelar <pshelar@ovn.org>, Eric Garver <e@erig.me>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59796 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936361AbcJGQHz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Oct 2016 12:07:55 -0400
In-Reply-To: <cover.1475855896.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The internal device does support 802.1AD offloading.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v3: new in v3
---
 net/openvswitch/vport-internal_dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 95c36147a6e1..e7da29021b38 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -176,7 +176,7 @@ static void do_setup(struct net_device *netdev)
 
 	netdev->vlan_features = netdev->features;
 	netdev->hw_enc_features = netdev->features;
-	netdev->features |= NETIF_F_HW_VLAN_CTAG_TX;
+	netdev->features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
 	netdev->hw_features = netdev->features & ~NETIF_F_LLTX;
 
 	eth_hw_addr_random(netdev);
-- 
1.8.3.1
