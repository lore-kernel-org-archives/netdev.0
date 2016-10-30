From: Joachim Eastwood <manabian@gmail.com>
Subject: [net-next PATCH 7/7] stmmac: dwmac-sti: remove unused priv dev member
Date: Sun, 30 Oct 2016 21:05:07 +0100
Message-ID: <20161030200507.851-8-manabian@gmail.com>
References: <20161030200507.851-1-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, peppe.cavallaro@st.com,
        alexandre.torgue@st.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33796 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752842AbcJ3UGl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 16:06:41 -0400
Received: by mail-lf0-f68.google.com with SMTP id i187so6041671lfe.1
        for <netdev@vger.kernel.org>; Sun, 30 Oct 2016 13:06:40 -0700 (PDT)
In-Reply-To: <20161030200507.851-1-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dev member of struct sti_dwmac is not used anywhere in the driver
so lets just remove it.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
index 0af3faa..f51fb16 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
@@ -126,7 +126,6 @@ struct sti_dwmac {
 	struct clk *clk;	/* PHY clock */
 	u32 ctrl_reg;		/* GMAC glue-logic control register */
 	int clk_sel_reg;	/* GMAC ext clk selection register */
-	struct device *dev;
 	struct regmap *regmap;
 	bool gmac_en;
 	u32 speed;
@@ -274,7 +273,6 @@ static int sti_dwmac_parse_data(struct sti_dwmac *dwmac,
 		return err;
 	}
 
-	dwmac->dev = dev;
 	dwmac->interface = of_get_phy_mode(np);
 	dwmac->regmap = regmap;
 	dwmac->gmac_en = of_property_read_bool(np, "st,gmac_en");
-- 
2.10.1
