From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 07/10] sfc: Add some missing bits to register self-test
 masks
Date: Wed, 03 Feb 2010 19:31:40 +0000
Message-ID: <1265225500.2116.7.camel@achroite.uk.solarflarecom.com>
References: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28097 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757368Ab0BCTbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 14:31:43 -0500
In-Reply-To: <1265225294.2116.1.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    2 +-
 drivers/net/sfc/siena.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 1e78585..f63a32c 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1008,7 +1008,7 @@ static int falcon_test_nvram(struct efx_nic *efx)
 
 static const struct efx_nic_register_test falcon_b0_register_tests[] = {
 	{ FR_AZ_ADR_REGION,
-	  EFX_OWORD32(0x0001FFFF, 0x0001FFFF, 0x0001FFFF, 0x0001FFFF) },
+	  EFX_OWORD32(0x0003FFFF, 0x0003FFFF, 0x0003FFFF, 0x0003FFFF) },
 	{ FR_AZ_RX_CFG,
 	  EFX_OWORD32(0xFFFFFFFE, 0x00017FFF, 0x00000000, 0x00000000) },
 	{ FR_AZ_TX_CFG,
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index 8e13112..1619fb5 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -134,7 +134,7 @@ void siena_remove_port(struct efx_nic *efx)
 
 static const struct efx_nic_register_test siena_register_tests[] = {
 	{ FR_AZ_ADR_REGION,
-	  EFX_OWORD32(0x0001FFFF, 0x0001FFFF, 0x0001FFFF, 0x0001FFFF) },
+	  EFX_OWORD32(0x0003FFFF, 0x0003FFFF, 0x0003FFFF, 0x0003FFFF) },
 	{ FR_CZ_USR_EV_CFG,
 	  EFX_OWORD32(0x000103FF, 0x00000000, 0x00000000, 0x00000000) },
 	{ FR_AZ_RX_CFG,
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

