From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6] sfc: Fix order of channel_name array
 dimensions
Date: Mon, 13 Sep 2010 15:14:49 +0100
Message-ID: <1284387289.2316.34.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:22229 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399Ab0IMOOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 10:14:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/net_driver.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 4b3f680..152342d 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -729,7 +729,7 @@ struct efx_nic {
 	enum reset_type reset_pending;
 
 	struct efx_channel *channel[EFX_MAX_CHANNELS];
-	char channel_name[IFNAMSIZ + 6][EFX_MAX_CHANNELS];
+	char channel_name[EFX_MAX_CHANNELS][IFNAMSIZ + 6];
 
 	unsigned rxq_entries;
 	unsigned txq_entries;
-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

