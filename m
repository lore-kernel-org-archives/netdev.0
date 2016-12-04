From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V2 net 01/20] net/ena: remove ntuple filter support from device feature list
Date: Sun,  4 Dec 2016 15:19:19 +0200
Message-ID: <1480857578-5065-2-git-send-email-netanel@annapurnalabs.com>
References: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove NETIF_F_NTUPLE from netdev->features.
The ENA device driver does not support ntuple filtering.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index bfeaec5..33a760e 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -2729,7 +2729,6 @@ static void ena_set_dev_offloads(struct ena_com_dev_get_features_ctx *feat,
 	netdev->features =
 		dev_features |
 		NETIF_F_SG |
-		NETIF_F_NTUPLE |
 		NETIF_F_RXHASH |
 		NETIF_F_HIGHDMA;
 
-- 
2.7.4
