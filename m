From: Achiad Shochat <achiad@mellanox.com>
Subject: [PATCH net-next 4/8] net/mlx5e: Support smaller RX/TX ring sizes
Date: Sun, 16 Aug 2015 16:04:48 +0300
Message-ID: <1439730292-29617-5-git-send-email-achiad@mellanox.com>
References: <1439730292-29617-1-git-send-email-achiad@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38419 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751520AbbHPNHH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Aug 2015 09:07:07 -0400
In-Reply-To: <1439730292-29617-1-git-send-email-achiad@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We un-intentionally limited the minimum rings size too much.

TX minimum ring size reduced from 128 to 64.
RX minimum ring size reduced from 128 to 2.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 3b659c3..d32a005 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -42,11 +42,11 @@
 
 #define MLX5E_MAX_NUM_TC	8
 
-#define MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE                0x7
+#define MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE                0x6
 #define MLX5E_PARAMS_DEFAULT_LOG_SQ_SIZE                0xa
 #define MLX5E_PARAMS_MAXIMUM_LOG_SQ_SIZE                0xd
 
-#define MLX5E_PARAMS_MINIMUM_LOG_RQ_SIZE                0x7
+#define MLX5E_PARAMS_MINIMUM_LOG_RQ_SIZE                0x1
 #define MLX5E_PARAMS_DEFAULT_LOG_RQ_SIZE                0xa
 #define MLX5E_PARAMS_MAXIMUM_LOG_RQ_SIZE                0xd
 
-- 
1.8.3.1
