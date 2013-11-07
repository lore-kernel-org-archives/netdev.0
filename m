From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH] netdev: smc91x: enable for xtensa
Date: Thu,  7 Nov 2013 17:16:06 +0200
Message-ID: <b003049d965510cd44a7e2319c4d559cb344c380.1383837285.git.baruch@tkos.co.il>
Cc: Matthew Davey <matthew.davey@astc-design.com>,
	Baruch Siach <baruch@tkos.co.il>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:41450 "EHLO
	sivan.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752038Ab3KGPQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 10:16:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tested in VLAB Works Xtensa simulation.

Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
 drivers/net/ethernet/smsc/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/smsc/Kconfig b/drivers/net/ethernet/smsc/Kconfig
index 068fc44..753630f 100644
--- a/drivers/net/ethernet/smsc/Kconfig
+++ b/drivers/net/ethernet/smsc/Kconfig
@@ -6,7 +6,7 @@ config NET_VENDOR_SMSC
 	bool "SMC (SMSC)/Western Digital devices"
 	default y
 	depends on ARM || ISA || MAC || ARM64 || MIPS || M32R || SUPERH || \
-		BLACKFIN || MN10300 || COLDFIRE || PCI || PCMCIA
+		BLACKFIN || MN10300 || COLDFIRE || XTENSA || PCI || PCMCIA
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -39,7 +39,7 @@ config SMC91X
 	select CRC32
 	select MII
 	depends on (ARM || M32R || SUPERH || MIPS || BLACKFIN || \
-		    MN10300 || COLDFIRE || ARM64)
+		    MN10300 || COLDFIRE || ARM64 || XTENSA)
 	---help---
 	  This is a driver for SMC's 91x series of Ethernet chipsets,
 	  including the SMC91C94 and the SMC91C111. Say Y if you want it
-- 
1.8.4.rc3
