From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 10/15] net/mlx5e: Rename physical symbol errors counter
Date: Fri, 16 Jun 2017 00:42:47 +0300
Message-ID: <20170615214252.30140-11-saeedm@mellanox.com>
References: <20170615214252.30140-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, kernel-team@fb.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32933 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752226AbdFOVnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 17:43:05 -0400
In-Reply-To: <20170615214252.30140-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Rename rx_symbol_errors_phy to rx_pcs_symbol_err_phy, in order to
prevent confusion with rx_symbol_err_phy counter.

rx_pcs_symbol_err_phy counter counts the number of symbol errors that
were detected on the PCS (regardless of traffic) and weren't
corrected by FEC correction algorithm or that FEC algorithm was
not active on this interface.

rx_symbol_err_phy refers to errors on packet level (physical error
during a packet receive).

Fixes: 5db0a4f64c04 ("net/mlx5e: Expose physical layer statistical...")
Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Cc: kernel-team@fb.com
---
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index f81c3aa60b46..fda247587ff6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -268,7 +268,7 @@ static const struct counter_desc pport_2819_stats_desc[] = {
 };
 
 static const struct counter_desc pport_phy_statistical_stats_desc[] = {
-	{ "rx_symbol_errors_phy", PPORT_PHY_STATISTICAL_OFF(phy_symbol_errors) },
+	{ "rx_pcs_symbol_err_phy", PPORT_PHY_STATISTICAL_OFF(phy_symbol_errors) },
 	{ "rx_corrected_bits_phy", PPORT_PHY_STATISTICAL_OFF(phy_corrected_bits) },
 };
 
-- 
2.11.0
