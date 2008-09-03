From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 41/52] sfc: Add check for memory allocation failure in falcon_probe_nic()
Date: Wed, 3 Sep 2008 15:07:50 +0100
Message-ID: <20080903140750.GX7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:54234 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753801AbYICOH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 10:07:58 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index e0c0b23..636fe82 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2758,6 +2758,8 @@ int falcon_probe_nic(struct efx_nic *efx)
 
 	/* Allocate storage for hardware specific data */
 	nic_data = kzalloc(sizeof(*nic_data), GFP_KERNEL);
+	if (!nic_data)
+		return -ENOMEM;
 	efx->nic_data = nic_data;
 
 	/* Determine number of ports etc. */
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
