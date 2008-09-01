From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 11/52] sfc: Reduce log level for XGXS lane status
Date: Mon, 1 Sep 2008 12:46:25 +0100
Message-ID: <20080901114624.GE7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:54314 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755961AbYIALq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:46:27 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was making noise during 10Xpress self-test.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mdio_10g.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index cb99f3f..3bb6b55 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -210,7 +210,7 @@ static inline int mdio_clause45_phyxgxs_lane_sync(struct efx_nic *efx)
 
 	sync = (lane_status & (1 << MDIO_PHYXS_LANE_ALIGNED_LBN)) != 0;
 	if (!sync)
-		EFX_INFO(efx, "XGXS lane status: %x\n", lane_status);
+		EFX_LOG(efx, "XGXS lane status: %x\n", lane_status);
 	return sync;
 }
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

