From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 1/2] stmmac: fixed a compilation error when use the external timer
Date: Mon, 23 Nov 2009 09:58:40 +0100
Message-ID: <1258966721-6567-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:37052 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755874AbZKWI6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 03:58:53 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C6196131
	for <netdev@vger.kernel.org>; Mon, 23 Nov 2009 08:58:52 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 8A6F897B
	for <netdev@vger.kernel.org>; Mon, 23 Nov 2009 08:58:52 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac_timer.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_timer.c b/drivers/net/stmmac/stmmac_timer.c
index b838c65..679f61f 100644
--- a/drivers/net/stmmac/stmmac_timer.c
+++ b/drivers/net/stmmac/stmmac_timer.c
@@ -63,7 +63,7 @@ int stmmac_open_ext_timer(struct net_device *dev, struct stmmac_timer *tm)
 
 	stmmac_rtc = rtc_class_open(CONFIG_RTC_HCTOSYS_DEVICE);
 	if (stmmac_rtc == NULL) {
-		pr_error("open rtc device failed\n");
+		pr_err("open rtc device failed\n");
 		return -ENODEV;
 	}
 
@@ -71,7 +71,7 @@ int stmmac_open_ext_timer(struct net_device *dev, struct stmmac_timer *tm)
 
 	/* Periodic mode is not supported */
 	if ((rtc_irq_set_freq(stmmac_rtc, &stmmac_task, tm->freq) < 0)) {
-		pr_error("set periodic failed\n");
+		pr_err("set periodic failed\n");
 		rtc_irq_unregister(stmmac_rtc, &stmmac_task);
 		rtc_class_close(stmmac_rtc);
 		return -1;
-- 
1.6.0.4

