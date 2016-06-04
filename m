From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: fec: fix spelling mistake "coalesed" -> "coalesced"
Date: Sat,  4 Jun 2016 20:01:15 +0100
Message-ID: <1465066875-7089-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Fugang Duan <fugang.duan@nxp.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

trivial fix to spelling mistake in pr_err message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 3c0255e..96bd210 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2427,13 +2427,13 @@ fec_enet_set_coalesce(struct net_device *ndev, struct ethtool_coalesce *ec)
 
 	cycle = fec_enet_us_to_itr_clock(ndev, fep->rx_time_itr);
 	if (cycle > 0xFFFF) {
-		pr_err("Rx coalesed usec exceeed hardware limiation");
+		pr_err("Rx coalesced usec exceeed hardware limiation");
 		return -EINVAL;
 	}
 
 	cycle = fec_enet_us_to_itr_clock(ndev, fep->tx_time_itr);
 	if (cycle > 0xFFFF) {
-		pr_err("Rx coalesed usec exceeed hardware limiation");
+		pr_err("Rx coalesced usec exceeed hardware limiation");
 		return -EINVAL;
 	}
 
-- 
2.8.1
