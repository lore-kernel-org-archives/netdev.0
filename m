From: Linus Walleij <linus.walleij@stericsson.com>
Subject: [PATCH] NET: smsc-ircc2: mark non-experimental
Date: Thu, 26 Apr 2012 23:51:07 +0200
Message-ID: <1335477067-26994-1-git-send-email-linus.walleij@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linus Walleij <linus.walleij@linaro.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:34193 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753936Ab2DZVv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 17:51:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Walleij <linus.walleij@linaro.org>

This has been used by me and others for ages, let's stop calling it
experimental.

Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
---
 drivers/net/irda/Kconfig      |    4 ++--
 drivers/net/irda/smsc-ircc2.c |    1 -
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
index 4680478..3575844 100644
--- a/drivers/net/irda/Kconfig
+++ b/drivers/net/irda/Kconfig
@@ -321,8 +321,8 @@ config AU1000_FIR
 	  Say M to build a module; it will be called au1k_ir.ko
 
 config SMC_IRCC_FIR
-	tristate "SMSC IrCC (EXPERIMENTAL)"
-	depends on EXPERIMENTAL && IRDA && ISA_DMA_API
+	tristate "SMSC IrCC"
+	depends on IRDA && ISA_DMA_API
 	help
 	  Say Y here if you want to build support for the SMC Infrared
 	  Communications Controller.  It is used in a wide variety of
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 6c95d40..a926813 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -1,7 +1,6 @@
 /*********************************************************************
  *
  * Description:   Driver for the SMC Infrared Communications Controller
- * Status:        Experimental.
  * Author:        Daniele Peri (peri@csai.unipa.it)
  * Created at:
  * Modified at:
-- 
1.7.9.2
