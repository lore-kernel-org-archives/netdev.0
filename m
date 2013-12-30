From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH] net: Cleanup in eth-netx.h
Date: Mon, 30 Dec 2013 10:41:56 +0530
Message-ID: <1388380316-1884-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org, patches@linaro.org,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:50972 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780Ab3L3FPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 00:15:33 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so11020455pde.28
        for <netdev@vger.kernel.org>; Sun, 29 Dec 2013 21:15:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 2960ed346877 ("ARM: netx: move platform_data definitions")
moved the file to the current location but forgot to remove the pointer
to its previous location. Clean it up. While at it also change the header
file protection macros appropriately.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
Cc: Sascha Hauer <s.hauer@pengutronix.de>
---
 include/linux/platform_data/eth-netx.h |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/linux/platform_data/eth-netx.h b/include/linux/platform_data/eth-netx.h
index 88af1ac28ead..a395159725d5 100644
--- a/include/linux/platform_data/eth-netx.h
+++ b/include/linux/platform_data/eth-netx.h
@@ -1,6 +1,4 @@
 /*
- * arch/arm/mach-netx/include/mach/eth.h
- *
  * Copyright (c) 2005 Sascha Hauer <s.hauer@pengutronix.de>, Pengutronix
  *
  * This program is free software; you can redistribute it and/or modify
@@ -17,8 +15,8 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#ifndef ASMARM_ARCH_ETH_H
-#define ASMARM_ARCH_ETH_H
+#ifndef __ETH_NETX_H
+#define __ETH_NETX_H
 
 struct netxeth_platform_data {
 	unsigned int xcno;	/* number of xmac/xpec engine this eth uses */
-- 
1.7.9.5
