From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 3/6] net/mlx5: Remove several module events out of ethtool stats
Date: Sun, 11 Jun 2017 17:00:25 +0300
Message-ID: <20170611140028.12467-4-saeedm@mellanox.com>
References: <20170611140028.12467-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35954 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751850AbdFKOAu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 10:00:50 -0400
In-Reply-To: <20170611140028.12467-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huy Nguyen <huyn@mellanox.com>

Remove the following module event counters out of ethtool stats. The
reason for removing these event counters is that these events do not
occur without techinician's intervention.
  module_pwr_budget_exd
  module_long_range
  module_no_eeprom
  module_enforce_part
  module_unknown_id
  module_unknown_status
  module_plug

Fixes: bedb7c909c19 ("net/mlx5e: Add port module event counters to ethtool stats")
Signed-off-by: Huy Nguyen <huyn@mellanox.com>
Reviewed by: Gal Pressman <galp@mellanox.com>

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
index 53e4992d6511..f81c3aa60b46 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.h
@@ -417,20 +417,13 @@ struct mlx5e_stats {
 };
 
 static const struct counter_desc mlx5e_pme_status_desc[] = {
-	{ "module_plug", 0 },
 	{ "module_unplug", 8 },
 };
 
 static const struct counter_desc mlx5e_pme_error_desc[] = {
-	{ "module_pwr_budget_exd", 0 },  /* power budget exceed */
-	{ "module_long_range", 8 },      /* long range for non MLNX cable */
-	{ "module_bus_stuck", 16 },      /* bus stuck (I2C or data shorted) */
-	{ "module_no_eeprom", 24 },      /* no eeprom/retry time out */
-	{ "module_enforce_part", 32 },   /* enforce part number list */
-	{ "module_unknown_id", 40 },     /* unknown identifier */
-	{ "module_high_temp", 48 },      /* high temperature */
+	{ "module_bus_stuck", 16 },       /* bus stuck (I2C or data shorted) */
+	{ "module_high_temp", 48 },       /* high temperature */
 	{ "module_bad_shorted", 56 },    /* bad or shorted cable/module */
-	{ "module_unknown_status", 64 },
 };
 
 #endif /* __MLX5_EN_STATS_H__ */
-- 
2.11.0
