From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: [PATCH net-next 4/9] net/mlx5_core: Remove unused dev cap enum fields
Date: Tue,  2 Dec 2014 12:26:14 +0200
Message-ID: <1417515979-22418-5-git-send-email-eli@mellanox.com>
References: <1417515979-22418-1-git-send-email-eli@mellanox.com>
Cc: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1417515979-22418-1-git-send-email-eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

These enumerations are not used so remove them.

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 include/linux/mlx5/device.h | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 1d67fd32e71c..ea4f1c46f761 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -219,23 +219,15 @@ enum {
 };
 
 enum {
-	MLX5_DEV_CAP_FLAG_RC		= 1LL <<  0,
-	MLX5_DEV_CAP_FLAG_UC		= 1LL <<  1,
-	MLX5_DEV_CAP_FLAG_UD		= 1LL <<  2,
 	MLX5_DEV_CAP_FLAG_XRC		= 1LL <<  3,
-	MLX5_DEV_CAP_FLAG_SRQ		= 1LL <<  6,
 	MLX5_DEV_CAP_FLAG_BAD_PKEY_CNTR	= 1LL <<  8,
 	MLX5_DEV_CAP_FLAG_BAD_QKEY_CNTR	= 1LL <<  9,
 	MLX5_DEV_CAP_FLAG_APM		= 1LL << 17,
 	MLX5_DEV_CAP_FLAG_ATOMIC	= 1LL << 18,
 	MLX5_DEV_CAP_FLAG_BLOCK_MCAST	= 1LL << 23,
-	MLX5_DEV_CAP_FLAG_ON_DMND_PG	= 1LL << 24,
 	MLX5_DEV_CAP_FLAG_CQ_MODER	= 1LL << 29,
 	MLX5_DEV_CAP_FLAG_RESIZE_CQ	= 1LL << 30,
-	MLX5_DEV_CAP_FLAG_RESIZE_SRQ	= 1LL << 32,
 	MLX5_DEV_CAP_FLAG_DCT		= 1LL << 37,
-	MLX5_DEV_CAP_FLAG_REMOTE_FENCE	= 1LL << 38,
-	MLX5_DEV_CAP_FLAG_TLP_HINTS	= 1LL << 39,
 	MLX5_DEV_CAP_FLAG_SIG_HAND_OVER	= 1LL << 40,
 	MLX5_DEV_CAP_FLAG_CMDIF_CSUM	= 3LL << 46,
 };
-- 
2.1.3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
