From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 3/3] openvswitch: add NETIF_F_HW_VLAN_STAG_TX to internal dev
Date: Mon, 10 Oct 2016 17:02:44 +0200
Message-ID: <688ddda46c331c1b85450d6f28b1441af6cee1de.1476111550.git.jbenc@redhat.com>
References: <cover.1476111550.git.jbenc@redhat.com>
Cc: pravin shelar <pshelar@ovn.org>, Eric Garver <e@erig.me>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49058 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753106AbcJJPDH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Oct 2016 11:03:07 -0400
In-Reply-To: <cover.1476111550.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The internal device does support 802.1AD offloading since 018c1dda5ff1
("openvswitch: 802.1AD Flow handling, actions, vlan parsing, netlink
attributes").

Signed-off-by: Jiri Benc <jbenc@redhat.com>
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
