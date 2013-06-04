From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/2] net: sun4i-emac: Remove redundant platform_set_drvdata()
Date: Tue,  4 Jun 2013 16:01:19 +0530
Message-ID: <1370341880-26501-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org,
	Stefan Roese <sr@denx.de>,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:43024 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317Ab3FDKph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 06:45:37 -0400
Received: by mail-pd0-f179.google.com with SMTP id q11so52798pdj.24
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 03:45:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 0998d06310 (device-core: Ensure drvdata = NULL when no
driver is bound) removes the need to set driver data field to
NULL.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
Cc: Stefan Roese <sr@denx.de>
Cc: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 drivers/net/ethernet/allwinner/sun4i-emac.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/allwinner/sun4i-emac.c b/drivers/net/ethernet/allwinner/sun4i-emac.c
index b411344..0049853 100644
--- a/drivers/net/ethernet/allwinner/sun4i-emac.c
+++ b/drivers/net/ethernet/allwinner/sun4i-emac.c
@@ -902,8 +902,6 @@ static int emac_remove(struct platform_device *pdev)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 
-	platform_set_drvdata(pdev, NULL);
-
 	unregister_netdev(ndev);
 	free_netdev(ndev);
 
-- 
1.7.9.5
