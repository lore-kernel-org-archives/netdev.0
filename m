From: Stefan Roese <sr@denx.de>
Subject: [PATCH] ibm_newemac: Increase number of default rx-/tx-buffers
Date: Sat,  5 Jan 2008 10:50:09 +0100
Message-ID: <1199526609-12290-1-git-send-email-sr@denx.de>
Cc: linuxppc-dev@ozlabs.org, benh@kernel.crashing.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:52503 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbYAEJuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 04:50:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Performance tests done by AMCC have shown that 256 buffer increase the
performance of the Linux EMAC driver. So let's update the default
values to match this setup.

Signed-off-by: Stefan Roese <sr@denx.de>
---
 drivers/net/ibm_newemac/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ibm_newemac/Kconfig b/drivers/net/ibm_newemac/Kconfig
index 0d3e738..5a06727 100644
--- a/drivers/net/ibm_newemac/Kconfig
+++ b/drivers/net/ibm_newemac/Kconfig
@@ -9,12 +9,12 @@ config IBM_NEW_EMAC
 config IBM_NEW_EMAC_RXB
 	int "Number of receive buffers"
 	depends on IBM_NEW_EMAC
-	default "128"
+	default "256"
 
 config IBM_NEW_EMAC_TXB
 	int "Number of transmit buffers"
 	depends on IBM_NEW_EMAC
-	default "64"
+	default "256"
 
 config IBM_NEW_EMAC_POLL_WEIGHT
 	int "MAL NAPI polling weight"
-- 
1.5.4.rc2

