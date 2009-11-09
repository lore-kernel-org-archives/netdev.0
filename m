From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 2/4] bnx2x: Remove misleading error print
Date: Mon, 9 Nov 2009 18:09:28 +0200
Message-ID: <1257782968.4101.41.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1776 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755718AbZKIQN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Nov 2009 11:13:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Failing to allocate MSI-X vectors is not an error and should not be printed as
such

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 856ca38..a8ebd46 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -7478,11 +7478,6 @@ static int bnx2x_set_int_mode(struct bnx2x *bp)
 		rc = bnx2x_enable_msix(bp);
 		if (rc) {
 			/* failed to enable MSI-X */
-			if (bp->multi_mode)
-				BNX2X_ERR("Multi requested but failed to "
-					  "enable MSI-X (rx %d tx %d), "
-					  "set number of queues to 1\n",
-					  bp->num_rx_queues, bp->num_tx_queues);
 			bp->num_rx_queues = 1;
 			bp->num_tx_queues = 1;
 		}
-- 
1.5.4.3




