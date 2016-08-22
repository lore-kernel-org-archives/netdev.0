From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH ethtool 2/3] ethtool: Add support for 25g, 50g and 100g advertise
Date: Mon, 22 Aug 2016 08:50:38 +0300
Message-ID: <1471845039-28718-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1471845039-28718-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vidya@cumulusnetworks.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <netdev@vger.kernel.org>, <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39415 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751736AbcHVFvU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 01:51:20 -0400
In-Reply-To: <1471845039-28718-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 ethtool.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/ethtool.c b/ethtool.c
index 4aa4762..aa8f34d 100644
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
1.9.3
