From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 10/10] bnx2x: disable FCoE for 578xx devices since not
 yet supported
Date: Tue, 19 Jul 2011 14:46:11 +0300
Message-ID: <1311075971.30287.13.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>, mchan@broadcom.com
To: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1572 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752364Ab1GSLur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 07:50:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index e4dea11..28ef7fa 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -10575,8 +10575,8 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	bp->qm_cid_count = bnx2x_set_qm_cid_count(bp);
 
 #ifdef BCM_CNIC
-	/* disable FCOE L2 queue for E1x*/
-	if (CHIP_IS_E1x(bp))
+	/* disable FCOE L2 queue for E1x and E3*/
+	if (CHIP_IS_E1x(bp) || CHIP_IS_E3(bp))
 		bp->flags |= NO_FCOE_FLAG;
 
 #endif
-- 
1.7.2.2




