From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 04/16] sfc: Removed unncesssary UL suffixes on 0 literals
Date: Fri, 16 May 2008 21:15:29 +0100
Message-ID: <20080516201529.GW28241@solarflare.com>
References: <20080516201005.GS28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53520 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755260AbYEPUQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:16:22 -0400
Content-Disposition: inline
In-Reply-To: <20080516201005.GS28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 1a065fc..3494f4c 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -793,7 +793,7 @@ static int efx_init_io(struct efx_nic *efx)
  fail4:
 	release_mem_region(efx->membase_phys, efx->type->mem_map_size);
  fail3:
-	efx->membase_phys = 0UL;
+	efx->membase_phys = 0;
  fail2:
 	pci_disable_device(efx->pci_dev);
  fail1:
@@ -811,7 +811,7 @@ static void efx_fini_io(struct efx_nic *efx)
 
 	if (efx->membase_phys) {
 		pci_release_region(efx->pci_dev, efx->type->mem_bar);
-		efx->membase_phys = 0UL;
+		efx->membase_phys = 0;
 	}
 
 	pci_disable_device(efx->pci_dev);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
