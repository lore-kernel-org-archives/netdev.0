From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 1/2] stmmac: fix macro  used for debugging the xmit
Date: Thu,  7 Feb 2013 07:47:51 +0100
Message-ID: <1360219672-27980-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:41996 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750821Ab3BGGsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 01:48:11 -0500
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 126A1F7
	for <netdev@vger.kernel.org>; Thu,  7 Feb 2013 06:48:00 +0000 (GMT)
Received: from mail7.sgp.st.com (unknown [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id A0CA924AB
	for <netdev@vger.kernel.org>; Thu,  7 Feb 2013 06:48:00 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the name of the macro used for
debugging the transmit process. I used STMMAC_TX_DEBUG
instead of STMMAC_XMIT_DEBUG.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index f07c061..b75f4b2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -69,7 +69,7 @@
 
 #undef STMMAC_XMIT_DEBUG
 /*#define STMMAC_XMIT_DEBUG*/
-#ifdef STMMAC_TX_DEBUG
+#ifdef STMMAC_XMIT_DEBUG
 #define TX_DBG(fmt, args...)  printk(fmt, ## args)
 #else
 #define TX_DBG(fmt, args...)  do { } while (0)
-- 
1.7.4.4
