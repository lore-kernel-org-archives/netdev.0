From: Ryan Raasch <ryan.raasch@gmail.com>
Subject: Disable pxa dma option for smc911x
Date: Mon, 14 Dec 2009 14:14:55 +0100
Message-ID: <4B263A4F.8050302@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020900060805020700050002"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f192.google.com ([209.85.221.192]:49418 "EHLO
	mail-qy0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754734AbZLNNPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 08:15:00 -0500
Received: by qyk30 with SMTP id 30so1526568qyk.33
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2009 05:14:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020900060805020700050002
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

Because our system, we have had to disable the dma for our chip :) We 
don't know why yet...

However, when disabling the DMA, there are a couple of cpp errors, which 
this patch fixes.

Greetings,
Ryan

--------------020900060805020700050002
Content-Type: text/x-patch;
 name="fix_smc911x_pxa_dma_disable.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fix_smc911x_pxa_dma_disable.patch"

diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index 05adb6a..e83213a 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -60,7 +60,7 @@
 #define SMC_DYNAMIC_BUS_CONFIG
 #endif
 
-#ifdef SMC_USE_PXA_DMA
+#if SMC_USE_PXA_DMA == 1
 #define SMC_USE_DMA
 #endif
 
@@ -209,7 +209,7 @@ static inline void SMC_outsl(struct smc911x_local *lp, int reg,
 #endif /* SMC_DYNAMIC_BUS_CONFIG */
 
 
-#ifdef SMC_USE_PXA_DMA
+#if SMC_USE_PXA_DMA == 1
 
 #include <mach/dma.h>
 

--------------020900060805020700050002--
