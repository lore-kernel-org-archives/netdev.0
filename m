From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 12/13] tg3: MII => TP
Date: Fri, 09 Nov 2007 16:39:07 -0800
Message-ID: <1194655147.5745.274.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1634 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751990AbXKJAjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 19:39:08 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes the PHY type reported through ethtool for copper
devices from MII to TP.  The latter is more accurate.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 8e76092..8d518cc 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8329,7 +8329,7 @@ static int tg3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				  SUPPORTED_100baseT_Full |
 				  SUPPORTED_10baseT_Half |
 				  SUPPORTED_10baseT_Full |
-				  SUPPORTED_MII);
+				  SUPPORTED_TP);
 		cmd->port = PORT_TP;
 	} else {
 		cmd->supported |= SUPPORTED_FIBRE;


