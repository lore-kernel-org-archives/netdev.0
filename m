From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 3/5] sfc: Replace EFX_DRIVER_NAME with
 KBUILD_MODNAME
Date: Wed, 23 Jun 2010 22:30:26 +0100
Message-ID: <1277328626.2101.10.camel@achroite.uk.solarflarecom.com>
References: <1277328447.2101.7.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:18555 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962Ab0FWVa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 17:30:29 -0400
In-Reply-To: <1277328447.2101.7.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    2 +-
 drivers/net/sfc/ethtool.c    |    2 +-
 drivers/net/sfc/net_driver.h |    4 +---
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 7251400..ad35911 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2432,7 +2432,7 @@ static struct dev_pm_ops efx_pm_ops = {
 };
 
 static struct pci_driver efx_pci_driver = {
-	.name		= EFX_DRIVER_NAME,
+	.name		= KBUILD_MODNAME,
 	.id_table	= efx_pci_table,
 	.probe		= efx_pci_probe,
 	.remove		= efx_pci_remove,
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 27230a9..53f3eb2 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -234,7 +234,7 @@ static void efx_ethtool_get_drvinfo(struct net_device *net_dev,
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
-	strlcpy(info->driver, EFX_DRIVER_NAME, sizeof(info->driver));
+	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
 	strlcpy(info->version, EFX_DRIVER_VERSION, sizeof(info->version));
 	if (efx_nic_rev(efx) >= EFX_REV_SIENA_A0)
 		siena_print_fwver(efx, info->fw_version,
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 33c62ae..6a901c8 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -39,9 +39,7 @@
  * Build definitions
  *
  **************************************************************************/
-#ifndef EFX_DRIVER_NAME
-#define EFX_DRIVER_NAME	"sfc"
-#endif
+
 #define EFX_DRIVER_VERSION	"3.0"
 
 #ifdef EFX_ENABLE_DEBUG
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

