From: akpm@linux-foundation.org
Subject: [patch 08/10] net: smc911x: shut up compiler warnings
Date: Thu, 13 Dec 2007 16:02:59 -0800
Message-ID: <200712140002.lBE02xMv025532@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	lethal@linux-sh.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55253 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935082AbXLNAJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 19:09:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Mundt <lethal@linux-sh.org>

Trivial fix to shut up gcc.

Signed-off-by: Paul Mundt <lethal@linux-sh.org>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/smc911x.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/smc911x.h~net-smc911x-shut-up-compiler-warnings drivers/net/smc911x.h
--- a/drivers/net/smc911x.h~net-smc911x-shut-up-compiler-warnings
+++ a/drivers/net/smc911x.h
@@ -76,7 +76,7 @@
 
 
 
-#if	 SMC_USE_PXA_DMA
+#ifdef SMC_USE_PXA_DMA
 #define SMC_USE_DMA
 
 /*
_
