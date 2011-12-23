From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next] stmmac: fix missing module license in the main.
Date: Fri, 23 Dec 2011 11:31:07 +0100
Message-ID: <1324636267-25533-1-git-send-email-peppe.cavallaro@st.com>
References: <4EF3DB45.30401@xenotime.net>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:60756 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756609Ab1LWKb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 05:31:27 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 2EE6516F
	for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 10:31:24 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id BE22821D7
	for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 10:31:24 +0000 (GMT)
In-Reply-To: <4EF3DB45.30401@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following warning raised
when compile:

WARNING: modpost: missing MODULE_LICENSE()
in drivers/net/ethernet/stmicro/stmmac/stmmac.o

Reported-by: Randy Dunlap <rdunlap@xenotime.net>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index b314592..3738b47 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2039,3 +2039,7 @@ err:
 
 __setup("stmmaceth=", stmmac_cmdline_opt);
 #endif
+
+MODULE_DESCRIPTION("STMMAC 10/100/1000 Ethernet device driver");
+MODULE_AUTHOR("Giuseppe Cavallaro <peppe.cavallaro@st.com>");
+MODULE_LICENSE("GPL");
-- 
1.7.4.4
