From: Antonio Borneo <borneo.antonio@gmail.com>
Subject: [PATCH 1/2] clocksource: Kconfig: replace USE_OF with OF
Date: Wed, 17 Jun 2015 19:42:30 +0800
Message-ID: <1434541351-9699-2-git-send-email-borneo.antonio@gmail.com>
References: <1434541351-9699-1-git-send-email-borneo.antonio@gmail.com>
Cc: Antonio Borneo <borneo.antonio@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Daniel Lezcano <daniel.lezcano@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:37434 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366AbbFQLnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 07:43:15 -0400
In-Reply-To: <1434541351-9699-1-git-send-email-borneo.antonio@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

USE_OF is used as intermediate Kconfig option by few
arch's (ARM, MIPS, Xtensa); in all these cases it
implies setting option OF too.
Replace the only instance of USE_OF in clocksource
with OF.

Signed-off-by: Antonio Borneo <borneo.antonio@gmail.com>
---

 drivers/clocksource/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/clocksource/Kconfig b/drivers/clocksource/Kconfig
index 51d7865f..d7410c2 100644
--- a/drivers/clocksource/Kconfig
+++ b/drivers/clocksource/Kconfig
@@ -254,7 +254,7 @@ config CLKSRC_MIPS_GIC
 
 config CLKSRC_PXA
 	def_bool y if ARCH_PXA || ARCH_SA1100
-	select CLKSRC_OF if USE_OF
+	select CLKSRC_OF if OF
 	help
 	  This enables OST0 support available on PXA and SA-11x0
 	  platforms.
-- 
2.4.3
