From: Pavel Belous <pavel.s.belous@gmail.com>
Subject: [PATCH net] net: ethtool: add support for 2500BaseT and 5000BaseT link modes
Date: Sat, 28 Jan 2017 22:53:28 +0300
Message-ID: <1485633208-2012-1-git-send-email-pavel.s.belous@gmail.com>
Cc: netdev@vger.kernel.org, decot@googlers.com,
        linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34862 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751306AbdA1UAX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2017 15:00:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduce support for 2500BaseT and 5000BaseT link modes.
These modes are included in the new IEEE 802.3bz standard.

Signed-off-by: Pavel Belous <pavel.s.belous@gmail.com>
---
 include/uapi/linux/ethtool.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index f0db778..3dc91a4 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1384,6 +1384,8 @@ enum ethtool_link_mode_bit_indices {
 	ETHTOOL_LINK_MODE_10000baseLR_Full_BIT	= 44,
 	ETHTOOL_LINK_MODE_10000baseLRM_Full_BIT	= 45,
 	ETHTOOL_LINK_MODE_10000baseER_Full_BIT	= 46,
+	ETHTOOL_LINK_MODE_2500baseT_Full_BIT	= 47,
+	ETHTOOL_LINK_MODE_5000baseT_Full_BIT	= 48,
 
 
 	/* Last allowed bit for __ETHTOOL_LINK_MODE_LEGACY_MASK is bit
@@ -1393,7 +1395,7 @@ enum ethtool_link_mode_bit_indices {
 	 */
 
 	__ETHTOOL_LINK_MODE_LAST
-	  = ETHTOOL_LINK_MODE_10000baseER_Full_BIT,
+	  = ETHTOOL_LINK_MODE_5000baseT_Full_BIT,
 };
 
 #define __ETHTOOL_LINK_MODE_LEGACY_MASK(base_name)	\
-- 
2.7.4
