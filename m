From: Moritz Fischer <moritz.fischer@ettus.com>
Subject: [PATCH v3 4/5] net: macb: Use ether_addr_copy over memcpy
Date: Tue, 29 Mar 2016 19:11:14 -0700
Message-ID: <1459303875-3362-5-git-send-email-moritz.fischer@ettus.com>
References: <1459303875-3362-1-git-send-email-moritz.fischer@ettus.com>
Cc: michal.simek@xilinx.com, joe@perches.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	moritz.fischer.private@gmail.com,
	Moritz Fischer <moritz.fischer@ettus.com>
To: nicolas.ferre@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:33042 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753642AbcDCR0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2016 13:26:37 -0400
Received: by mail-oi0-f51.google.com with SMTP id w85so8662855oiw.0
        for <netdev@vger.kernel.org>; Sun, 03 Apr 2016 10:26:37 -0700 (PDT)
In-Reply-To: <1459303875-3362-1-git-send-email-moritz.fischer@ettus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checkpatch suggests using ether_addr_copy over memcpy
to copy the mac address.

Acked-by: Michal Simek <michal.simek@xilinx.com>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Signed-off-by: Moritz Fischer <moritz.fischer@ettus.com>
---
 drivers/net/ethernet/cadence/macb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 2ba0934..01a8ffb 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2973,7 +2973,7 @@ static int macb_probe(struct platform_device *pdev)
 
 	mac = of_get_mac_address(np);
 	if (mac)
-		memcpy(bp->dev->dev_addr, mac, ETH_ALEN);
+		ether_addr_copy(bp->dev->dev_addr, mac);
 	else
 		macb_get_hwaddr(bp);
 
-- 
2.7.4
