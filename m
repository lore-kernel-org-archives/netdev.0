From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 1/2] stmmac: make the STi Layer compatible to STiH407
Date: Tue, 14 Oct 2014 08:12:55 +0200
Message-ID: <1413267176-325-2-git-send-email-peppe.cavallaro@st.com>
References: <1413267176-325-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <maxime.coquelin@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:52765 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754652AbaJNGRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 02:17:36 -0400
Received: from pps.filterd (m0046668.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id s9E6DY7s030106
	for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 08:17:35 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1q0sg598nm-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 08:17:35 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 97E603A
	for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 06:17:10 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id BADFD16A1F
	for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 06:17:32 +0000 (GMT)
In-Reply-To: <1413267176-325-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds the missing compatibility to the STiH407 SoC.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 .../devicetree/bindings/net/sti-dwmac.txt          |    4 ++--
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/sti-dwmac.txt b/Documentation/devicetree/bindings/net/sti-dwmac.txt
index 3dd3d0b..8c84d9a 100644
--- a/Documentation/devicetree/bindings/net/sti-dwmac.txt
+++ b/Documentation/devicetree/bindings/net/sti-dwmac.txt
@@ -3,8 +3,8 @@ STMicroelectronics SoC DWMAC glue layer controller
 The device node has following properties.
 
 Required properties:
- - compatible	: Can be "st,stih415-dwmac", "st,stih416-dwmac" or
-   "st,stid127-dwmac".
+ - compatible	: Can be "st,stih415-dwmac", "st,stih416-dwmac",
+   "st,stid127-dwmac", "st,stih407-dwmac".
  - reg		: Offset of the glue configuration register map in system
    configuration regmap pointed by st,syscon property and size.
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 4894500..0d6b9ad 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -40,6 +40,7 @@ static const struct of_device_id stmmac_dt_ids[] = {
 	{ .compatible = "st,stih415-dwmac", .data = &sti_gmac_data},
 	{ .compatible = "st,stih416-dwmac", .data = &sti_gmac_data},
 	{ .compatible = "st,stid127-dwmac", .data = &sti_gmac_data},
+	{ .compatible = "st,stih407-dwmac", .data = &sti_gmac_data},
 #endif
 #ifdef CONFIG_DWMAC_SOCFPGA
 	{ .compatible = "altr,socfpga-stmmac", .data = &socfpga_gmac_data },
-- 
1.7.4.4
