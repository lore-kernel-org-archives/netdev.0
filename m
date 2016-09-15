From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: emac: remove unnecessary dev_set_drvdata()
Date: Thu, 15 Sep 2016 02:25:52 +0000
Message-ID: <1473906352-2974-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33508 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755693AbcIOC0A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 22:26:00 -0400
Received: by mail-pf0-f196.google.com with SMTP id 128so1543568pfb.0
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 19:26:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/qualcomm/emac/emac.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index 56e0a9f..42d2d233 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -722,7 +722,6 @@ static int emac_remove(struct platform_device *pdev)
 
 	mdiobus_unregister(adpt->mii_bus);
 	free_netdev(netdev);
-	dev_set_drvdata(&pdev->dev, NULL);
 
 	return 0;
 }
