From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/3] net: ethernet: cpsw: Remove redundant of_match_ptr
Date: Mon, 30 Sep 2013 09:55:12 +0530
Message-ID: <1380515114-2823-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:65230 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802Ab3I3EZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 00:25:28 -0400
Received: by mail-pb0-f43.google.com with SMTP id md4so5033365pbc.16
        for <netdev@vger.kernel.org>; Sun, 29 Sep 2013 21:25:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The data structure of_match_ptr() protects is always compiled in.
Hence of_match_ptr() is not needed.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 5efb37b..7290f11 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2217,7 +2217,7 @@ static struct platform_driver cpsw_driver = {
 		.name	 = "cpsw",
 		.owner	 = THIS_MODULE,
 		.pm	 = &cpsw_pm_ops,
-		.of_match_table = of_match_ptr(cpsw_of_mtable),
+		.of_match_table = cpsw_of_mtable,
 	},
 	.probe = cpsw_probe,
 	.remove = cpsw_remove,
-- 
1.7.9.5
