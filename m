From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/3] sfc: don't select SFC_FALCON
Date: Thu, 1 Dec 2016 17:01:07 +0000
Message-ID: <3a8a7ccb-8389-6c9f-dcd3-5d8ac2838820@solarflare.com>
References: <c52a0276-e379-7841-8d10-d5a834b81c4e@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <bkenward@solarflare.com>, <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:56299 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755545AbcLARBX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 12:01:23 -0500
In-Reply-To: <c52a0276-e379-7841-8d10-d5a834b81c4e@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Easy enough for Falcon users to enable it when making oldconfig.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/Kconfig | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/Kconfig b/drivers/net/ethernet/sfc/Kconfig
index 0e16197..605ebc7 100644
--- a/drivers/net/ethernet/sfc/Kconfig
+++ b/drivers/net/ethernet/sfc/Kconfig
@@ -6,7 +6,6 @@ config SFC
 	select I2C
 	select I2C_ALGOBIT
 	select PTP_1588_CLOCK
-	select SFC_FALCON
 	---help---
 	  This driver supports 10/40-gigabit Ethernet cards based on
 	  the Solarflare SFC9000-family and SFC9100-family controllers.
