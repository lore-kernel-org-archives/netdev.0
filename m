From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH Resend] drivers: net: b44: Fix typo in returning multicast stats
Date: Thu, 11 Sep 2014 23:19:49 +0100
Message-ID: <1410473989-2049-1-git-send-email-mark.einon@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mark Einon <mark.einon@gmail.com>
To: gary.zambrano@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nstat->multicast refers to received packets, not transmitted as
is returned here. Change it so that received packet stats are
given.

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---

changing to send to alternate address for Gary Zambrano, maintainers entry bounced.

 drivers/net/ethernet/broadcom/b44.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index 4a7028d..d588136 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -1697,7 +1697,7 @@ static struct rtnl_link_stats64 *b44_get_stats64(struct net_device *dev,
 				     hwstat->tx_underruns +
 				     hwstat->tx_excessive_cols +
 				     hwstat->tx_late_cols);
-		nstat->multicast  = hwstat->tx_multicast_pkts;
+		nstat->multicast  = hwstat->rx_multicast_pkts;
 		nstat->collisions = hwstat->tx_total_cols;
 
 		nstat->rx_length_errors = (hwstat->rx_oversize_pkts +
-- 
2.1.0
