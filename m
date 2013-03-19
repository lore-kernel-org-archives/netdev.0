From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/1] net/smsc911x: Use NULL instead of integer for pointer
Date: Tue, 19 Mar 2013 12:31:38 +0530
Message-ID: <1363676498-9370-1-git-send-email-sachin.kamat@linaro.org>
Cc: steve.glendinning@shawell.net, davem@davemloft.net,
	sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:45069 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754184Ab3CSHMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 03:12:41 -0400
Received: by mail-da0-f53.google.com with SMTP id n34so133994dal.12
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 00:12:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Silences the following sparse warning:
drivers/net/ethernet/smsc/smsc911x.c:2145:30:
warning: Using plain integer as NULL pointer

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/ethernet/smsc/smsc911x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index df77df1..3663b9e 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -2142,7 +2142,7 @@ static int smsc911x_init(struct net_device *dev)
 	spin_lock_init(&pdata->dev_lock);
 	spin_lock_init(&pdata->mac_lock);
 
-	if (pdata->ioaddr == 0) {
+	if (pdata->ioaddr == NULL) {
 		SMSC_WARN(pdata, probe, "pdata->ioaddr: 0x00000000");
 		return -ENODEV;
 	}
-- 
1.7.4.1
