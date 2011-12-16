From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 2/3] sfc: Remove device ID macros only used once
Date: Fri, 16 Dec 2011 20:12:35 +0000
Message-ID: <1324066355.2798.21.camel@bwh-desktop>
References: <1324066213.2798.19.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26432 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932667Ab1LPUMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 15:12:39 -0500
In-Reply-To: <1324066213.2798.19.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SFC9020/SFL9021 device IDs are only used in the device ID table,
where we can just as well use comments.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    4 ++--
 drivers/net/ethernet/sfc/efx.h |    4 ----
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 14e134d..9cf3eab 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2235,9 +2235,9 @@ static DEFINE_PCI_DEVICE_TABLE(efx_pci_table) = {
 	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE,
 		    PCI_DEVICE_ID_SOLARFLARE_SFC4000B),
 	 .driver_data = (unsigned long) &falcon_b0_nic_type},
-	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE, BETHPAGE_A_P_DEVID),
+	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE, 0x0803),	/* SFC9020 */
 	 .driver_data = (unsigned long) &siena_a0_nic_type},
-	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE, SIENA_A_P_DEVID),
+	{PCI_DEVICE(PCI_VENDOR_ID_SOLARFLARE, 0x0813),	/* SFL9021 */
 	 .driver_data = (unsigned long) &siena_a0_nic_type},
 	{0}			/* end of list */
 };
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 4764793..8a5336d 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -14,10 +14,6 @@
 #include "net_driver.h"
 #include "filter.h"
 
-/* PCI IDs */
-#define BETHPAGE_A_P_DEVID      0x0803
-#define SIENA_A_P_DEVID         0x0813
-
 /* Solarstorm controllers use BAR 0 for I/O space and BAR 2(&3) for memory */
 #define EFX_MEM_BAR 2
 
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
