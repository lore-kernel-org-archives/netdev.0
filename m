From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 10/10] sfc: Correct some comments on enum reset_type
Date: Tue, 17 Jul 2012 19:07:59 +0100
Message-ID: <1342548479.2698.28.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342544740.2698.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:49468 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756093Ab2GQSIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 14:08:02 -0400
In-Reply-To: <1342544740.2698.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/enum.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/enum.h b/drivers/net/ethernet/sfc/enum.h
index d725a8f..182dbe2 100644
--- a/drivers/net/ethernet/sfc/enum.h
+++ b/drivers/net/ethernet/sfc/enum.h
@@ -136,10 +136,10 @@ enum efx_loopback_mode {
  *
  * Reset methods are numbered in order of increasing scope.
  *
- * @RESET_TYPE_INVISIBLE: don't reset the PHYs or interrupts
- * @RESET_TYPE_ALL: reset everything but PCI core blocks
- * @RESET_TYPE_WORLD: reset everything, save & restore PCI config
- * @RESET_TYPE_DISABLE: disable NIC
+ * @RESET_TYPE_INVISIBLE: Reset datapath and MAC (Falcon only)
+ * @RESET_TYPE_ALL: Reset datapath, MAC and PHY
+ * @RESET_TYPE_WORLD: Reset as much as possible
+ * @RESET_TYPE_DISABLE: Reset datapath, MAC and PHY; leave NIC disabled
  * @RESET_TYPE_TX_WATCHDOG: reset due to TX watchdog
  * @RESET_TYPE_INT_ERROR: reset due to internal error
  * @RESET_TYPE_RX_RECOVERY: reset to recover from RX datapath errors
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
