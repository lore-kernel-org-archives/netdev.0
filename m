From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 12/13] stmmac: improve Kconfig help
Date: Thu,  7 Jan 2010 10:07:22 +0100
Message-ID: <1262855243-6762-12-git-send-email-peppe.cavallaro@st.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-4-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-5-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-6-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-7-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-8-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-9-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-10-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-11-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:42574 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756357Ab0AGJHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 04:07:32 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id D330E1A1
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:28 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id A1EB0BE4
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:28 +0000 (GMT)
In-Reply-To: <1262855243-6762-11-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/Kconfig |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/stmmac/Kconfig b/drivers/net/stmmac/Kconfig
index 35eaa52..fb28764 100644
--- a/drivers/net/stmmac/Kconfig
+++ b/drivers/net/stmmac/Kconfig
@@ -4,8 +4,9 @@ config STMMAC_ETH
 	select PHYLIB
 	depends on NETDEVICES && CPU_SUBTYPE_ST40
 	help
-	  This is the driver for the ST MAC 10/100/1000 on-chip Ethernet
-	  controllers. ST Ethernet IPs are built around a Synopsys IP Core.
+	  This is the driver for the Ethernet IPs are built around a
+	  Synopsys IP Core and fully tested on the STMicroelectronics
+	  platforms.
 
 if STMMAC_ETH
 
@@ -32,7 +33,8 @@ config STMMAC_TIMER
 	default n
 	help
 	  Use an external timer for mitigating the number of network
-	  interrupts.
+	  interrupts. Currently, for SH architectures, it is possible
+	  to use the TMU channel 2 and the SH-RTC device.
 
 choice
         prompt "Select Timer device"
-- 
1.6.0.4

