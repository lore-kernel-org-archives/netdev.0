From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH v3 5/7] net: moxa: add IFF_LIVE_ADDR_CHANGE flag
Date: Mon, 20 Jan 2014 12:13:17 +0100
Message-ID: <1390216399-27028-5-git-send-email-jonas.jensen@gmail.com>
References: <1390216399-27028-1-git-send-email-jonas.jensen@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, f.fainelli@gmail.com,
	bhutchings@solarflare.com, Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:52233 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825AbaATLOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 06:14:00 -0500
In-Reply-To: <1390216399-27028-1-git-send-email-jonas.jensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.ndo_set_mac_address hook callback already supports IFF_LIVE_ADDR_CHANGE
so add it to our flags.

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    Applies to next-20140120

 drivers/net/ethernet/moxa/moxart_ether.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index ca892bb..6df372f 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -728,7 +728,7 @@ static int moxart_mac_probe(struct platform_device *pdev)
 	ether_setup(ndev);
 	ndev->netdev_ops = &moxart_netdev_ops;
 	netif_napi_add(ndev, &priv->napi, moxart_rx_poll, RX_DESC_NUM);
-	ndev->priv_flags |= IFF_UNICAST_FLT;
+	ndev->priv_flags |= IFF_UNICAST_FLT | IFF_LIVE_ADDR_CHANGE;
 	ndev->irq = irq;
 
 	SET_NETDEV_DEV(ndev, &pdev->dev);
-- 
1.8.2.1
