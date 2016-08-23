From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: [ethtool PATCH v4 1/4] ethtool-copy.h:sync with net
Date: Tue, 23 Aug 2016 06:30:30 -0700
Message-ID: <1471959033-1053-2-git-send-email-vidya@cumulusnetworks.com>
Cc: decot@googlers.com, bkenward@solarflare.com, daniel@iogearbox.net,
        galp@mellanox.com, roopa@cumulusnetworks.com,
        gospo@cumulusnetworks.com, dustin@cumulusnetworks.com,
        ben@decadent.org.uk
To: linville@tuxdriver.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34046 "EHLO
        mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752916AbcHWNaj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 09:30:39 -0400
Received: by mail-pa0-f49.google.com with SMTP id fi15so48443140pac.1
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 06:30:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

This covers kernel changes upto:

commit 89da45b8b5b2187734a11038b8593714f964ffd1
Author: Gal Pressman <galp@mellanox.com>
Date:   Thu Jun 23 17:02:43 2016 +0300

    ethtool: Add 50G baseSR2 link mode

    Add ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT bit.

    Signed-off-by: Gal Pressman <galp@mellanox.com>
    Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
    Cc: Ben Hutchings <bwh@kernel.org>
    Cc: David Decotigny <decot@googlers.com>
    Acked-By: David Decotigny <decot@googlers.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
---
 ethtool-copy.h | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 7c581ea..246f7b0 100644
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
@@ -1646,9 +1656,9 @@ enum ethtool_reset_flags {
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
