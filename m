From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH] smc91x: Add MigoR board support
Date: Fri, 08 Feb 2008 18:49:27 +0900
Message-ID: <20080208094927.2020.3230.sendpatchset@clockwork.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:26110 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932611AbYBHJyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 04:54:08 -0500
Received: by wa-out-1112.google.com with SMTP id v27so340222wah.23
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2008 01:54:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds MigoR board support to the smc91x driver.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 drivers/net/smc91x.h |   14 ++++++++++++++
 1 file changed, 14 insertions(+)

--- 0001/drivers/net/smc91x.h
+++ work/drivers/net/smc91x.h	2008-02-06 23:13:55.000000000 +0900
@@ -306,6 +306,20 @@ SMC_outw(u16 val, void __iomem *ioaddr, 
 #define SMC_insw(a, r, p, l)   insw((a) + (r), p, l)
 #define SMC_outsw(a, r, p, l)  outsw((a) + (r), p, l)
 
+#elif defined(CONFIG_SH_MIGOR)
+
+#define SMC_IRQ_FLAGS		(-1)
+#define SMC_CAN_USE_8BIT	0
+#define SMC_CAN_USE_16BIT	1
+#define SMC_CAN_USE_32BIT	0
+#define SMC_IO_SHIFT		0
+#define SMC_NOWAIT		1
+
+#define SMC_inw(a, r)		inw((a) + (r))
+#define SMC_outw(v, a, r)	outw(v, (a) + (r))
+#define SMC_insw(a, r, p, l)	insw((a) + (r), p, l)
+#define SMC_outsw(a, r, p, l)	outsw((a) + (r), p, l)
+
 #else /* BOARDS */
 
 #define SMC_CAN_USE_8BIT       1
