From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 2/3] stmmac: remove dead option in the driver's Kconfig
Date: Tue, 24 Aug 2010 08:40:41 +0200
Message-ID: <1282632042-752-2-git-send-email-peppe.cavallaro@st.com>
References: <1282632042-752-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:38221 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755209Ab0HXNjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 09:39:08 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 85E50FB
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 13:39:06 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5461C26A9
	for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 13:39:06 +0000 (GMT)
In-Reply-To: <1282632042-752-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the CPU_SUBTYPE_ST40 dependency in the
driver's Kconfig.
In fact, this option has been removed in the commit:
 f96691872439ab2071171d4531c4a95b5d493ae5
as reported by Christian Dietrich.

Note that the driver remains tested on STM platforms, only.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/stmmac/Kconfig b/drivers/net/stmmac/Kconfig
index eb63d44..6439680 100644
--- a/drivers/net/stmmac/Kconfig
+++ b/drivers/net/stmmac/Kconfig
@@ -3,10 +3,10 @@ config STMMAC_ETH
 	select MII
 	select PHYLIB
 	select CRC32
-	depends on NETDEVICES && CPU_SUBTYPE_ST40
+	depends on NETDEVICES
 	help
 	  This is the driver for the Ethernet IPs are built around a
-	  Synopsys IP Core and fully tested on the STMicroelectronics
+	  Synopsys IP Core and only tested on the STMicroelectronics
 	  platforms.
 
 if STMMAC_ETH
-- 
1.5.5.6

