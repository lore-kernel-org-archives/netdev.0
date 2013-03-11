From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 13/13] bnx2x: Restore FCoE 4-port devices
 support
Date: Mon, 11 Mar 2013 17:17:53 +0200
Message-ID: <1363015073-25743-14-git-send-email-yuvalmin@broadcom.com>
References: <1363015073-25743-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1764 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753672Ab3CKQZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Mar 2013 12:25:30 -0400
In-Reply-To: <1363015073-25743-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

bnx2x FW 1.78.17 properly supports DCBX configuration for 4-port devices,
enabling FCoE support on 57840 boards.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   10 ----------
 1 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index c7df223..04d123f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -12492,16 +12492,6 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 	if (CHIP_IS_E1x(bp))
 		bp->flags |= NO_FCOE_FLAG;
 
-	/* disable FCOE for 57840 device, until FW supports it */
-	switch (ent->driver_data) {
-	case BCM57840_O:
-	case BCM57840_4_10:
-	case BCM57840_2_20:
-	case BCM57840_MFO:
-	case BCM57840_MF:
-		bp->flags |= NO_FCOE_FLAG;
-	}
-
 	/* Set bp->num_queues for MSI-X mode*/
 	bnx2x_set_num_queues(bp);
 
-- 
1.7.7.2
