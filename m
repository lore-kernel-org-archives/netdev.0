From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 03/16] sfc: Strengthen EFX_ASSERT_RESET_SERIALISED
Date: Thu, 26 Nov 2009 02:08:52 +0000
Message-ID: <1259201332.2806.9.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31126 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752420AbZKZCIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 21:08:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 4787faa..9f3ef38 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -186,7 +186,8 @@ static void efx_fini_channels(struct efx_nic *efx);
 
 #define EFX_ASSERT_RESET_SERIALISED(efx)		\
 	do {						\
-		if (efx->state == STATE_RUNNING)	\
+		if ((efx->state == STATE_RUNNING) ||	\
+		    (efx->state == STATE_DISABLED))	\
 			ASSERT_RTNL();			\
 	} while (0)
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

