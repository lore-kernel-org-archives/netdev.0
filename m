From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V2 2/6] net/mlx5: Remove duplicate pci dev name print
Date: Tue,  6 Dec 2016 17:32:44 +0200
Message-ID: <1481038368-29677-3-git-send-email-saeedm@mellanox.com>
References: <1481038368-29677-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Kamal Heib <kamalh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55470 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753064AbcLFPdk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 10:33:40 -0500
In-Reply-To: <1481038368-29677-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamal Heib <kamalh@mellanox.com>

Remove duplicate pci dev name printing from mlx5_core_warn/dbg.

Fixes: 5a7883989b1c ('net/mlx5_core: Improve mlx5 messages')
Signed-off-by: Kamal Heib <kamalh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
index 20d16b1..2ce0346 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/mlx5_core.h
@@ -47,8 +47,8 @@
 extern uint mlx5_core_debug_mask;
 
 #define mlx5_core_dbg(__dev, format, ...)				\
-	dev_dbg(&(__dev)->pdev->dev, "%s:%s:%d:(pid %d): " format,	\
-		 (__dev)->priv.name, __func__, __LINE__, current->pid,	\
+	dev_dbg(&(__dev)->pdev->dev, "%s:%d:(pid %d): " format,		\
+		 __func__, __LINE__, current->pid,			\
 		 ##__VA_ARGS__)
 
 #define mlx5_core_dbg_mask(__dev, mask, format, ...)			\
@@ -63,8 +63,8 @@ do {									\
 	       ##__VA_ARGS__)
 
 #define mlx5_core_warn(__dev, format, ...)				\
-	dev_warn(&(__dev)->pdev->dev, "%s:%s:%d:(pid %d): " format,	\
-		(__dev)->priv.name, __func__, __LINE__, current->pid,	\
+	dev_warn(&(__dev)->pdev->dev, "%s:%d:(pid %d): " format,	\
+		 __func__, __LINE__, current->pid,			\
 		##__VA_ARGS__)
 
 #define mlx5_core_info(__dev, format, ...)				\
-- 
2.7.4
