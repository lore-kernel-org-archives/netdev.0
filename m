From: Barry Song <21cnbao@gmail.com>
Subject: [PATCH] dm9000: fix a typo
Date: Mon,  7 Sep 2015 03:15:20 +0000
Message-ID: <1441595720-31975-1-git-send-email-21cnbao@gmail.com>
Cc: Barry Song <Baohua.Song@csr.com>
To: davem@davemloft.net, nikita@compulab.co.il,
	grinberg@compulab.co.il, jg1.han@samsung.com, mugunthanvnm@ti.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34608 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753208AbbIGDHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2015 23:07:47 -0400
Received: by padhy16 with SMTP id hy16so79905606pad.1
        for <netdev@vger.kernel.org>; Sun, 06 Sep 2015 20:07:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barry Song <Baohua.Song@csr.com>

Signed-off-by: Barry Song <Baohua.Song@csr.com>
---
 drivers/net/ethernet/davicom/dm9000.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index c0a7813..cf94b72 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1226,7 +1226,7 @@ static irqreturn_t dm9000_interrupt(int irq, void *dev_id)
 	if (int_status & ISR_PRS)
 		dm9000_rx(dev);
 
-	/* Trnasmit Interrupt check */
+	/* Transmit Interrupt check */
 	if (int_status & ISR_PTS)
 		dm9000_tx_done(dev, db);
 
-- 
1.9.1
