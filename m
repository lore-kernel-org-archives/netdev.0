From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH 05/05] smc911x: SuperH architecture support
Date: Mon, 02 Jun 2008 20:37:48 +0900
Message-ID: <20080602113748.28716.86669.sendpatchset@rx1.opensource.se>
References: <20080602113706.28716.92046.sendpatchset@rx1.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org,
	akpm@linux-foundation.org, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:47685 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574AbYFBLhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 07:37:35 -0400
Received: by rv-out-0506.google.com with SMTP id l9so1003094rvb.1
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2008 04:37:35 -0700 (PDT)
In-Reply-To: <20080602113706.28716.92046.sendpatchset@rx1.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable the smc911x driver for the SuperH architecture.
While at it remove the unused SMC_USE_SH_DMA definition.

Signed-off-by: Magnus Damm <damm@igel.co.jp>
---

 drivers/net/Kconfig   |    2 +-
 drivers/net/smc911x.h |    1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

--- 0001/drivers/net/Kconfig
+++ work/drivers/net/Kconfig	2008-06-02 18:36:29.000000000 +0900
@@ -955,7 +955,7 @@ config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
 	select MII
-	depends on ARCH_PXA || SH_MAGIC_PANEL_R2
+	depends on ARCH_PXA || SUPERH
 	help
 	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
 	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
--- 0005/drivers/net/smc911x.h
+++ work/drivers/net/smc911x.h	2008-06-02 18:58:10.000000000 +0900
@@ -39,7 +39,6 @@
   #define SMC_USE_32BIT		1
   #define SMC_IRQ_SENSE		IRQF_TRIGGER_FALLING
 #elif defined(CONFIG_SH_MAGIC_PANEL_R2)
-  #define SMC_USE_SH_DMA	0
   #define SMC_USE_16BIT		0
   #define SMC_USE_32BIT		1
   #define SMC_IRQ_SENSE		IRQF_TRIGGER_LOW
