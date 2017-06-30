From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 1/2] sfc: change Unknown MCDI event message to print
 full event.
Date: Fri, 30 Jun 2017 15:54:33 +0100
Message-ID: <b38824ec-79ed-7a56-cfb7-5e71467f91e7@solarflare.com>
References: <fd53588b-c163-4c82-a8f2-c0b08ccb95b5@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:38575 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751666AbdF3Oyt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 10:54:49 -0400
In-Reply-To: <fd53588b-c163-4c82-a8f2-c0b08ccb95b5@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index b942245..00cd6a2 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1389,8 +1389,9 @@ void efx_mcdi_process_event(struct efx_channel *channel,
 				MCDI_EVENT_FIELD(*event, PROXY_RESPONSE_RC));
 		break;
 	default:
-		netif_err(efx, hw, efx->net_dev, "Unknown MCDI event 0x%x\n",
-			  code);
+		netif_err(efx, hw, efx->net_dev,
+			  "Unknown MCDI event " EFX_QWORD_FMT "\n",
+			  EFX_QWORD_VAL(*event));
 	}
 }
 
