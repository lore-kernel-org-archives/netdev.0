From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next] sfc: Select PTP_1588_CLOCK
Date: Thu, 1 Nov 2012 21:22:22 +0000
Message-ID: <1351804942.2883.47.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32213 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759926Ab2KAVW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 17:22:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was missed in commit a24006ed12616bde1bbdb26868495906a212d8dc
('ptp: Enable clock drivers along with associated net/PHY drivers')
which enabled sfc's clock driver unconditionally.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/sfc/Kconfig b/drivers/net/ethernet/sfc/Kconfig
index fb3cbc2..3ab2c428 100644
--- a/drivers/net/ethernet/sfc/Kconfig
+++ b/drivers/net/ethernet/sfc/Kconfig
@@ -5,6 +5,7 @@ config SFC
 	select CRC32
 	select I2C
 	select I2C_ALGOBIT
+	select PTP_1588_CLOCK
 	---help---
 	  This driver supports 10-gigabit Ethernet cards based on
 	  the Solarflare SFC4000 and SFC9000-family controllers.
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
