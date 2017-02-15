From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH] net: ethernet: ti: cpsw: correct ale dev to cpsw
Date: Wed, 15 Feb 2017 19:45:02 +0200
Message-ID: <1487180702-19944-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:33494 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752456AbdBORpN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 12:45:13 -0500
Received: by mail-lf0-f46.google.com with SMTP id x1so84639709lff.0
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 09:45:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ale is a property of cpsw, so change dev to cpsw->dev,
aka pdev->dev, to be consistent.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
Based on net-next/master

 drivers/net/ethernet/ti/cpsw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index e86f226..57c8308 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -3032,7 +3032,7 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_dma_ret;
 	}
 
-	ale_params.dev			= &ndev->dev;
+	ale_params.dev			= &pdev->dev;
 	ale_params.ale_ageout		= ale_ageout;
 	ale_params.ale_entries		= data->ale_entries;
 	ale_params.ale_ports		= data->slaves;
-- 
2.7.4
