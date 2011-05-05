From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] stmmac: removed not used definitions
Date: Thu,  5 May 2011 12:10:50 +0200
Message-ID: <1304590250-9434-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:46733 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753587Ab1EEKcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 06:32:04 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 4755F13C
	for <netdev@vger.kernel.org>; Thu,  5 May 2011 10:11:13 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id EE0E72C8E
	for <netdev@vger.kernel.org>; Thu,  5 May 2011 10:11:12 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Karim Hamiti <karim.hamiti@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac_main.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index cc973fc..4ca9203 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -116,9 +116,6 @@ static int tc = TC_DEFAULT;
 module_param(tc, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(tc, "DMA threshold control value");
 
-#define RX_NO_COALESCE	1	/* Always interrupt on completion */
-#define TX_NO_COALESCE	-1	/* No moderation by default */
-
 /* Pay attention to tune this parameter; take care of both
  * hardware capability and network stabitily/performance impact.
  * Many tests showed that ~4ms latency seems to be good enough. */
-- 
1.7.4.4

