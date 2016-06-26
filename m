From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: [ethtool PATCH v2 4/4] ethtool: Enhancing link mode bits to support 25G/50G/100G
Date: Sun, 26 Jun 2016 12:45:07 -0700
Message-ID: <1466970307-2411-5-git-send-email-vidya@cumulusnetworks.com>
Cc: bkenward@solarflare.com, daniel@iogearbox.net, galp@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	dustin@cumulusnetworks.com
To: ben@decadent.org.uk, netdev@vger.kernel.org, bwh@kernel.org,
	davem@davemloft.net, decot@googlers.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35419 "EHLO
	mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720AbcFZTpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2016 15:45:19 -0400
Received: by mail-pf0-f177.google.com with SMTP id c2so54715365pfa.2
        for <netdev@vger.kernel.org>; Sun, 26 Jun 2016 12:45:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

Enhancing link mode bits to support 25G/50G/100G
for supported and advertised speed mode bits

Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
---
 ethtool.c | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/ethtool.c b/ethtool.c
index 1d6564e..5c3c765 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -512,6 +512,15 @@ static void init_global_link_mode_masks(void)
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
 	};
 	static const enum ethtool_link_mode_bit_indices
 		additional_advertised_flags_bits[] = {
@@ -632,6 +641,24 @@ static void dump_link_caps(const char *prefix, const char *an_prefix,
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
 	};
 	int indent;
 	int did1, new_line_pend, i;
-- 
2.1.4
