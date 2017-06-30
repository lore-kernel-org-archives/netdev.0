From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/2] sfc: correct comment on efx_mcdi_process_event
Date: Fri, 30 Jun 2017 15:55:28 +0100
Message-ID: <eac92abd-a9a4-1204-78ec-d15aba2b861e@solarflare.com>
References: <fd53588b-c163-4c82-a8f2-c0b08ccb95b5@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:42181 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751946AbdF3Ozt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 10:55:49 -0400
In-Reply-To: <fd53588b-c163-4c82-a8f2-c0b08ccb95b5@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix out-of-date comment.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 00cd6a2..3df872f 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1301,7 +1301,7 @@ static void efx_mcdi_abandon(struct efx_nic *efx)
 	efx_schedule_reset(efx, RESET_TYPE_MCDI_TIMEOUT);
 }
 
-/* Called from  falcon_process_eventq for MCDI events */
+/* Called from efx_farch_ev_process and efx_ef10_ev_process for MCDI events */
 void efx_mcdi_process_event(struct efx_channel *channel,
 			    efx_qword_t *event)
 {
