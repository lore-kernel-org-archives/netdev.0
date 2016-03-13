From: Moritz Fischer <moritz.fischer@ettus.com>
Subject: [PATCH 4/5] net: macb: Use ether_addr_copy over memcpy
Date: Sun, 13 Mar 2016 12:10:46 -0700
Message-ID: <1457896247-25934-5-git-send-email-moritz.fischer@ettus.com>
References: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
Cc: michal.simek@xilinx.com, joe@perches.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	moritz.fischer.private@gmail.com,
	Moritz Fischer <moritz.fischer@ettus.com>
To: nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36395 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754139AbcCMTLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 15:11:08 -0400
Received: by mail-pa0-f44.google.com with SMTP id tt10so140549549pab.3
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2016 12:11:08 -0700 (PDT)
In-Reply-To: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checkpatch suggests using ether_addr_copy over memcpy
to copy the mac address.

Signed-off-by: Moritz Fischer <moritz.fischer@ettus.com>
---
 drivers/net/ethernet/cadence/macb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 53400f6..a0c01e5 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2891,7 +2891,7 @@ static int macb_probe(struct platform_device *pdev)
 
 	mac = of_get_mac_address(np);
 	if (mac)
-		memcpy(bp->dev->dev_addr, mac, ETH_ALEN);
+		ether_addr_copy(bp->dev->dev_addr, mac);
 	else
 		macb_get_hwaddr(bp);
 
-- 
2.4.3
