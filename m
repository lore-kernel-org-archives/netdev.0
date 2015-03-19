From: kbuild test robot <fengguang.wu@intel.com>
Subject: [PATCH jkirsher-next-queue] net/mlx4_en: mlx4_en_set_tx_maxrate()
 can be static
Date: Thu, 19 Mar 2015 08:51:27 +0800
Message-ID: <20150319005127.GA57239@snb>
References: <201503190816.FI64cKgW%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201503190816.FI64cKgW%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 en_netdev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index d8dc3f9..763ba26 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2379,7 +2379,7 @@ static netdev_features_t mlx4_en_features_check(struct sk_buff *skb,
 }
 #endif
 
-int mlx4_en_set_tx_maxrate(struct net_device *dev, int queue_index, u32 maxrate)
+static int mlx4_en_set_tx_maxrate(struct net_device *dev, int queue_index, u32 maxrate)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_tx_ring *tx_ring = priv->tx_ring[queue_index];
