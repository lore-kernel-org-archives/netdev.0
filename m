From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 13/13] sfc: Make module parameters really boolean
Date: Sat, 1 Dec 2012 04:44:40 +0000
Message-ID: <1354337080.2640.52.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26210 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751978Ab2LAEon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 23:44:43 -0500
In-Reply-To: <1354336821.2640.39.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most of the module parameters treated as boolean are currently exposed
as type int or uint.  Defining them with the proper type is useful
documentation for both users and developers.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 6f073d0..d858f31 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -106,8 +106,8 @@ static struct workqueue_struct *reset_workqueue;
  *
  * This is only used in MSI-X interrupt mode
  */
-static unsigned int separate_tx_channels;
-module_param(separate_tx_channels, uint, 0444);
+static bool separate_tx_channels;
+module_param(separate_tx_channels, bool, 0444);
 MODULE_PARM_DESC(separate_tx_channels,
 		 "Use separate channels for TX and RX");
 
@@ -160,8 +160,8 @@ static unsigned int rss_cpus;
 module_param(rss_cpus, uint, 0444);
 MODULE_PARM_DESC(rss_cpus, "Number of CPUs to use for Receive-Side Scaling");
 
-static int phy_flash_cfg;
-module_param(phy_flash_cfg, int, 0644);
+static bool phy_flash_cfg;
+module_param(phy_flash_cfg, bool, 0644);
 MODULE_PARM_DESC(phy_flash_cfg, "Set PHYs into reflash mode initially");
 
 static unsigned irq_adapt_low_thresh = 8000;
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
