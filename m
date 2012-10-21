From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 4/5] ARM: AT91: Remove HAVE_NET_MACB
Date: Sun, 21 Oct 2012 16:23:11 +0200
Message-ID: <1350829392-3812-5-git-send-email-manabian@gmail.com>
References: <1350829392-3812-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net,
	hskinnemoen@gmail.com, egtvedt@samfundet.no, plagnioj@jcrosoft.com,
	bgat@billgatliff.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:62687 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753732Ab2JUOXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 10:23:39 -0400
Received: by mail-lb0-f174.google.com with SMTP id n3so1170577lbo.19
        for <netdev@vger.kernel.org>; Sun, 21 Oct 2012 07:23:37 -0700 (PDT)
In-Reply-To: <1350829392-3812-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HAVE_NET_MACB has already been removed from the driver itself
so removed it from mach Kconfig as well.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 arch/arm/mach-at91/Kconfig | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/arch/arm/mach-at91/Kconfig b/arch/arm/mach-at91/Kconfig
index d846b6e..72020fb 100644
--- a/arch/arm/mach-at91/Kconfig
+++ b/arch/arm/mach-at91/Kconfig
@@ -45,7 +45,6 @@ config SOC_AT91RM9200
 config SOC_AT91SAM9260
 	bool "AT91SAM9260, AT91SAM9XE or AT91SAM9G20"
 	select HAVE_AT91_DBGU0
-	select HAVE_NET_MACB
 	select SOC_AT91SAM9
 	help
 	  Select this if you are using one of Atmel's AT91SAM9260, AT91SAM9XE
@@ -63,7 +62,6 @@ config SOC_AT91SAM9263
 	bool "AT91SAM9263"
 	select HAVE_AT91_DBGU1
 	select HAVE_FB_ATMEL
-	select HAVE_NET_MACB
 	select SOC_AT91SAM9
 
 config SOC_AT91SAM9RL
@@ -76,7 +74,6 @@ config SOC_AT91SAM9G45
 	bool "AT91SAM9G45 or AT91SAM9M10 families"
 	select HAVE_AT91_DBGU1
 	select HAVE_FB_ATMEL
-	select HAVE_NET_MACB
 	select SOC_AT91SAM9
 	help
 	  Select this if you are using one of Atmel's AT91SAM9G45 family SoC.
@@ -86,7 +83,6 @@ config SOC_AT91SAM9X5
 	bool "AT91SAM9x5 family"
 	select HAVE_AT91_DBGU0
 	select HAVE_FB_ATMEL
-	select HAVE_NET_MACB
 	select SOC_AT91SAM9
 	help
 	  Select this if you are using one of Atmel's AT91SAM9x5 family SoC.
-- 
1.7.12.4
