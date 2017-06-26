From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net/mlx4: fix spelling mistake: "coalesing" -> "coalescing"
Date: Mon, 26 Jun 2017 13:53:46 +0100
Message-ID: <20170626125346.22143-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in en_dbg debug message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 18252a79a074..9da76e3be2fc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1352,7 +1352,7 @@ static void mlx4_en_set_default_moderation(struct mlx4_en_priv *priv)
 	priv->rx_usecs = MLX4_EN_RX_COAL_TIME;
 	priv->tx_frames = MLX4_EN_TX_COAL_PKTS;
 	priv->tx_usecs = MLX4_EN_TX_COAL_TIME;
-	en_dbg(INTR, priv, "Default coalesing params for mtu:%d - rx_frames:%d rx_usecs:%d\n",
+	en_dbg(INTR, priv, "Default coalescing params for mtu:%d - rx_frames:%d rx_usecs:%d\n",
 	       priv->dev->mtu, priv->rx_frames, priv->rx_usecs);
 
 	/* Setup cq moderation params */
-- 
2.11.0
