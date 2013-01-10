From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH 1/2] net: ethernet: xilinx: Do not use axienet on PPC
Date: Thu, 10 Jan 2013 17:58:42 +0100
Message-ID: <1357837123-18996-1-git-send-email-michal.simek@xilinx.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:46215 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528Ab3AJQ6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 11:58:47 -0500
Received: by mail-ee0-f54.google.com with SMTP id c13so412370eek.41
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 08:58:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Axi ethernet can't be used on PPC because it is
little endian IP and PPC is big endian.
This system can't be designed.

Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
 drivers/net/ethernet/xilinx/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/Kconfig b/drivers/net/ethernet/xilinx/Kconfig
index 5778a4a..122d60c 100644
--- a/drivers/net/ethernet/xilinx/Kconfig
+++ b/drivers/net/ethernet/xilinx/Kconfig
@@ -27,7 +27,7 @@ config XILINX_EMACLITE
 
 config XILINX_AXI_EMAC
 	tristate "Xilinx 10/100/1000 AXI Ethernet support"
-	depends on (PPC32 || MICROBLAZE)
+	depends on MICROBLAZE
 	select PHYLIB
 	---help---
 	  This driver supports the 10/100/1000 Ethernet from Xilinx for the
-- 
1.7.0.4
