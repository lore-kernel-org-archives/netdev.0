From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 8/9] bnxt_en: Fix bnxt_setup_tc() error message.
Date: Sun, 12 Feb 2017 19:18:17 -0500
Message-ID: <1486945098-4086-9-git-send-email-michael.chan@broadcom.com>
References: <1486945098-4086-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:37136 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751376AbdBMAS5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 19:18:57 -0500
Received: by mail-it0-f42.google.com with SMTP id x75so22850404itb.0
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 16:18:57 -0800 (PST)
In-Reply-To: <1486945098-4086-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add proper puctuation to make the message more clear.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 9f1dfbe..c899d61 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6833,7 +6833,7 @@ int bnxt_setup_mq_tc(struct net_device *dev, u8 tc)
 	int rc;
 
 	if (tc > bp->max_tc) {
-		netdev_err(dev, "too many traffic classes requested: %d Max supported is %d\n",
+		netdev_err(dev, "Too many traffic classes requested: %d. Max supported is %d.\n",
 			   tc, bp->max_tc);
 		return -EINVAL;
 	}
-- 
1.8.3.1
