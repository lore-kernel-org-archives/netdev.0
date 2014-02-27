From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 3/4] stmmac: dwmac-sti: fix broken STiD127 compatibility
Date: Thu, 27 Feb 2014 11:35:39 +0100
Message-ID: <1393497340-8013-4-git-send-email-peppe.cavallaro@st.com>
References: <1393497340-8013-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:43712 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751761AbaB0KhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 05:37:07 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 97FF115D
	for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 10:37:05 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas22.st.com [10.75.90.92])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7F3ADAE7E
	for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 10:37:05 +0000 (GMT)
In-Reply-To: <1393497340-8013-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to fix the compatibility to the STiD127 SoC.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index c61bc72b..8fb32a8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -36,7 +36,7 @@ static const struct of_device_id stmmac_dt_ids[] = {
 #ifdef CONFIG_DWMAC_STI
 	{ .compatible = "st,stih415-dwmac", .data = &sti_gmac_data},
 	{ .compatible = "st,stih416-dwmac", .data = &sti_gmac_data},
-	{ .compatible = "st,stih127-dwmac", .data = &sti_gmac_data},
+	{ .compatible = "st,stid127-dwmac", .data = &sti_gmac_data},
 #endif
 	/* SoC specific glue layers should come before generic bindings */
 	{ .compatible = "st,spear600-gmac"},
-- 
1.7.4.4
