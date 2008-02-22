From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH 04/04] smc91x: make superh use default config V2
Date: Fri, 22 Feb 2008 19:55:33 +0900
Message-ID: <20080222105533.7408.30987.sendpatchset@clockwork.opensource.se>
References: <20080222105456.7408.11277.sendpatchset@clockwork.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org,
	nico@cam.org, akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.230]:16945 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755247AbYBVLBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 06:01:01 -0500
Received: by wr-out-0506.google.com with SMTP id c48so584558wra.23
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2008 03:01:01 -0800 (PST)
In-Reply-To: <20080222105456.7408.11277.sendpatchset@clockwork.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removes superh board specific configuration from the header file. These boards
will instead be configured using platform data.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 drivers/net/smc91x.h |   30 ------------------------------
 1 file changed, 30 deletions(-)

--- 0004/drivers/net/smc91x.h
+++ work/drivers/net/smc91x.h	2008-02-22 15:26:42.000000000 +0900
@@ -292,36 +292,6 @@ SMC_outw(u16 val, void __iomem *ioaddr, 
 #define SMC_insw(a, r, p, l)	insw((a) + (r), p, l)
 #define SMC_outsw(a, r, p, l)	outsw((a) + (r), p, l)
 
-#elif   defined(CONFIG_SUPERH)
-
-#ifdef CONFIG_SOLUTION_ENGINE
-#define SMC_IRQ_FLAGS		(0)
-#define SMC_CAN_USE_8BIT       0
-#define SMC_CAN_USE_16BIT      1
-#define SMC_CAN_USE_32BIT      0
-#define SMC_IO_SHIFT           0
-#define SMC_NOWAIT             1
-
-#define SMC_inw(a, r)          inw((a) + (r))
-#define SMC_outw(v, a, r)      outw(v, (a) + (r))
-#define SMC_insw(a, r, p, l)   insw((a) + (r), p, l)
-#define SMC_outsw(a, r, p, l)  outsw((a) + (r), p, l)
-
-#else /* BOARDS */
-
-#define SMC_CAN_USE_8BIT       1
-#define SMC_CAN_USE_16BIT      1
-#define SMC_CAN_USE_32BIT      0
-
-#define SMC_inb(a, r)          inb((a) + (r))
-#define SMC_inw(a, r)          inw((a) + (r))
-#define SMC_outb(v, a, r)      outb(v, (a) + (r))
-#define SMC_outw(v, a, r)      outw(v, (a) + (r))
-#define SMC_insw(a, r, p, l)   insw((a) + (r), p, l)
-#define SMC_outsw(a, r, p, l)  outsw((a) + (r), p, l)
-
-#endif  /* BOARDS */
-
 #elif   defined(CONFIG_M32R)
 
 #define SMC_CAN_USE_8BIT	0
