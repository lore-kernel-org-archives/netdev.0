From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 2/4] stmmac: do not use strict_strtoul but kstrtoul
Date: Tue, 12 Jun 2012 14:45:51 +0200
Message-ID: <1339505153-26731-3-git-send-email-peppe.cavallaro@st.com>
References: <1339505153-26731-1-git-send-email-peppe.cavallaro@st.com>
Cc: bhutchings@solarflare.com, rayagond@vayavyalabs.com,
	davem@davemloft.net, yuvalmin@broadcom.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:36132 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752802Ab2FLMqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 08:46:44 -0400
In-Reply-To: <1339505153-26731-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces the obsolete strict_strtoul with kstrtoul.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   26 ++++++++-------------
 1 files changed, 10 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 8899e10..e33abf5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2126,42 +2126,36 @@ static int __init stmmac_cmdline_opt(char *str)
 		return -EINVAL;
 	while ((opt = strsep(&str, ",")) != NULL) {
 		if (!strncmp(opt, "debug:", 6)) {
-			if (strict_strtoul(opt + 6, 0, (unsigned long *)&debug))
+			if (kstrtoul(opt + 6, 0, (unsigned long *)&debug))
 				goto err;
 		} else if (!strncmp(opt, "phyaddr:", 8)) {
-			if (strict_strtoul(opt + 8, 0,
-					   (unsigned long *)&phyaddr))
+			if (kstrtoul(opt + 8, 0, (unsigned long *)&phyaddr))
 				goto err;
 		} else if (!strncmp(opt, "dma_txsize:", 11)) {
-			if (strict_strtoul(opt + 11, 0,
-					   (unsigned long *)&dma_txsize))
+			if (kstrtoul(opt + 11, 0, (unsigned long *)&dma_txsize))
 				goto err;
 		} else if (!strncmp(opt, "dma_rxsize:", 11)) {
-			if (strict_strtoul(opt + 11, 0,
+			if (kstrtoul(opt + 11, 0,
 					   (unsigned long *)&dma_rxsize))
 				goto err;
 		} else if (!strncmp(opt, "buf_sz:", 7)) {
-			if (strict_strtoul(opt + 7, 0,
-					   (unsigned long *)&buf_sz))
+			if (kstrtoul(opt + 7, 0, (unsigned long *)&buf_sz))
 				goto err;
 		} else if (!strncmp(opt, "tc:", 3)) {
-			if (strict_strtoul(opt + 3, 0, (unsigned long *)&tc))
+			if (kstrtoul(opt + 3, 0, (unsigned long *)&tc))
 				goto err;
 		} else if (!strncmp(opt, "watchdog:", 9)) {
-			if (strict_strtoul(opt + 9, 0,
-					   (unsigned long *)&watchdog))
+			if (kstrtoul(opt + 9, 0, (unsigned long *)&watchdog))
 				goto err;
 		} else if (!strncmp(opt, "flow_ctrl:", 10)) {
-			if (strict_strtoul(opt + 10, 0,
-					   (unsigned long *)&flow_ctrl))
+			if (kstrtoul(opt + 10, 0, (unsigned long *)&flow_ctrl))
 				goto err;
 		} else if (!strncmp(opt, "pause:", 6)) {
-			if (strict_strtoul(opt + 6, 0, (unsigned long *)&pause))
+			if (kstrtoul(opt + 6, 0, (unsigned long *)&pause))
 				goto err;
 #ifdef CONFIG_STMMAC_TIMER
 		} else if (!strncmp(opt, "tmrate:", 7)) {
-			if (strict_strtoul(opt + 7, 0,
-					   (unsigned long *)&tmrate))
+			if (kstrtoul(opt + 7, 0, (unsigned long *)&tmrate))
 				goto err;
 #endif
 		}
-- 
1.7.4.4
