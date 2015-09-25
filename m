From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 8/8] net/mlx5_core: Update health syndromes
Date: Fri, 25 Sep 2015 10:49:16 +0300
Message-ID: <1443167356-32095-9-git-send-email-ogerlitz@mellanox.com>
References: <1443167356-32095-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, eli@labmailer.mlnx,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Eli Cohen <eli@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39349 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753443AbbIYHuP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2015 03:50:15 -0400
In-Reply-To: <1443167356-32095-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Update new health monitored syndromes and their descriptions.

Signed-off-by: Eli Cohen <eli@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/health.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/health.c b/drivers/net/ethernet/mellanox/mlx5/core/health.c
index 6e69de0..1277c42 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/health.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/health.c
@@ -46,12 +46,15 @@ enum {
 enum {
 	MLX5_HEALTH_SYNDR_FW_ERR		= 0x1,
 	MLX5_HEALTH_SYNDR_IRISC_ERR		= 0x7,
+	MLX5_HEALTH_SYNDR_HW_UNRECOVERABLE_ERR	= 0x8,
 	MLX5_HEALTH_SYNDR_CRC_ERR		= 0x9,
 	MLX5_HEALTH_SYNDR_FETCH_PCI_ERR		= 0xa,
 	MLX5_HEALTH_SYNDR_HW_FTL_ERR		= 0xb,
 	MLX5_HEALTH_SYNDR_ASYNC_EQ_OVERRUN_ERR	= 0xc,
 	MLX5_HEALTH_SYNDR_EQ_ERR		= 0xd,
+	MLX5_HEALTH_SYNDR_EQ_INV		= 0xe,
 	MLX5_HEALTH_SYNDR_FFSER_ERR		= 0xf,
+	MLX5_HEALTH_SYNDR_HIGH_TEMP		= 0x10
 };
 
 static DEFINE_SPINLOCK(health_lock);
@@ -88,6 +91,8 @@ static const char *hsynd_str(u8 synd)
 		return "firmware internal error";
 	case MLX5_HEALTH_SYNDR_IRISC_ERR:
 		return "irisc not responding";
+	case MLX5_HEALTH_SYNDR_HW_UNRECOVERABLE_ERR:
+		return "unrecoverable hardware error";
 	case MLX5_HEALTH_SYNDR_CRC_ERR:
 		return "firmware CRC error";
 	case MLX5_HEALTH_SYNDR_FETCH_PCI_ERR:
@@ -98,8 +103,12 @@ static const char *hsynd_str(u8 synd)
 		return "async EQ buffer overrun";
 	case MLX5_HEALTH_SYNDR_EQ_ERR:
 		return "EQ error";
+	case MLX5_HEALTH_SYNDR_EQ_INV:
+		return "Invalid EQ refrenced";
 	case MLX5_HEALTH_SYNDR_FFSER_ERR:
 		return "FFSER error";
+	case MLX5_HEALTH_SYNDR_HIGH_TEMP:
+		return "High temprature";
 	default:
 		return "unrecognized error";
 	}
-- 
2.3.7
