From: Michael Opdenacker <michael.opdenacker-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: [PATCH] mlx5: remove unused MLX5_DEBUG param in Kconfig
Date: Fri,  6 Sep 2013 13:49:22 +0200
Message-ID: <1378468162-3109-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Michael Opdenacker <michael.opdenacker-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch proposes to remove the MLX5_DEBUG kernel configuration
parameter defined in drivers/net/ethernet/mellanox/mlx5/core/Kconfig,
but used nowhere in the makefiles and source code.

This could also be fixed by using this parameter,
but this may be a leftover from driver development...

Signed-off-by: Michael Opdenacker <michael.opdenacker-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index 2196282..157fe8d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -6,13 +6,3 @@ config MLX5_CORE
 	tristate
 	depends on PCI && X86
 	default n
-
-config MLX5_DEBUG
-	bool "Verbose debugging output" if (MLX5_CORE && EXPERT)
-	depends on MLX5_CORE
-	default y
-	---help---
-	  This option causes debugging code to be compiled into the
-	  mlx5_core driver.  The output can be turned on via the
-	  debug_mask module parameter (which can also be set after
-	  the driver is loaded through sysfs).
-- 
1.8.1.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
