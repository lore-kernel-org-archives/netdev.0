From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-next 5/8] bnx2x: Remove unneeded setting of XAUI low
 power to BCM8727
Date: Wed, 1 Sep 2010 22:51:30 +0300
Message-ID: <1283370690.4403.136.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1286 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755177Ab0IAQdR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 12:33:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unneeded setting of XAUI low power to BCM8727. This was required
only in older microcode which is not in the field. 

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_link.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 7a8df7a..e2945b4 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -4200,7 +4200,6 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				       val);
 
 			bnx2x_8727_power_module(bp, params, ext_phy_addr, 1);
-			bnx2x_bcm8073_set_xaui_low_power_mode(params);
 
 			bnx2x_cl45_read(bp, params->port,
 				      ext_phy_type,
-- 
1.7.1




