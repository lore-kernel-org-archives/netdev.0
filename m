From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] sfc: Report XAUI link down at default log level
Date: Fri, 30 May 2008 22:18:35 +0100
Message-ID: <20080530211835.GE1743@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:35645 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753231AbYE3VSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 17:18:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is normal when the external link is down so don't report it as an error.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon_xmac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 264e1ee..37d3cae 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -513,7 +513,7 @@ static int falcon_check_xaui_link_up(struct efx_nic *efx)
 		tries--;
 	}
 
-	EFX_ERR(efx, "Failed to bring XAUI link back up in %d tries!\n",
+	EFX_LOG(efx, "Failed to bring XAUI link back up in %d tries!\n",
 		max_tries);
 	return 0;
 }
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
