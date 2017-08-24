From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 2/8] net/mlx5: Remove a leftover unused variable
Date: Thu, 24 Aug 2017 16:21:46 +0300
Message-ID: <20170824132152.29538-3-saeedm@mellanox.com>
References: <20170824132152.29538-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34094 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753042AbdHXNV6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 09:21:58 -0400
In-Reply-To: <20170824132152.29538-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

mlx5_core_wq is no longer being used and should be removed
from the code.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/linux/mlx5/driver.h | 2 --
 1 file changed, 2 deletions(-)

diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index d26f18b39c4a..d5b6f6a9fcc5 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -890,8 +890,6 @@ static inline void *mlx5_buf_offset(struct mlx5_buf *buf, int offset)
 		return buf->direct.buf + offset;
 }
 
-extern struct workqueue_struct *mlx5_core_wq;
-
 #define STRUCT_FIELD(header, field) \
 	.struct_offset_bytes = offsetof(struct ib_unpacked_ ## header, field),      \
 	.struct_size_bytes   = sizeof((struct ib_unpacked_ ## header *)0)->field
-- 
2.13.0
