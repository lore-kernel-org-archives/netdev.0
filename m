From: Alessandro Rubini <ru@gnudd.com>
Subject: [PATCH] smc91x.h: add config for Nomadik evaluation kit
Date: Thu, 23 Jul 2009 00:39:04 +0200
Message-ID: <20090722223904.GA13346@mail.gnudd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.gnudd.com ([213.203.150.91]:61493 "EHLO mail.gnudd.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753832AbZGVWr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2009 18:47:56 -0400
Received: from mail.gnudd.com (localhost [127.0.0.1])
	by mail.gnudd.com (8.14.3/8.14.3/Debian-5) with ESMTP id n6MMd5gX013354
	for <netdev@vger.kernel.org>; Thu, 23 Jul 2009 00:39:05 +0200
Received: (from rubini@localhost)
	by mail.gnudd.com (8.14.3/8.14.3/Submit) id n6MMd5EU013353
	for netdev@vger.kernel.org; Thu, 23 Jul 2009 00:39:05 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alessandro Rubini <rubini@unipv.it>
Acked-by: Andrea Gallo <andrea.gallo@stericsson.com>
---

Base support for the Nomadik SoC, by ST-Ericsson, is already
included in the "nomadik" branch of rmk's tree.  This one-liner
enables the 16-bit-only configuration for the chip, as the
default are not working for us

 drivers/net/smc91x.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index f1f773b..57a159f 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -186,7 +186,8 @@ static inline void SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 #define SMC_outsb(a, r, p, l)	writesb((a) + (r), p, (l))
 #define SMC_IRQ_FLAGS		(-1)	/* from resource */
 
-#elif	defined(CONFIG_MACH_LOGICPD_PXA270)
+#elif	defined(CONFIG_MACH_LOGICPD_PXA270) \
+	|| defined(CONFIG_MACH_NOMADIK_8815NHK)
 
 #define SMC_CAN_USE_8BIT	0
 #define SMC_CAN_USE_16BIT	1
-- 
1.6.0.2
