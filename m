From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net 5/5] bnx2x: disable dcb on 578xx since not supported
 yet
Date: Tue, 9 Aug 2011 16:11:13 +0300
Message-ID: <1312895473.21856.4.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2861 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751943Ab1HINO3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2011 09:14:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_dcb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_dcb.c b/drivers/net/bnx2x/bnx2x_dcb.c
index a4ea35f..a1e004a 100644
--- a/drivers/net/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/bnx2x/bnx2x_dcb.c
@@ -920,7 +920,7 @@ static void bnx2x_dcbx_admin_mib_updated_params(struct bnx2x *bp,
 
 void bnx2x_dcbx_set_state(struct bnx2x *bp, bool dcb_on, u32 dcbx_enabled)
 {
-	if (!CHIP_IS_E1x(bp)) {
+	if (!CHIP_IS_E1x(bp) && !CHIP_IS_E3(bp)) {
 		bp->dcb_state = dcb_on;
 		bp->dcbx_enabled = dcbx_enabled;
 	} else {
-- 
1.7.2.2




