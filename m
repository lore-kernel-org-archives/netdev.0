From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-2.6 7/8] bnx2x: Fix AER setting for BCM57712
Date: Tue, 18 Jan 2011 16:33:52 +0200
Message-ID: <1295361232.5281.90.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3540 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752219Ab1AROd1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jan 2011 09:33:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix AER settings for BCM57712 to allow accessing all device addresses range in CL45 MDC/MDIO

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index bb1c811..7160ec5 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -1573,7 +1573,7 @@ static void bnx2x_set_aer_mmd_xgxs(struct link_params *params,
 
 	offset = phy->addr + ser_lane;
 	if (CHIP_IS_E2(bp))
-		aer_val = 0x2800 + offset - 1;
+		aer_val = 0x3800 + offset - 1;
 	else
 		aer_val = 0x3800 + offset;
 	CL45_WR_OVER_CL22(bp, phy,
-- 
1.7.1









