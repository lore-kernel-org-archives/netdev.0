From: Daniel Walker <dwalker@codeaurora.org>
Subject: net: smc91x: Support Qualcomm MSM development boards.
Date: Fri, 05 Mar 2010 11:12:34 -0800
Message-ID: <1267816354.30393.4.camel@c-dwalke-linux.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Brown <davidb@quicinc.com>, netdev@vger.kernel.org
To: Nicolas Pitre <nico@fluxnic.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:23827 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755454Ab0CETMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 14:12:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brown <davidb@quicinc.com>

Signed-off-by: David Brown <davidb@quicinc.com>
Signed-off-by: Daniel Walker <dwalker@codeaurora.org>
---
 drivers/net/smc91x.h |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 5479954..a6ee883 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -330,6 +330,20 @@ static inline void LPD7_SMC_outsw (unsigned char* a, int r,
 
 #include <unit/smc91111.h>
 
+#elif defined(CONFIG_ARCH_MSM)
+
+#define SMC_CAN_USE_8BIT	0
+#define SMC_CAN_USE_16BIT	1
+#define SMC_CAN_USE_32BIT	0
+#define SMC_NOWAIT		1
+
+#define SMC_inw(a, r)		readw((a) + (r))
+#define SMC_outw(v, a, r)	writew(v, (a) + (r))
+#define SMC_insw(a, r, p, l)	readsw((a) + (r), p, l)
+#define SMC_outsw(a, r, p, l)	writesw((a) + (r), p, l)
+
+#define SMC_IRQ_FLAGS		IRQF_TRIGGER_HIGH
+
 #else
 
 /*
-- 
1.6.3.3



