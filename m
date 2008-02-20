From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH 03/04] smc91x: make superh use default config
Date: Wed, 20 Feb 2008 18:58:12 +0900
Message-ID: <20080220095812.22645.94915.sendpatchset@clockwork.opensource.se>
References: <20080220095740.22645.36783.sendpatchset@clockwork.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org,
	nico@cam.org, akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:48369 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905AbYBTKD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 05:03:28 -0500
Received: by rv-out-0910.google.com with SMTP id k20so1895551rvb.1
        for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 02:03:28 -0800 (PST)
In-Reply-To: <20080220095740.22645.36783.sendpatchset@clockwork.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removes superh board specific configuration from the header file. These boards
will instead be configured using platform data.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 drivers/net/smc91x.h |   30 ------------------------------
 1 file changed, 30 deletions(-)

--- 0018/drivers/net/smc91x.h
+++ work/drivers/net/smc91x.h	2008-02-20 17:09:28.000000000 +0900
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
