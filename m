From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V2 2/7] bnx2x: convert to CYCLECOUNTER_MASK macro.
Date: Fri,  2 Jan 2015 20:22:04 +0100
Message-ID: <6a7e236ed3320834f89e8a75eb4f8dcc13a2ecee.1420226266.git.richardcochran@gmail.com>
References: <20141231.183347.862533634176009078.davem@davemloft.net>
Cc: David Miller <davem@davemloft.net>,
	John Stultz <john.stultz@linaro.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:33761 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036AbbABTWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 14:22:16 -0500
Received: by mail-wi0-f171.google.com with SMTP id bs8so52215wib.10
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 11:22:15 -0800 (PST)
In-Reply-To: <20141231.183347.862533634176009078.davem@davemloft.net>
In-Reply-To: <cover.1420226266.git.richardcochran@gmail.com>
References: <cover.1420226266.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 2c95132..0758c8b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -14610,7 +14610,7 @@ static void bnx2x_init_cyclecounter(struct bnx2x *bp)
 {
 	memset(&bp->cyclecounter, 0, sizeof(bp->cyclecounter));
 	bp->cyclecounter.read = bnx2x_cyclecounter_read;
-	bp->cyclecounter.mask = CLOCKSOURCE_MASK(64);
+	bp->cyclecounter.mask = CYCLECOUNTER_MASK(64);
 	bp->cyclecounter.shift = 1;
 	bp->cyclecounter.mult = 1;
 }
-- 
1.7.10.4
