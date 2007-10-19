From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 2/7] tg3: MII => TP
Date: Fri, 19 Oct 2007 14:36:42 -0700
Message-ID: <1192829803.22064.556.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3124 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763755AbXJSVgx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 17:36:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes the PHY type reported through ethtool for copper
devices from MII to TP.  The latter is more accurate.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 253d761..66682b8 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8274,7 +8274,7 @@ static int tg3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				  SUPPORTED_100baseT_Full |
 				  SUPPORTED_10baseT_Half |
 				  SUPPORTED_10baseT_Full |
-				  SUPPORTED_MII);
+				  SUPPORTED_TP);
 		cmd->port = PORT_TP;
 	} else {
 		cmd->supported |= SUPPORTED_FIBRE;


