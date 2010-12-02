From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 16/17] sfc: Use current MAC address, not NVRAM
 MAC address, for WoL filter
Date: Thu, 02 Dec 2010 23:48:20 +0000
Message-ID: <1291333700.3259.39.camel@bwh-desktop>
References: <1291333490.3259.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:13141 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932171Ab0LBXsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:48:23 -0500
In-Reply-To: <1291333490.3259.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/siena.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index 45236f5..b315980 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -562,7 +562,7 @@ static int siena_set_wol(struct efx_nic *efx, u32 type)
 		if (nic_data->wol_filter_id != -1)
 			efx_mcdi_wol_filter_remove(efx,
 						   nic_data->wol_filter_id);
-		rc = efx_mcdi_wol_filter_set_magic(efx, efx->mac_address,
+		rc = efx_mcdi_wol_filter_set_magic(efx, efx->net_dev->dev_addr,
 						   &nic_data->wol_filter_id);
 		if (rc)
 			goto fail;
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

