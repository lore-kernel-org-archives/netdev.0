From: Heiner Kallweit <hkallweit1@gmail.com>
Subject: [PATCH v2] net: stmmac: Fix wrong message in stmmac_probe_config_dt
Date: Thu, 2 Feb 2017 08:20:12 +0100
Message-ID: <dc9df66b-022f-6a8b-8797-1965fc9b10bb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Phil Reid <preid@electromag.com.au>,
        jpinto <Joao.Pinto@synopsys.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:34867 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750808AbdBBHUW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 02:20:22 -0500
Received: by mail-wj0-f193.google.com with SMTP id i7so35994wjf.2
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 23:20:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most likely a copy & paste error in referenced commit.
Restore the debug message to what it was before.

Fixes: f573c0b9c4e0 ("stmmac: move stmmac_clk, pclk, clk_ptp_ref and stmmac_rst to platform structure")
Signed-off-by: Heiner Kallweit <hkallweit1@gmail.com>
---
v2:
- Don't remove the wrong comment but replace it with what
  was there before the referenced commit.
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 460f94f5..4963ccdb 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -371,7 +371,7 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 	} else {
 		clk_prepare_enable(plat->clk_ptp_ref);
 		plat->clk_ptp_rate = clk_get_rate(plat->clk_ptp_ref);
-		dev_info(&pdev->dev, "No reset control found\n");
+		dev_dbg(&pdev->dev, "PTP rate %d\n", plat->clk_ptp_rate);
 	}
 
 	plat->stmmac_rst = devm_reset_control_get(&pdev->dev,
-- 
2.11.0
