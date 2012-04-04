From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 09/10] bnx2x: Fix BCM57711+BCM84823 link issue
Date: Wed, 4 Apr 2012 14:29:02 +0300
Message-ID: <1333538942-9904-10-git-send-email-yanivr@broadcom.com>
References: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2757 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756109Ab2DDJ3r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 05:29:47 -0400
In-Reply-To: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a link problem on the second port of BCM57711 + BCM84823 boards due to 
incorrect macro usage.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index ce95ef7..7e41682 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -10177,7 +10177,7 @@ static void bnx2x_848x3_link_reset(struct bnx2x_phy *phy,
 	u8 port;
 	u16 val16;
 
-	if (!(CHIP_IS_E1(bp)))
+	if (!(CHIP_IS_E1x(bp)))
 		port = BP_PATH(bp);
 	else
 		port = params->port;
@@ -10204,7 +10204,7 @@ static void bnx2x_848xx_set_link_led(struct bnx2x_phy *phy,
 	u16 val;
 	u8 port;
 
-	if (!(CHIP_IS_E1(bp)))
+	if (!(CHIP_IS_E1x(bp)))
 		port = BP_PATH(bp);
 	else
 		port = params->port;
-- 
1.7.7.1
