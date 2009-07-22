From: Alessandro Rubini <rubini-list@gnudd.com>
Subject: [PATCH v2] smc91x.h: add config for Nomadik evaluation kit
Date: Thu, 23 Jul 2009 00:49:08 +0200
Message-ID: <20090722224908.GA13789@mail.gnudd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: andrea.gallo@stericsson.com, STEricsson_nomadik_linux@list.st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.gnudd.com ([213.203.150.91]:61494 "EHLO mail.gnudd.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755191AbZGVWtX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jul 2009 18:49:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alessandro Rubini <rubini@unipv.it>
Acked-by: Andrea Gallo <andrea.gallo@stericsson.com>
---

[sorry for the repost: I used a non-subscribed address and
forgot to Cc: company people, V2 is otherwise the same as V1]

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
