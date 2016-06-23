From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 07/10] ethtool: Add 50G baseSR2 link mode
Date: Thu, 23 Jun 2016 17:02:43 +0300
Message-ID: <1466690566-14700-8-git-send-email-saeedm@mellanox.com>
References: <1466690566-14700-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ben Hutchings <bwh@kernel.org>,
	David Decotigny <decot@googlers.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:35441 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751634AbcFWPrg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2016 11:47:36 -0400
In-Reply-To: <1466690566-14700-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Add ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT bit.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Cc: Ben Hutchings <bwh@kernel.org>
Cc: David Decotigny <decot@googlers.com>
---
 include/uapi/linux/ethtool.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 5f030b4..b8f38e8 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1362,6 +1362,7 @@ enum ethtool_link_mode_bit_indices {
 	ETHTOOL_LINK_MODE_100000baseSR4_Full_BIT	= 37,
 	ETHTOOL_LINK_MODE_100000baseCR4_Full_BIT	= 38,
 	ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT	= 39,
+	ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT         = 40,
 
 	/* Last allowed bit for __ETHTOOL_LINK_MODE_LEGACY_MASK is bit
 	 * 31. Please do NOT define any SUPPORTED_* or ADVERTISED_*
@@ -1370,7 +1371,7 @@ enum ethtool_link_mode_bit_indices {
 	 */
 
 	__ETHTOOL_LINK_MODE_LAST
-	  = ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT,
+	  = ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT,
 };
 
 #define __ETHTOOL_LINK_MODE_LEGACY_MASK(base_name)	\
-- 
2.8.0
