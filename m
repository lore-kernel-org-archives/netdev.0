From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 23/32] sfc: Update the description of SFC_MTD
Date: Fri, 27 Jan 2012 20:50:15 +0000
Message-ID: <1327697415.2503.30.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:63749 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751824Ab2A0UuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:50:18 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SFC4000 boards also have an EEPROM exposed as MTD.
The boot configuration is accessed through MTD.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/Kconfig |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/Kconfig b/drivers/net/ethernet/sfc/Kconfig
index ae40b66..8d42354 100644
--- a/drivers/net/ethernet/sfc/Kconfig
+++ b/drivers/net/ethernet/sfc/Kconfig
@@ -16,9 +16,9 @@ config SFC_MTD
 	depends on SFC && MTD && !(SFC=y && MTD=m)
 	default y
 	---help---
-	  This exposes the on-board flash memory as MTD devices (e.g.
-	  /dev/mtd1).  This makes it possible to upload new firmware
-	  to the NIC.
+	  This exposes the on-board flash and/or EEPROM as MTD devices
+	  (e.g. /dev/mtd1).  This is required to update the firmware or
+	  the boot configuration under Linux.
 config SFC_MCDI_MON
 	bool "Solarflare SFC9000-family hwmon support"
 	depends on SFC && HWMON && !(SFC=y && HWMON=m)
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
