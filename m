From: akpm@linux-foundation.org
Subject: [patch 08/17] smc91x: make superh use default config
Date: Tue, 04 Mar 2008 15:19:27 -0800
Message-ID: <200803042319.m24NJR7R002703@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	magnus.damm@gmail.com, damm@igel.co.jp, lethal@linux-sh.org,
	nico@cam.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60432 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935120AbYCDXT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:19:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Damm <magnus.damm@gmail.com>

Removes superh board specific configuration from the header file.  These
boards will instead be configured using platform data.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
Acked-by: Nicolas Pitre <nico@cam.org>
Cc: Paul Mundt <lethal@linux-sh.org>,
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/smc91x.h |   30 ------------------------------
 1 file changed, 30 deletions(-)

diff -puN drivers/net/smc91x.h~smc91x-make-superh-use-default-config-v2 drivers/net/smc91x.h
--- a/drivers/net/smc91x.h~smc91x-make-superh-use-default-config-v2
+++ a/drivers/net/smc91x.h
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
_
