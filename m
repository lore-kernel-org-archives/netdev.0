From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 3/6] net/mlx5e: Disallow changing name-space for VF representors
Date: Fri,  4 Nov 2016 01:48:44 +0200
Message-ID: <1478216927-31328-4-git-send-email-saeedm@mellanox.com>
References: <1478216927-31328-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37670 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933614AbcKCXuN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 19:50:13 -0400
In-Reply-To: <1478216927-31328-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

VF reps should be altogether on the same NS as they were created.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 7fe6559..bf1c09c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -308,7 +308,7 @@ static void mlx5e_build_rep_netdev(struct net_device *netdev)
 	netdev->switchdev_ops = &mlx5e_rep_switchdev_ops;
 #endif
 
-	netdev->features	 |= NETIF_F_VLAN_CHALLENGED | NETIF_F_HW_TC;
+	netdev->features	 |= NETIF_F_VLAN_CHALLENGED | NETIF_F_HW_TC | NETIF_F_NETNS_LOCAL;
 	netdev->hw_features      |= NETIF_F_HW_TC;
 
 	eth_hw_addr_random(netdev);
-- 
2.7.4
