From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] net: ieee802154/adf7242: syntax error ifdef DEBUG
Date: Tue, 17 May 2016 23:58:40 +0200
Message-ID: <1463522320-10964-1-git-send-email-xypron.glpk@gmx.de>
Cc: linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Michael Hennerich <michael.hennerich@analog.com>,
	Alexander Aring <aar@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:57492 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940AbcEQV66 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2016 17:58:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If DEBUG is defined, a superfluous closing brace
is introduced.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ieee802154/adf7242.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ieee802154/adf7242.c b/drivers/net/ieee802154/adf7242.c
index b82e39d..9fa7ac9 100644
--- a/drivers/net/ieee802154/adf7242.c
+++ b/drivers/net/ieee802154/adf7242.c
@@ -915,7 +915,6 @@ static void adf7242_debug(u8 irq1)
 		(stat & 0xf) == RC_STATUS_PHY_RDY ? "RC_STATUS_PHY_RDY" : "",
 		(stat & 0xf) == RC_STATUS_RX ? "RC_STATUS_RX" : "",
 		(stat & 0xf) == RC_STATUS_TX ? "RC_STATUS_TX" : "");
-	}
 #endif
 }
 
-- 
2.1.4
