From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: [PATCH net-next 0/3] mlx5: fix warnings
Date: Fri, 21 Apr 2017 11:15:55 -0700
Message-ID: <20170421181558.5414-1-sthemmin@microsoft.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Stephen Hemminger <sthemmin-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

While looking for sparse and warning output in another driver,
I saw several trivial warnings from MLX5 driver. This patch
series fixes them.

Stephen Hemminger (3):
  mlx5: hide unused functions
  mlx5: fix warning about missing prototype
  mlx5: fix space waste from ethtool descriptions

 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 208 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 206 +-------------------
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c    |  24 +--
 5 files changed, 224 insertions(+), 216 deletions(-)

-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
