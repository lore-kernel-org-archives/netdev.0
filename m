From: Alexandre TORGUE <alexandre.torgue@st.com>
Subject: [RESEND PATCH v6 3/3] net: ethernet: stmmac: add support of Synopsys 3.50a MAC IP
Date: Mon, 29 Aug 2016 18:23:40 +0200
Message-ID: <1472487820-5132-4-git-send-email-alexandre.torgue@st.com>
References: <1472487820-5132-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <robh@kernel.org>, <manabian@gmail.com>
To: <netdev@vger.kernel.org>, <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:48362 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754383AbcH2QY3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 12:24:29 -0400
In-Reply-To: <1472487820-5132-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandre TORGUE <alexandre.torgue@gmail.com>

Adds support of Synopsys 3.50a MAC IP in stmmac driver.

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Tested-by: Maxime Coquelin <maxime.coquelin@st.com>
Signed-off-by: Alexandre TORGUE <alexandre.torgue@gmail.com>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 756bb54..0a0d6a8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -265,6 +265,7 @@ stmmac_probe_config_dt(struct platform_device *pdev, const char **mac)
 	 * once needed on other platforms.
 	 */
 	if (of_device_is_compatible(np, "st,spear600-gmac") ||
+		of_device_is_compatible(np, "snps,dwmac-3.50a") ||
 		of_device_is_compatible(np, "snps,dwmac-3.70a") ||
 		of_device_is_compatible(np, "snps,dwmac")) {
 		/* Note that the max-frame-size parameter as defined in the
-- 
1.9.1
