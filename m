From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH net 01/18] net/ena: remove RFS support from device feature list
Date: Sun, 20 Nov 2016 10:45:30 +0200
Message-ID: <1479631547-29354-2-git-send-email-netanel@annapurnalabs.com>
References: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f172.google.com ([209.85.210.172]:34493 "EHLO
        mail-wj0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753121AbcKTIvf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 03:51:35 -0500
Received: by mail-wj0-f172.google.com with SMTP id mp19so14053659wjc.1
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 00:51:34 -0800 (PST)
In-Reply-To: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove NETIF_F_NTUPLE from netdev->features.
The ENA device driver does not support RFS acceleration.

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
1.9.1
