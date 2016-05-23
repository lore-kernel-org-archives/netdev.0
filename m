From: vidya@cumulusnetworks.com
Subject: [RFC PATCH] ethtool: add support for 25G/50G/100G speed modes
Date: Sun, 22 May 2016 23:59:00 -0700
Message-ID: <1463986740-17572-1-git-send-email-vidya@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, netdev@vger.kernel.org
To: davem@davemloft.net, jiri@resnulli.us, ben@decadent.org.uk,
	ddecotig@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33065 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983AbcEWG7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 02:59:06 -0400
Received: by mail-pa0-f45.google.com with SMTP id xk12so59609730pac.0
        for <netdev@vger.kernel.org>; Sun, 22 May 2016 23:59:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

This patch enhances ethtool link mode bitmap to include
25G/50G/100G speed along with interface modes

Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
---
 include/uapi/linux/ethtool.h | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index 9222db8..5f030b4 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -1353,6 +1353,15 @@ enum ethtool_link_mode_bit_indices {
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
 
 	/* Last allowed bit for __ETHTOOL_LINK_MODE_LEGACY_MASK is bit
 	 * 31. Please do NOT define any SUPPORTED_* or ADVERTISED_*
@@ -1361,7 +1370,7 @@ enum ethtool_link_mode_bit_indices {
 	 */
 
 	__ETHTOOL_LINK_MODE_LAST
-	  = ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT,
+	  = ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT,
 };
 
 #define __ETHTOOL_LINK_MODE_LEGACY_MASK(base_name)	\
-- 
2.1.4
