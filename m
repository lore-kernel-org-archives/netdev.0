From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/3] au1000_eth: remove unused variable in update_rx_stats
Date: Tue, 28 Jul 2009 23:06:31 +0200
Message-ID: <200907282306.31601.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Manuel Lauss <manuel.lauss@googlemail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:55459 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754555AbZG1VGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 17:06:38 -0400
Received: by ewy26 with SMTP id 26so363267ewy.37
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2009 14:06:38 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the unused aup variable in update_rx_stats

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 1f724da..f5611a5 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -649,7 +649,6 @@ static int au1000_init(struct net_device *dev)
 
 static inline void update_rx_stats(struct net_device *dev, u32 status)
 {
-	struct au1000_private *aup = netdev_priv(dev);
 	struct net_device_stats *ps = &dev->stats;
 
 	ps->rx_packets++;
