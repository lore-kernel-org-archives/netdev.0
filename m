From: Christopher Covington <cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: [PATCH] net: mlx5: Fix Kconfig help text
Date: Fri,  9 Dec 2016 16:53:05 -0500
Message-ID: <20161209215306.721-1-cov@codeaurora.org>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Christopher Covington <cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Since the following commit, Infiniband and Ethernet have not been
mutually exclusive.

Fixes: 4aa17b28 mlx5: Enable mutual support for IB and Ethernet

Signed-off-by: Christopher Covington <cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index aae4688..521cfdb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -18,8 +18,6 @@ config MLX5_CORE_EN
 	default n
 	---help---
 	  Ethernet support in Mellanox Technologies ConnectX-4 NIC.
-	  Ethernet and Infiniband support in ConnectX-4 are currently mutually
-	  exclusive.
 
 config MLX5_CORE_EN_DCB
 	bool "Data Center Bridging (DCB) Support"
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc. Qualcomm Technologies, Inc. is a member of the Code Aurora
Forum, a Linux Foundation Collaborative Project.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
