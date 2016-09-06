From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [PATCH v5 6/6] net: stmmac: update the module description of the dwmac-meson driver
Date: Tue,  6 Sep 2016 23:38:48 +0200
Message-ID: <20160906213848.17785-7-martin.blumenstingl@googlemail.com>
References: <20160904182320.671-1-martin.blumenstingl@googlemail.com>
 <20160906213848.17785-1-martin.blumenstingl@googlemail.com>
Cc: robh+dt@kernel.org, mark.rutland@arm.com, catalin.marinas@arm.com,
        will.deacon@arm.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        sboyd@codeaurora.org, manabian@gmail.com, arnd@arndb.de,
        davem@davemloft.net, b.galvani@gmail.com,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>
To: linux-amlogic@lists.infradead.org, khilman@baylibre.com,
        carlo@caione.org, mturquette@baylibre.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35575 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755005AbcIFVjo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 17:39:44 -0400
In-Reply-To: <20160906213848.17785-1-martin.blumenstingl@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dwmac-meson glue driver supports Meson6 and Meson8 SoCs. Newer SoCs
are supported by the dwmac-meson8b driver.

Signed-off-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c
index c1bac19..309d995 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c
@@ -1,5 +1,5 @@
 /*
- * Amlogic Meson DWMAC glue layer
+ * Amlogic Meson6 and Meson8 DWMAC glue layer
  *
  * Copyright (C) 2014 Beniamino Galvani <b.galvani@gmail.com>
  *
@@ -96,5 +96,5 @@ static struct platform_driver meson6_dwmac_driver = {
 module_platform_driver(meson6_dwmac_driver);
 
 MODULE_AUTHOR("Beniamino Galvani <b.galvani@gmail.com>");
-MODULE_DESCRIPTION("Amlogic Meson DWMAC glue layer");
+MODULE_DESCRIPTION("Amlogic Meson6 and Meson8 DWMAC glue layer");
 MODULE_LICENSE("GPL v2");
-- 
2.9.3
