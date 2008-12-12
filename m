From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 24/33] sfc: Fix format arguments for warning about MSI-X allocation
Date: Fri, 12 Dec 2008 12:56:38 +0000
Message-ID: <20081212125637.GX10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:34214 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757823AbYLLM4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:56:40 -0500
Content-Disposition: inline
In-Reply-To: <cover.1229085672.git.bhutchings@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index b99ccfb..ce1c7d3 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -899,7 +899,7 @@ static void efx_probe_interrupts(struct efx_nic *efx)
 		rc = pci_enable_msix(efx->pci_dev, xentries, wanted_ints);
 		if (rc > 0) {
 			EFX_ERR(efx, "WARNING: Insufficient MSI-X vectors"
-				" available (%d < %d).\n", wanted_ints, rc);
+				" available (%d < %d).\n", rc, wanted_ints);
 			EFX_ERR(efx, "WARNING: Performance may be reduced.\n");
 			EFX_BUG_ON_PARANOID(rc >= wanted_ints);
 			wanted_ints = rc;
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
