From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 1/2] sfc: MTD: Leave the DEBUG macro alone
Date: Mon, 30 Jan 2012 18:21:58 +0000
Message-ID: <1327947718.2595.8.camel@bwh-desktop>
References: <1327947627.2595.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:26045 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752687Ab2A3SWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 13:22:02 -0500
In-Reply-To: <1327947627.2595.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<linux/mtd/mtd.h> no longer defines DEBUG so we do not need to
un-define it here.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mtd.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mtd.c b/drivers/net/ethernet/sfc/mtd.c
index eff49da..79c1922 100644
--- a/drivers/net/ethernet/sfc/mtd.c
+++ b/drivers/net/ethernet/sfc/mtd.c
@@ -10,7 +10,6 @@
 
 #include <linux/bitops.h>
 #include <linux/module.h>
-#undef DEBUG /* <linux/mtd/mtd.h> has its own use for DEBUG */
 #include <linux/mtd/mtd.h>
 #include <linux/delay.h>
 #include <linux/slab.h>
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
