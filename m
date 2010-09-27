From: Otavio Salvador <otavio@ossystems.com.br>
Subject: [PATCH 4/4] net: r6040: store BIOS default MAC in perm_add
Date: Sun, 26 Sep 2010 23:49:39 -0300
Message-ID: <1285555779-5885-1-git-send-email-otavio@ossystems.com.br>
Cc: Otavio Salvador <otavio@ossystems.com.br>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:57192 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758248Ab0I0CuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 22:50:01 -0400
Received: by gyd8 with SMTP id 8so1420072gyd.19
        for <netdev@vger.kernel.org>; Sun, 26 Sep 2010 19:50:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Otavio Salvador <otavio@ossystems.com.br>
---
 drivers/net/r6040.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 142c381..5780d08 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -740,6 +740,9 @@ static void r6040_mac_address(struct net_device *dev)
 	iowrite16(adrp[0], ioaddr + MID_0L);
 	iowrite16(adrp[1], ioaddr + MID_0M);
 	iowrite16(adrp[2], ioaddr + MID_0H);
+
+	/* Store MAC Address in perm_addr */
+	memcpy(dev->perm_addr, dev->dev_addr, ETH_ALEN);
 }
 
 static int r6040_open(struct net_device *dev)
-- 
1.7.2.3.313.gcd15

