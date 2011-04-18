From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 2/5] be2net: Add code to display nic speeds other
 than 1Gbps/10Gbps
Date: Mon, 18 Apr 2011 17:30:04 -0500
Message-ID: <20110418223004.GA9483@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:45950 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753124Ab1DRWaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 18:30:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_ethtool.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_ethtool.c b/drivers/net/benet/be_ethtool.c
index 22523b9..33c2bec 100644
--- a/drivers/net/benet/be_ethtool.c
+++ b/drivers/net/benet/be_ethtool.c
@@ -384,12 +384,21 @@ static int be_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 			ecmd->speed = link_speed*10;
 		} else {
 			switch (mac_speed) {
+			case PHY_LINK_SPEED_10MBPS:
+				ecmd->speed = SPEED_10;
+				break;
+			case PHY_LINK_SPEED_100MBPS:
+				ecmd->speed = SPEED_100;
+				break;
 			case PHY_LINK_SPEED_1GBPS:
 				ecmd->speed = SPEED_1000;
 				break;
 			case PHY_LINK_SPEED_10GBPS:
 				ecmd->speed = SPEED_10000;
 				break;
+			case PHY_LINK_SPEED_ZERO:
+				ecmd->speed = 0;
+				break;
 			}
 		}
 
-- 
1.7.1

