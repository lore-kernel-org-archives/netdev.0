From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH 06/10] bnx2x: fix MB index for 4-port devices
Date: Tue, 19 Jul 2011 14:42:40 +0300
Message-ID: <1311075760.30287.8.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4946 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752271Ab1GSLuc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 07:50:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 333f5d6..4b255e5 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -1104,7 +1104,7 @@ struct bnx2x {
 #define BP_VN(bp)			(BP_E1HVN(bp)) /*remove when approved*/
 #define BP_L_ID(bp)			(BP_E1HVN(bp) << 2)
 #define BP_FW_MB_IDX(bp)		(BP_PORT(bp) +\
-					 BP_VN(bp) * (CHIP_IS_E1x(bp) ? 2  : 1))
+	  BP_VN(bp) * ((CHIP_IS_E1x(bp) || (CHIP_MODE_IS_4_PORT(bp))) ? 2  : 1))
 
 	struct net_device	*dev;
 	struct pci_dev		*pdev;
-- 
1.7.2.2




