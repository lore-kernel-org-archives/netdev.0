From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH ethtool 1/3] ethtool: Copy high-speed bits from ethtool.h
Date: Mon, 22 Aug 2016 08:50:37 +0300
Message-ID: <1471845039-28718-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1471845039-28718-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vidya@cumulusnetworks.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <netdev@vger.kernel.org>, <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39414 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751736AbcHVFvS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 01:51:18 -0400
In-Reply-To: <1471845039-28718-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 ethtool-copy.h | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 7c581ea..f14300c 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -1351,6 +1351,16 @@ enum ethtool_link_mode_bit_indices {
 	ETHTOOL_LINK_MODE_56000baseCR4_Full_BIT	= 28,
 	ETHTOOL_LINK_MODE_56000baseSR4_Full_BIT	= 29,
 	ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT	= 30,
+	ETHTOOL_LINK_MODE_25000baseCR_Full_BIT	= 31,
+	ETHTOOL_LINK_MODE_25000baseKR_Full_BIT	= 32,
+	ETHTOOL_LINK_MODE_25000baseSR_Full_BIT	= 33,
+	ETHTOOL_LINK_MODE_50000baseCR2_Full_BIT	= 34,
+	ETHTOOL_LINK_MODE_50000baseKR2_Full_BIT	= 35,
+	ETHTOOL_LINK_MODE_100000baseKR4_Full_BIT	= 36,
+	ETHTOOL_LINK_MODE_100000baseSR4_Full_BIT	= 37,
+	ETHTOOL_LINK_MODE_100000baseCR4_Full_BIT	= 38,
+	ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT	= 39,
+	ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT         = 40,
 
 	/* Last allowed bit for __ETHTOOL_LINK_MODE_LEGACY_MASK is bit
 	 * 31. Please do NOT define any SUPPORTED_* or ADVERTISED_*
@@ -1359,7 +1369,7 @@ enum ethtool_link_mode_bit_indices {
 	 */
 
 	__ETHTOOL_LINK_MODE_LAST
-	  = ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT,
+	  = ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT,
 };
 
 #define __ETHTOOL_LINK_MODE_LEGACY_MASK(base_name)	\
-- 
1.9.3
