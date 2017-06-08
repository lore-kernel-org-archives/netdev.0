From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net 3/3] ethtool.h: remind to update 802.3ad when adding new speeds
Date: Thu,  8 Jun 2017 11:18:13 +0200
Message-ID: <1496913493-23293-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1496913493-23293-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, thibaut.collet@6wind.com,
        linville@tuxdriver.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:41411 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751299AbdFHJSs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 05:18:48 -0400
In-Reply-To: <1496913493-23293-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each time a new speed is added, the bonding 802.3ad isn't updated. Add a
comment to remind the developer to update this driver.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/ethtool.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index d179d7767f51..7d4a594d5d58 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1486,8 +1486,10 @@ enum ethtool_link_mode_bit_indices {
  * it was forced up into this mode or autonegotiated.
  */
 
-/* The forced speed, in units of 1Mb. All values 0 to INT_MAX are legal. */
-/* Update drivers/net/phy/phy.c:phy_speed_to_str() when adding new values */
+/* The forced speed, in units of 1Mb. All values 0 to INT_MAX are legal.
+ * Update drivers/net/phy/phy.c:phy_speed_to_str() and
+ * drivers/net/bonding/bond_3ad.c:__get_link_speed() when adding new values.
+ */
 #define SPEED_10		10
 #define SPEED_100		100
 #define SPEED_1000		1000
-- 
2.8.1
