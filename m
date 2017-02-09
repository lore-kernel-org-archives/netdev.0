From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V4 net-next 01/13] net/ena: remove ntuple filter support from device feature list
Date: Thu,  9 Feb 2017 15:21:27 +0200
Message-ID: <1486646499-13682-2-git-send-email-netanel@annapurnalabs.com>
References: <1486646499-13682-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com, eric.dumazet@gmail.com,
        evgenys@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486646499-13682-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove NETIF_F_NTUPLE from netdev->features.
The ENA device driver does not support ntuple filtering.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index aca95b3..d8cd9ca 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -2720,7 +2720,6 @@ static void ena_set_dev_offloads(struct ena_com_dev_get_features_ctx *feat,
 	netdev->features =
 		dev_features |
 		NETIF_F_SG |
-		NETIF_F_NTUPLE |
 		NETIF_F_RXHASH |
 		NETIF_F_HIGHDMA;
 
-- 
2.7.4
