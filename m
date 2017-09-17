From: Roman Yeryomin <leroi.lists@gmail.com>
Subject: [PATCH net-next v2 3/7] net: korina: use NAPI_POLL_WEIGHT
Date: Sun, 17 Sep 2017 20:24:38 +0300
Message-ID: <20170917172438.32421-1-roman@advem.lv>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36399 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751636AbdIQRYk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 17 Sep 2017 13:24:40 -0400
Received: by mail-lf0-f67.google.com with SMTP id l196so3439546lfl.3
        for <netdev@vger.kernel.org>; Sun, 17 Sep 2017 10:24:39 -0700 (PDT)
Received: from ubrain.corp.ubnt.com ([2a02:16d8:105:4000:76d4:35ff:fe88:7631])
        by smtp.googlemail.com with ESMTPSA id 63sm1125757lfr.65.2017.09.17.10.24.38
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Sep 2017 10:24:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Yeryomin <roman@advem.lv>
---
 drivers/net/ethernet/korina.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index e5466e19994a..c210add9b654 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -1082,7 +1082,7 @@ static int korina_probe(struct platform_device *pdev)
 	dev->netdev_ops = &korina_netdev_ops;
 	dev->ethtool_ops = &netdev_ethtool_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
-	netif_napi_add(dev, &lp->napi, korina_poll, 64);
+	netif_napi_add(dev, &lp->napi, korina_poll, NAPI_POLL_WEIGHT);
 
 	lp->phy_addr = (((lp->rx_irq == 0x2c? 1:0) << 8) | 0x05);
 	lp->mii_if.dev = dev;
-- 
2.11.0
