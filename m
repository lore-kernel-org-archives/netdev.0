From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 3/9] Removed bogus 'fall-thru' comments
Date: Wed, 7 May 2008 12:56:57 +0100
Message-ID: <20080507115657.GO2217@solarflare.com>
References: <20080507114121.GL2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:55744 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755185AbYEGL5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 07:57:40 -0400
Content-Disposition: inline
In-Reply-To: <20080507114121.GL2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fall-through is expected outside a switch statement.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    2 --
 drivers/net/sfc/rx.c     |    1 -
 2 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 46db549..9cac344 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2468,14 +2468,12 @@ int falcon_probe_nic(struct efx_nic *efx)
  fail5:
 	falcon_free_buffer(efx, &efx->irq_status);
  fail4:
-	/* fall-thru */
  fail3:
 	if (nic_data->pci_dev2) {
 		pci_dev_put(nic_data->pci_dev2);
 		nic_data->pci_dev2 = NULL;
 	}
  fail2:
-	/* fall-thru */
  fail1:
 	kfree(efx->nic_data);
 	return rc;
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index 551299b..9fd1984 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -736,7 +736,6 @@ void __efx_rx_packet(struct efx_channel *channel,
 	/* Update allocation strategy method */
 	channel->rx_alloc_level += RX_ALLOC_FACTOR_SKB;
 
-	/* fall-thru */
 done:
 	efx->net_dev->last_rx = jiffies;
 }

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
