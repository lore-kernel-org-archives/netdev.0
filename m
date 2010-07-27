From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 1/3] stmmac: remove the STMMAC_DUAL_MAC option
Date: Tue, 27 Jul 2010 12:09:45 +0200
Message-ID: <1280225387-26240-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:44639 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754927Ab0G0KKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 06:10:03 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 33B0F118
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 10:09:54 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D1A1B2651
	for <netdev@vger.kernel.org>; Tue, 27 Jul 2010 10:09:53 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The STMMAC_DUAL_MAC is now removed from the driver's Kconfig.
It will be available from a specific STM boards Kconfig.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/Kconfig |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/stmmac/Kconfig b/drivers/net/stmmac/Kconfig
index eb63d44..2513555 100644
--- a/drivers/net/stmmac/Kconfig
+++ b/drivers/net/stmmac/Kconfig
@@ -20,15 +20,6 @@ config STMMAC_DA
 	  By default, the DMA arbitration scheme is based on Round-robin
 	  (rx:tx priority is 1:1).
 
-config STMMAC_DUAL_MAC
-	bool "STMMAC: dual mac support (EXPERIMENTAL)"
-	default n
-        depends on EXPERIMENTAL && STMMAC_ETH && !STMMAC_TIMER
-	help
-	  Some ST SoCs (for example the stx7141 and stx7200c2) have two
-	  Ethernet Controllers. This option turns on the second Ethernet
-	  device on this kind of platforms.
-
 config STMMAC_TIMER
 	bool "STMMAC Timer optimisation"
 	default n
-- 
1.5.5.6

