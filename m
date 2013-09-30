From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 2/3] net: ethernet: cpsw-phy-sel: Remove redundant of_match_ptr
Date: Mon, 30 Sep 2013 09:55:13 +0530
Message-ID: <1380515114-2823-2-git-send-email-sachin.kamat@linaro.org>
References: <1380515114-2823-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:56297 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238Ab3I3EZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 00:25:30 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq14so5276056pab.26
        for <netdev@vger.kernel.org>; Sun, 29 Sep 2013 21:25:30 -0700 (PDT)
In-Reply-To: <1380515114-2823-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The data structure of_match_ptr() protects is always compiled in.
Hence of_match_ptr() is not needed.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/ethernet/ti/cpsw-phy-sel.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw-phy-sel.c b/drivers/net/ethernet/ti/cpsw-phy-sel.c
index e092ede..148da9a 100644
--- a/drivers/net/ethernet/ti/cpsw-phy-sel.c
+++ b/drivers/net/ethernet/ti/cpsw-phy-sel.c
@@ -152,7 +152,7 @@ static struct platform_driver cpsw_phy_sel_driver = {
 	.driver		= {
 		.name	= "cpsw-phy-sel",
 		.owner	= THIS_MODULE,
-		.of_match_table = of_match_ptr(cpsw_phy_sel_id_table),
+		.of_match_table = cpsw_phy_sel_id_table,
 	},
 };
 
-- 
1.7.9.5
