From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 26/33] sfc: Remove leading spaces
Date: Fri, 12 Dec 2008 12:57:18 +0000
Message-ID: <20081212125717.GZ10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:58447 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757927AbYLLM5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:57:20 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 2c53ef4..8107460 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2940,10 +2940,10 @@ int falcon_probe_nic(struct efx_nic *efx)
 		goto fail5;
 
 	/* Initialise I2C adapter */
- 	efx->i2c_adap.owner = THIS_MODULE;
+	efx->i2c_adap.owner = THIS_MODULE;
 	nic_data->i2c_data = falcon_i2c_bit_operations;
 	nic_data->i2c_data.data = efx;
- 	efx->i2c_adap.algo_data = &nic_data->i2c_data;
+	efx->i2c_adap.algo_data = &nic_data->i2c_data;
 	efx->i2c_adap.dev.parent = &efx->pci_dev->dev;
 	strlcpy(efx->i2c_adap.name, "SFC4000 GPIO", sizeof(efx->i2c_adap.name));
 	rc = i2c_bit_add_bus(&efx->i2c_adap);
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
