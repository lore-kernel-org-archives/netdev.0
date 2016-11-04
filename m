From: Joachim Eastwood <manabian@gmail.com>
Subject: [net-next v2 1/7] stmmac: dwmac-sti: remove useless of_node check
Date: Fri,  4 Nov 2016 18:54:05 +0100
Message-ID: <20161104175411.12943-2-manabian@gmail.com>
References: <20161104175411.12943-1-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36359 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934840AbcKDRzZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 13:55:25 -0400
Received: by mail-lf0-f66.google.com with SMTP id o20so4992078lfg.3
        for <netdev@vger.kernel.org>; Fri, 04 Nov 2016 10:55:24 -0700 (PDT)
In-Reply-To: <20161104175411.12943-1-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since dwmac-sti is a DT only driver checking for OF node is not necessary.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Tested-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index 58c05ac..075ed42 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -270,9 +270,6 @@ static int sti_dwmac_parse_data(struct sti_dwmac *dwmac,
 	struct regmap *regmap;
 	int err;
 
-	if (!np)
-		return -EINVAL;
-
 	/* clk selection from extra syscfg register */
 	dwmac->clk_sel_reg = -ENXIO;
 	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "sti-clkconf");
-- 
2.10.2
