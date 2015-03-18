From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net V1 2/4] net/mlx4_en: Fix off-by-one in ethtool statistics display
Date: Wed, 18 Mar 2015 16:51:36 +0200
Message-ID: <1426690298-10567-3-git-send-email-ogerlitz@mellanox.com>
References: <1426690298-10567-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:49368 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754789AbbCROvq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2015 10:51:46 -0400
In-Reply-To: <1426690298-10567-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

NUM_PORT_STATS was 9 instead of 10, which caused off-by-one bug when
displaying the statistics starting from tx_chksum_offload in ethtool.

Fixes: f8c6455bb04b ('net/mlx4_en: Extend checksum offloading by CHECKSUM COMPLETE')
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 2a8268e..ebbe244 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -453,7 +453,7 @@ struct mlx4_en_port_stats {
 	unsigned long rx_chksum_none;
 	unsigned long rx_chksum_complete;
 	unsigned long tx_chksum_offload;
-#define NUM_PORT_STATS		9
+#define NUM_PORT_STATS		10
 };
 
 struct mlx4_en_perf_stats {
-- 
1.7.1
