From: akpm@osdl.org
Subject: [patch 2/8] smc911x Kconfig fix
Date: Thu, 08 Jun 2006 22:19:41 -0700
Message-ID: <200606090519.k595Jflj032017@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, dustin@sensoria.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:39643 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965039AbWFIFTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 01:19:47 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Andrew Morton <akpm@osdl.org>

In file included from drivers/net/smc911x.c:84:
drivers/net/smc911x.h:46:9: warning: "SMC_USE_16BIT" is not defined
drivers/net/smc911x.h:60:9: warning: "SMC_USE_32BIT" is not defined
drivers/net/smc911x.h:73:10: warning: "SMC_USE_PXA_DMA" is not defined
drivers/net/smc911x.c: In function `smc911x_reset':
drivers/net/smc911x.c:247: warning: implicit declaration of function `SMC_inl'
drivers/net/smc911x.c:249: warning: implicit declaration of function `SMC_outl'

Cc: Dustin McIntire <dustin@sensoria.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/Kconfig |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/Kconfig~smc911x-Kconfig-fix drivers/net/Kconfig
--- devel/drivers/net/Kconfig~smc911x-Kconfig-fix	2006-04-26 20:42:30.000000000 -0700
+++ devel-akpm/drivers/net/Kconfig	2006-04-26 20:42:56.000000000 -0700
@@ -869,7 +869,7 @@ config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
 	select MII
-	depends on NET_ETHERNET
+	depends on NET_ETHERNET && ARCH_PXA
 	help
 	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
 	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
_
