From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 22/27] sfc: Remove incorrect assertion from
	efx_pci_remove_main()
Date: Fri, 23 Oct 2009 19:32:51 +0100
Message-ID: <1256322771.2785.47.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8918 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996AbZJWScu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:32:50 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 29003fe..c925801 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2022,8 +2022,6 @@ static void efx_fini_struct(struct efx_nic *efx)
  */
 static void efx_pci_remove_main(struct efx_nic *efx)
 {
-	EFX_ASSERT_RESET_SERIALISED(efx);
-
 	/* Skip everything if we never obtained a valid membase */
 	if (!efx->membase)
 		return;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

