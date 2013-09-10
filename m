From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/1] sfc: Staticize efx_ef10_filter_update_rx_scatter
Date: Tue, 10 Sep 2013 15:19:27 +0530
Message-ID: <1378806567-30625-1-git-send-email-sachin.kamat@linaro.org>
Cc: bhutchings@solarflare.com, linux-net-drivers@solarflare.com,
	sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:41535 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982Ab3IJKH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 06:07:29 -0400
Received: by mail-pb0-f43.google.com with SMTP id md4so7305478pbc.2
        for <netdev@vger.kernel.org>; Tue, 10 Sep 2013 03:07:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'efx_ef10_filter_update_rx_scatter' is used only in this file.
Make it static.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/ethernet/sfc/ef10.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 5f42313..6956bd2 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -2121,7 +2121,7 @@ out_unlock:
 	return rc;
 }
 
-void efx_ef10_filter_update_rx_scatter(struct efx_nic *efx)
+static void efx_ef10_filter_update_rx_scatter(struct efx_nic *efx)
 {
 	/* no need to do anything here on EF10 */
 }
-- 
1.7.9.5
