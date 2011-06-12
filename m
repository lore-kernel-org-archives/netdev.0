From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 04/10] davinci_emac: enable transmit time stamping.
Date: Sun, 12 Jun 2011 14:19:01 +0200
Message-ID: <8a2ddd8b4d012e06d1f1889751d7e68c62b8ec06.1307880494.git.richard.cochran@omicron.at>
References: <cover.1307880494.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>, Anant Gole <anantgole@ti.com>,
	Kevin Hilman <khilman@deeprootsystems.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46427 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753137Ab1FLMTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 08:19:22 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so3125460bwz.19
        for <netdev@vger.kernel.org>; Sun, 12 Jun 2011 05:19:21 -0700 (PDT)
In-Reply-To: <cover.1307880494.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1307880494.git.richard.cochran@omicron.at>
References: <cover.1307880494.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables software (and phy device) transmit time stamping
for the DaVinci EMAC driver. Tested together with the dp83640 PHY.

Cc: Anant Gole <anantgole@ti.com>
Cc: Kevin Hilman <khilman@deeprootsystems.com>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/davinci_emac.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 5c2baa4..f5688ff 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -1090,6 +1090,7 @@ static int emac_dev_xmit(struct sk_buff *skb, struct net_device *ndev)
 			dev_err(emac_dev, "DaVinci EMAC: desc submit failed");
 		goto fail_tx;
 	}
+	skb_tx_timestamp(skb);
 
 	return NETDEV_TX_OK;
 
-- 
1.7.0.4

