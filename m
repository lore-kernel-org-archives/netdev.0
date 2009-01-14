From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 30/34]bnx2x: Prevent self test loopback failures
Date: Wed, 14 Jan 2009 18:44:16 +0200
Message-ID: <1231951456.11301.151.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1340 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764134AbZANQpd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:45:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Setting loopback requires time to take effect

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index d9e1cfc..4ce107c 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -3583,7 +3583,7 @@ static void bnx2x_set_xgxs_loopback(struct link_params *params,
 			       (MDIO_REG_BANK_CL73_IEEEB0 +
 				(MDIO_CL73_IEEEB0_CL73_AN_CONTROL & 0xf)),
 			       0x6041);
-
+		msleep(200);
 		/* set aer mmd back */
 		bnx2x_set_aer_mmd(params, vars);
 
-- 
1.5.4.3




