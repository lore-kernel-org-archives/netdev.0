From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: [ethtool PATCH v2 1/4] ethtool-copy.h:sync with net
Date: Sun, 26 Jun 2016 12:45:04 -0700
Message-ID: <1466970307-2411-2-git-send-email-vidya@cumulusnetworks.com>
Cc: bkenward@solarflare.com, daniel@iogearbox.net, galp@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	dustin@cumulusnetworks.com
To: ben@decadent.org.uk, netdev@vger.kernel.org, bwh@kernel.org,
	davem@davemloft.net, decot@googlers.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33968 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbcFZTpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 15:45:12 -0400
Received: by mail-pa0-f53.google.com with SMTP id bz2so52194079pad.1
        for <netdev@vger.kernel.org>; Sun, 26 Jun 2016 12:45:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

This covers kernel changes upto:

commit 3851112e4737cd52aaeda0ce8d084be9ee128106
Author: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Date:   Sun May 22 23:59:00 2016 -0700

    ethtool: add support for 25G/50G/100G speed modes

    This patch enhances ethtool link mode bitmap to include
    25G/50G/100G speed along with interface modes

Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 ethtool-copy.h | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 7c581ea..7817779 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -1351,6 +1351,15 @@ enum ethtool_link_mode_bit_indices {
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
@@ -1359,7 +1368,7 @@ enum ethtool_link_mode_bit_indices {
 	 */
 
 	__ETHTOOL_LINK_MODE_LAST
-	  = ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT,
+	  = ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT,
 };
 
 #define __ETHTOOL_LINK_MODE_LEGACY_MASK(base_name)	\
@@ -1646,9 +1655,9 @@ enum ethtool_reset_flags {
  *	%ETHTOOL_GLINKSETTINGS: on entry, number of words passed by user
  *	(>= 0); on return, if handshake in progress, negative if
  *	request size unsupported by kernel: absolute value indicates
- *	kernel recommended size and cmd field is 0, as well as all the
- *	other fields; otherwise (handshake completed), strictly
- *	positive to indicate size used by kernel and cmd field is
+ *	kernel expected size and all the other fields but cmd
+ *	are 0; otherwise (handshake completed), strictly positive
+ *	to indicate size used by kernel and cmd field stays
  *	%ETHTOOL_GLINKSETTINGS, all other fields populated by driver. For
  *	%ETHTOOL_SLINKSETTINGS: must be valid on entry, ie. a positive
  *	value returned previously by %ETHTOOL_GLINKSETTINGS, otherwise
-- 
2.1.4
