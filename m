From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 7/9] Remove unused macro EFX_XAUI_RETRAIN_MAX
Date: Wed, 7 May 2008 12:59:10 +0100
Message-ID: <20080507115910.GS2217@solarflare.com>
References: <20080507114121.GL2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:55764 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755083AbYEGL74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 07:59:56 -0400
Content-Disposition: inline
In-Reply-To: <20080507114121.GL2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon_xmac.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 8c41662..b875c7b 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -495,8 +495,6 @@ void falcon_update_stats_xmac(struct efx_nic *efx)
 		(mac_stats->rx_bytes - mac_stats->rx_good_bytes);
 }
 
-#define EFX_XAUI_RETRAIN_MAX 8
-
 int falcon_check_xmac(struct efx_nic *efx)
 {
 	unsigned xaui_link_ok;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
