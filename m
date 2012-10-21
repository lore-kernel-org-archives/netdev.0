From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 5/5] AVR32: Remove HAVE_NET_MACB
Date: Sun, 21 Oct 2012 16:23:12 +0200
Message-ID: <1350829392-3812-6-git-send-email-manabian@gmail.com>
References: <1350829392-3812-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net,
	hskinnemoen@gmail.com, egtvedt@samfundet.no, plagnioj@jcrosoft.com,
	bgat@billgatliff.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:65406 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866Ab2JUOXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 10:23:39 -0400
Received: by mail-lb0-f174.google.com with SMTP id n3so1170561lbo.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 07:23:39 -0700 (PDT)
In-Reply-To: <1350829392-3812-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HAVE_NET_MACB has already been removed from the driver itself
so removed it from arch Kconfig as well.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 arch/avr32/Kconfig | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/avr32/Kconfig b/arch/avr32/Kconfig
index 06e73bf..09f9fa8 100644
--- a/arch/avr32/Kconfig
+++ b/arch/avr32/Kconfig
@@ -80,7 +80,6 @@ config PLATFORM_AT32AP
 	select ARCH_REQUIRE_GPIOLIB
 	select GENERIC_ALLOCATOR
 	select HAVE_FB_ATMEL
-	select HAVE_NET_MACB
 
 #
 # CPU types
-- 
1.7.12.4
