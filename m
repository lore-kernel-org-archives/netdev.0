From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 2/8] net/mlx4: fix sparse warnings on TX control
 flags, endianess
Date: Tue, 6 Mar 2012 16:03:41 +0200
Message-ID: <4F56193D.7070806@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:51729 "HELO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758264Ab2CFODr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 09:03:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Fix sparse warnings on incompatibility between the endianess of the ctrl_flags
field of struct mlx4_en_priv to the srcrb_flags field of struct
mlx4_wqe_ctrl_seg by changing the former to be __be32 instead of u32.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index a5bb0b7d..8f4e655 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -453,7 +453,7 @@ struct mlx4_en_priv {
 	int base_qpn;
 
 	struct mlx4_en_rss_map rss_map;
-	u32 ctrl_flags;
+	__be32 ctrl_flags;
 	u32 flags;
 #define MLX4_EN_FLAG_PROMISC	0x1
 #define MLX4_EN_FLAG_MC_PROMISC	0x2
-- 
1.7.7
