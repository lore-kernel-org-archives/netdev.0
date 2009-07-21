From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 8/10] bnx2x: Set LED in loopback test
Date: Tue, 21 Jul 2009 18:47:49 +0300
Message-ID: <1248191269.18195.51.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2313 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755464AbZGUPsM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 11:48:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index b9c85a2..a24bc51 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -5494,6 +5494,11 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 		}
 		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE +
 			    params->port*4, 0);
+
+		bnx2x_set_led(bp, params->port, LED_MODE_OPER,
+			    vars->line_speed, params->hw_led_mode,
+			    params->chip_id);
+
 	} else
 	/* No loopback */
 	{
-- 
1.5.4.3




