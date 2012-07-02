From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next 2/2] drivers/ieee802154/at231rf230: remove unused return status
Date: Mon,  2 Jul 2012 10:18:32 +0400
Message-ID: <1341209912-6030-3-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1341209912-6030-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org, dbaryshkov@gmail.com,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:63898 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932425Ab2GBGWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 02:22:46 -0400
Received: by werb14 with SMTP id b14so2283780wer.19
        for <netdev@vger.kernel.org>; Sun, 01 Jul 2012 23:22:45 -0700 (PDT)
In-Reply-To: <1341209912-6030-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove excessive variable used for the return status.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 drivers/ieee802154/at86rf230.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/ieee802154/at86rf230.c b/drivers/ieee802154/at86rf230.c
index 4d033d4..902e38b 100644
--- a/drivers/ieee802154/at86rf230.c
+++ b/drivers/ieee802154/at86rf230.c
@@ -585,7 +585,6 @@ err:
 static int at86rf230_rx(struct at86rf230_local *lp)
 {
 	u8 len = 128, lqi = 0;
-	int rc;
 	struct sk_buff *skb;
 
 	skb = alloc_skb(len, GFP_KERNEL);
@@ -607,7 +606,7 @@ static int at86rf230_rx(struct at86rf230_local *lp)
 
 	ieee802154_rx_irqsafe(lp->dev, skb, lqi);
 
-	dev_dbg(&lp->spi->dev, "READ_FBUF: %d %d %x\n", rc, len, lqi);
+	dev_dbg(&lp->spi->dev, "READ_FBUF: %d %x\n", len, lqi);
 
 	return 0;
 err:
-- 
1.7.2.3
