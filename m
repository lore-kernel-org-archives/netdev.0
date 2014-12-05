From: James Byrne <james.byrne@origamienergy.com>
Subject: [PATCH 1/1] net: macb: Remove obsolete comment from Kconfig
Date: Fri,  5 Dec 2014 13:03:53 +0000
Message-ID: <1417784633-13360-1-git-send-email-james.byrne@origamienergy.com>
Cc: netdev@vger.kernel.org, James Byrne <james.byrne@origamienergy.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp01.dentaku.gol.com ([203.216.5.71]:35847 "EHLO
	smtp01.dentaku.gol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258AbaLENNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 08:13:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Kconfig file says that Gigabit mode is not supported, but it has been
supported since commit 140b7552fdff04bbceeb842f0e04f0b4015fe97b ("net/macb:
Add support for Gigabit Ethernet mode").

Signed-off-by: James Byrne <james.byrne@origamienergy.com>
---
 drivers/net/ethernet/cadence/Kconfig | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/Kconfig b/drivers/net/ethernet/cadence/Kconfig
index 9e089d2..6932be0 100644
--- a/drivers/net/ethernet/cadence/Kconfig
+++ b/drivers/net/ethernet/cadence/Kconfig
@@ -35,8 +35,8 @@ config MACB
 	---help---
 	  The Cadence MACB ethernet interface is found on many Atmel AT32 and
 	  AT91 parts.  This driver also supports the Cadence GEM (Gigabit
-	  Ethernet MAC found in some ARM SoC devices).  Note: the Gigabit mode
-	  is not yet supported.  Say Y to include support for the MACB/GEM chip.
+	  Ethernet MAC found in some ARM SoC devices).  Say Y to include
+	  support for the MACB/GEM chip.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called macb.
-- 
1.9.1
