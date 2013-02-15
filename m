From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git)] stmmac: fix the parsing of the eee_timer parameter
Date: Fri, 15 Feb 2013 10:00:13 +0100
Message-ID: <1360918813-25805-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:47348 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752395Ab3BOJA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 04:00:26 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7D2763ED
	for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 09:00:23 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D8A764731
	for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 09:00:22 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This pacth fixes the parsing of the eee_timer driver parameter.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index b75f4b2..601dd84 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2254,7 +2254,7 @@ static int __init stmmac_cmdline_opt(char *str)
 		} else if (!strncmp(opt, "pause:", 6)) {
 			if (kstrtoint(opt + 6, 0, &pause))
 				goto err;
-		} else if (!strncmp(opt, "eee_timer:", 6)) {
+		} else if (!strncmp(opt, "eee_timer:", 10)) {
 			if (kstrtoint(opt + 10, 0, &eee_timer))
 				goto err;
 		}
-- 
1.7.4.4
