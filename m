From: akpm@linux-foundation.org
Subject: [patch 11/13] smc911x: SuperH architecture support
Date: Mon, 09 Jun 2008 16:33:55 -0700
Message-ID: <200806092333.m59NXul9014702@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	magnus.damm@gmail.com, damm@igel.co.jp, lethal@linux-sh.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58496 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756565AbYFIXeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 19:34:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Damm <magnus.damm@gmail.com>

Enable the smc911x driver for the SuperH architecture.  While at it remove
the unused SMC_USE_SH_DMA definition.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Paul Mundt <lethal@linux-sh.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/Kconfig   |    2 +-
 drivers/net/smc911x.h |    1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

diff -puN drivers/net/Kconfig~smc911x-superh-architecture-support drivers/net/Kconfig
--- a/drivers/net/Kconfig~smc911x-superh-architecture-support
+++ a/drivers/net/Kconfig
@@ -955,7 +955,7 @@ config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
 	select MII
-	depends on ARCH_PXA || SH_MAGIC_PANEL_R2
+	depends on ARCH_PXA || SUPERH
 	help
 	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
 	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
diff -puN drivers/net/smc911x.h~smc911x-superh-architecture-support drivers/net/smc911x.h
--- a/drivers/net/smc911x.h~smc911x-superh-architecture-support
+++ a/drivers/net/smc911x.h
@@ -39,7 +39,6 @@
   #define SMC_USE_32BIT		1
   #define SMC_IRQ_SENSE		IRQF_TRIGGER_FALLING
 #elif defined(CONFIG_SH_MAGIC_PANEL_R2)
-  #define SMC_USE_SH_DMA	0
   #define SMC_USE_16BIT		0
   #define SMC_USE_32BIT		1
   #define SMC_IRQ_SENSE		IRQF_TRIGGER_LOW
_
