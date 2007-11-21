From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] smc911x: Fix undefined CONFIG_ symbol warning
Date: Wed, 21 Nov 2007 15:28:06 +0100
Message-ID: <E1IuqyC-0004eh-QM@nanv.dk>
To: netdev@vger.kernel.org, jeff@garzik.org,
	super.firetwister@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps.korsgaard.com ([64.79.194.204]:40926 "EHLO nanv.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755690AbXKUOya (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 09:54:30 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

elif defined(CONFIG_*) should be used instead of elif CONFIG_*
so GCC doesn't give warnings about undefined symbols when the config
option is disabled.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
Sigh, forgot --signoff :/

 drivers/net/smc911x.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index 16a0edc..d04e4fa 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -37,7 +37,7 @@
   #define SMC_USE_16BIT		0
   #define SMC_USE_32BIT		1
   #define SMC_IRQ_SENSE		IRQF_TRIGGER_FALLING
-#elif CONFIG_SH_MAGIC_PANEL_R2
+#elif defined(CONFIG_SH_MAGIC_PANEL_R2)
   #define SMC_USE_SH_DMA	0
   #define SMC_USE_16BIT		0
   #define SMC_USE_32BIT		1
-- 
1.5.3.4

