From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 13/16] sfc: Expose NVRAM_PARTITION_TYPE_LICENSE on
 EF10
Date: Thu, 12 Dec 2013 23:02:50 +0000
Message-ID: <1386889370.1516.350.camel@bwh-desktop.uk.level5networks.com>
References: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29541 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579Ab3LLXCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:02:53 -0500
In-Reply-To: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 69a0cf7f4f47..45af374b1df9 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3296,6 +3296,7 @@ static const struct efx_ef10_nvram_type_info efx_ef10_nvram_types[] = {
 	{ NVRAM_PARTITION_TYPE_EXPROM_CONFIG_PORT1, 0,   1, "sfc_exp_rom_cfg" },
 	{ NVRAM_PARTITION_TYPE_EXPROM_CONFIG_PORT2, 0,   2, "sfc_exp_rom_cfg" },
 	{ NVRAM_PARTITION_TYPE_EXPROM_CONFIG_PORT3, 0,   3, "sfc_exp_rom_cfg" },
+	{ NVRAM_PARTITION_TYPE_LICENSE,		   0,    0, "sfc_license" },
 	{ NVRAM_PARTITION_TYPE_PHY_MIN,		   0xff, 0, "sfc_phy_fw" },
 };
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
