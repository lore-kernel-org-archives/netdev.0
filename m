From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] net: phy: add missing SPEED_14000
Date: Fri,  9 Jun 2017 15:45:32 +0200
Message-ID: <1497015932-6917-1-git-send-email-nicolas.dichtel@6wind.com>
References: <1496966712.1929.25.camel@perches.com>
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, thibaut.collet@6wind.com,
        linville@tuxdriver.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net, joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:48295 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751534AbdFINpq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 09:45:46 -0400
In-Reply-To: <1496966712.1929.25.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Fixes: 0d7e2d2166f6 ("IB/ipoib: add get_link_ksettings in ethtool")
Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/phy/phy.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 7524caa0f29d..eebb0e1c70ff 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -54,6 +54,8 @@ static const char *phy_speed_to_str(int speed)
 		return "5Gbps";
 	case SPEED_10000:
 		return "10Gbps";
+	case SPEED_14000:
+		return "14Gbps";
 	case SPEED_20000:
 		return "20Gbps";
 	case SPEED_25000:
-- 
2.8.1
