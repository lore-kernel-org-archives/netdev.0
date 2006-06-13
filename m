From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.18 2/6] bnx2: Allow WoL settings on new 5708 chips
Date: Mon, 12 Jun 2006 17:17:08 -0700
Message-ID: <1150157828.26173.7.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:54030 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S932676AbWFMAUO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 20:20:14 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow WOL settings on 5708 B2 and newer chips that have the problem
fixed.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 1a5f7a8..49c09da 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5642,7 +5642,9 @@ bnx2_init_board(struct pci_dev *pdev, st
 		}
 	}
 
-	if (CHIP_NUM(bp) == CHIP_NUM_5708)
+	if ((CHIP_ID(bp) == CHIP_ID_5708_A0) ||
+	    (CHIP_ID(bp) == CHIP_ID_5708_B0) ||
+	    (CHIP_ID(bp) == CHIP_ID_5708_B1))
 		bp->flags |= NO_WOL_FLAG;
 
 	if (CHIP_ID(bp) == CHIP_ID_5706_A0) {


