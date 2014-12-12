From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net] net: ethernet: smsc: Allow to select SMC91X for nios2
Date: Fri, 12 Dec 2014 10:21:08 +0100
Message-ID: <1418376068-28649-1-git-send-email-tklauser@distanz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:58240 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933200AbaLLJVK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2014 04:21:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This chip is present on the Nios2 Development Kit 2C35.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/smsc/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/smsc/Kconfig b/drivers/net/ethernet/smsc/Kconfig
index 753630f..6279268 100644
--- a/drivers/net/ethernet/smsc/Kconfig
+++ b/drivers/net/ethernet/smsc/Kconfig
@@ -6,7 +6,7 @@ config NET_VENDOR_SMSC
 	bool "SMC (SMSC)/Western Digital devices"
 	default y
 	depends on ARM || ISA || MAC || ARM64 || MIPS || M32R || SUPERH || \
-		BLACKFIN || MN10300 || COLDFIRE || XTENSA || PCI || PCMCIA
+		BLACKFIN || MN10300 || COLDFIRE || XTENSA || NIOS2 || PCI || PCMCIA
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -39,7 +39,7 @@ config SMC91X
 	select CRC32
 	select MII
 	depends on (ARM || M32R || SUPERH || MIPS || BLACKFIN || \
-		    MN10300 || COLDFIRE || ARM64 || XTENSA)
+		    MN10300 || COLDFIRE || ARM64 || XTENSA || NIOS2)
 	---help---
 	  This is a driver for SMC's 91x series of Ethernet chipsets,
 	  including the SMC91C94 and the SMC91C111. Say Y if you want it
-- 
2.2.0
