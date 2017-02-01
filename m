From: Heiner Kallweit <hkallweit1@gmail.com>
Subject: [PATCH] net: stmmac: Remove wrong message in stmmac_probe_config_dt
Date: Wed, 1 Feb 2017 22:05:12 +0100
Message-ID: <b01bb0ae-361c-a28a-d372-f9a3881c0a9b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35665 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751252AbdBAVF0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 16:05:26 -0500
Received: by mail-wm0-f67.google.com with SMTP id u63so8278400wmu.2
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 13:05:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I can only imagine that this message ended up there by a copy & paste
mistake. The same message appears correctly a few lines later, but
here it doesn't make sense.

Signed-off-by: Heiner Kallweit <hkallweit1@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 460f94f5..5edf23dc 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -371,7 +371,6 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 	} else {
 		clk_prepare_enable(plat->clk_ptp_ref);
 		plat->clk_ptp_rate = clk_get_rate(plat->clk_ptp_ref);
-		dev_info(&pdev->dev, "No reset control found\n");
 	}
 
 	plat->stmmac_rst = devm_reset_control_get(&pdev->dev,
-- 
2.11.0
