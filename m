From: Matthew Whitehead <tedheadster@gmail.com>
Subject: [PATCH net-next] 3com: Fix drivers/net/ethernet/3com/Kconfig references to PCMCIA and 3c515
Date: Wed,  2 Oct 2013 11:08:03 -0400
Message-ID: <1380726483-17247-1-git-send-email-tedheadster@gmail.com>
Cc: Matthew Whitehead <tedheadster@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f41.google.com ([209.85.216.41]:55126 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046Ab3JBPIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 11:08:10 -0400
Received: by mail-qa0-f41.google.com with SMTP id ii20so4451769qab.14
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 08:08:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Vortex driver works with PCI and Cardbus devices, not PCMCIA.

There never was an EISA 3c515 card, only ISA, so remove that option.

Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>
---
 drivers/net/ethernet/3com/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/3com/Kconfig b/drivers/net/ethernet/3com/Kconfig
index f00c763..65b735d 100644
--- a/drivers/net/ethernet/3com/Kconfig
+++ b/drivers/net/ethernet/3com/Kconfig
@@ -35,7 +35,7 @@ config EL3
 
 config 3C515
 	tristate "3c515 ISA \"Fast EtherLink\""
-	depends on (ISA || EISA) && ISA_DMA_API
+	depends on ISA && ISA_DMA_API
 	---help---
 	  If you have a 3Com ISA EtherLink XL "Corkscrew" 3c515 Fast Ethernet
 	  network card, say Y and read the Ethernet-HOWTO, available from
@@ -70,7 +70,7 @@ config VORTEX
 	select MII
 	---help---
 	  This option enables driver support for a large number of 10Mbps and
-	  10/100Mbps EISA, PCI and PCMCIA 3Com network cards:
+	  10/100Mbps EISA, PCI and Cardbus 3Com network cards:
 
 	  "Vortex"    (Fast EtherLink 3c590/3c592/3c595/3c597) EISA and PCI
 	  "Boomerang" (EtherLink XL 3c900 or 3c905)            PCI
-- 
1.7.2.5
