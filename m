From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 7/8] mlx4_en: Added vlan_features support
Date: Tue, 02 Jun 2009 12:28:29 +0300
Message-ID: <4A24F0BD.2070506@mellanox.co.il>
References: <4A0AB34A.10100@mellanox.co.il><4A1948D7.8010504@mellanox.co.il><4A1A57AA.1080209@mellanox.co.il> <20090525.014435.203274473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tziporet Koren <tziporet@mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:50285 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758919AbZFBIhq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 04:37:46 -0400
In-Reply-To: <20090525.014435.203274473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_netdev.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 37e4d30..0a7e78a 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -1038,7 +1038,9 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	 * Set driver features
 	 */
 	dev->features |= NETIF_F_SG;
+	dev->vlan_features |= NETIF_F_SG;
 	dev->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+	dev->vlan_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 	dev->features |= NETIF_F_HIGHDMA;
 	dev->features |= NETIF_F_HW_VLAN_TX |
 			 NETIF_F_HW_VLAN_RX |
@@ -1048,6 +1050,8 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	if (mdev->LSO_support) {
 		dev->features |= NETIF_F_TSO;
 		dev->features |= NETIF_F_TSO6;
+		dev->vlan_features |= NETIF_F_TSO;
+		dev->vlan_features |= NETIF_F_TSO6;
 	}
 
 	mdev->pndev[port] = dev;
-- 
1.6.0


