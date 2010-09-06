From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 2/2] mlx4_en: Fixed Ethtool statistics report
Date: Mon, 6 Sep 2010 11:20:24 +0300
Message-ID: <4C84A448.9000903@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:39775 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752850Ab0IFIU1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Sep 2010 04:20:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The values didn't match the title after removing the LRO
statistics in commit fa37a9586f92051de03a13e55e5ec3880bb6783e

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_ethtool.c |    2 +-
 drivers/net/mlx4/mlx4_en.h    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/mlx4/en_ethtool.c
index 01634a3..056152b 100644
--- a/drivers/net/mlx4/en_ethtool.c
+++ b/drivers/net/mlx4/en_ethtool.c
@@ -107,7 +107,7 @@ static const char main_strings[][ETH_GSTRING_LEN] = {
 	"tx_prio_1", "tx_prio_2", "tx_prio_3", "tx_prio_4", "tx_prio_5",
 	"tx_prio_6", "tx_prio_7",
 };
-#define NUM_MAIN_STATS	18
+#define NUM_MAIN_STATS	21
 #define NUM_ALL_STATS	(NUM_MAIN_STATS + NUM_PORT_STATS + NUM_PKT_STATS + NUM_PERF_STATS)
 
 static const char mlx4_en_test_names[][ETH_GSTRING_LEN]= {
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index ce8e233..1fc16ab 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -385,7 +385,7 @@ struct mlx4_en_port_stats {
 	unsigned long rx_chksum_good;
 	unsigned long rx_chksum_none;
 	unsigned long tx_chksum_offload;
-#define NUM_PORT_STATS		11
+#define NUM_PORT_STATS		8
 };
 
 struct mlx4_en_perf_stats {
-- 
1.6.1.3


