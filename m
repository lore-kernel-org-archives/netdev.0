From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: [ethtool PATCH v4 4/4] ethtool: Enhancing link mode bits to support 25G/50G/100G
Date: Tue, 23 Aug 2016 06:30:33 -0700
Message-ID: <1471959033-1053-5-git-send-email-vidya@cumulusnetworks.com>
Cc: decot@googlers.com, bkenward@solarflare.com, daniel@iogearbox.net,
        galp@mellanox.com, roopa@cumulusnetworks.com,
        gospo@cumulusnetworks.com, dustin@cumulusnetworks.com,
        ben@decadent.org.uk
To: linville@tuxdriver.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35631 "EHLO
        mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755371AbcHWNam (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 09:30:42 -0400
Received: by mail-pa0-f44.google.com with SMTP id hb8so29843738pac.2
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 06:30:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

Enhancing link mode bits to support 25G/50G/100G
for supported and advertised speed mode bits

Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Acked-By: David Decotigny <decot@googlers.com>
---
 ethtool.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/ethtool.c b/ethtool.c
index 1d6564e..ab58c7f 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -512,6 +512,16 @@ static void init_global_link_mode_masks(void)
 		ETHTOOL_LINK_MODE_56000baseCR4_Full_BIT,
 		ETHTOOL_LINK_MODE_56000baseSR4_Full_BIT,
 		ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT,
+		ETHTOOL_LINK_MODE_25000baseCR_Full_BIT,
+		ETHTOOL_LINK_MODE_25000baseKR_Full_BIT,
+		ETHTOOL_LINK_MODE_25000baseSR_Full_BIT,
+		ETHTOOL_LINK_MODE_50000baseCR2_Full_BIT,
+		ETHTOOL_LINK_MODE_50000baseKR2_Full_BIT,
+		ETHTOOL_LINK_MODE_100000baseKR4_Full_BIT,
+		ETHTOOL_LINK_MODE_100000baseSR4_Full_BIT,
+		ETHTOOL_LINK_MODE_100000baseCR4_Full_BIT,
+		ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT,
+		ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT,
 	};
 	static const enum ethtool_link_mode_bit_indices
 		additional_advertised_flags_bits[] = {
@@ -632,6 +642,26 @@ static void dump_link_caps(const char *prefix, const char *an_prefix,
 		  "56000baseSR4/Full" },
 		{ 0, ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT,
 		  "56000baseLR4/Full" },
+		{ 0, ETHTOOL_LINK_MODE_25000baseCR_Full_BIT,
+		  "25000baseCR/Full" },
+		{ 0, ETHTOOL_LINK_MODE_25000baseKR_Full_BIT,
+		  "25000baseKR/Full" },
+		{ 0, ETHTOOL_LINK_MODE_25000baseSR_Full_BIT,
+		  "25000baseSR/Full" },
+		{ 0, ETHTOOL_LINK_MODE_50000baseCR2_Full_BIT,
+		  "50000baseCR2/Full" },
+		{ 0, ETHTOOL_LINK_MODE_50000baseKR2_Full_BIT,
+		  "50000baseKR2/Full" },
+		{ 0, ETHTOOL_LINK_MODE_100000baseKR4_Full_BIT,
+		  "100000baseKR4/Full" },
+		{ 0, ETHTOOL_LINK_MODE_100000baseSR4_Full_BIT,
+		  "100000baseSR4/Full" },
+		{ 0, ETHTOOL_LINK_MODE_100000baseCR4_Full_BIT,
+		  "100000baseCR4/Full" },
+		{ 0, ETHTOOL_LINK_MODE_100000baseLR4_ER4_Full_BIT,
+		  "100000baseLR4_ER4/Full" },
+		{ 0, ETHTOOL_LINK_MODE_50000baseSR2_Full_BIT,
+		  "50000baseSR2/Full" },
 	};
 	int indent;
 	int did1, new_line_pend, i;
-- 
2.1.4
