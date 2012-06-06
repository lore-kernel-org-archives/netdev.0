From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH ethtool] ethtool: fix to display support for KX4 and KX PHY
Date: Wed, 6 Jun 2012 15:03:36 -0500
Message-ID: <20120606200336.GA21620@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:15312 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758056Ab2FFUEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 16:04:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 ethtool.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index f18f611..546a43a 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -424,6 +424,13 @@ dump_link_caps(const char *prefix, const char *an_prefix, u32 mask)
 	if (mask & ADVERTISED_1000baseT_Full) {
 		did1++; fprintf(stdout, "1000baseT/Full ");
 	}
+	if (did1 && (mask & ADVERTISED_1000baseKX_Full)) {
+		fprintf(stdout, "\n");
+		fprintf(stdout, "	%*s", indent, "");
+	}
+	if (mask & ADVERTISED_1000baseKX_Full) {
+		did1++; fprintf(stdout, "1000baseKX/Full ");
+	}
 	if (did1 && (mask & ADVERTISED_2500baseX_Full)) {
 		fprintf(stdout, "\n");
 		fprintf(stdout, "	%*s", indent, "");
@@ -438,6 +445,13 @@ dump_link_caps(const char *prefix, const char *an_prefix, u32 mask)
 	if (mask & ADVERTISED_10000baseT_Full) {
 		did1++; fprintf(stdout, "10000baseT/Full ");
 	}
+	if (did1 && (mask & ADVERTISED_10000baseKX4_Full)) {
+		fprintf(stdout, "\n");
+		fprintf(stdout, "	%*s", indent, "");
+	}
+	if (mask & ADVERTISED_10000baseKX4_Full) {
+		did1++; fprintf(stdout, "10000baseKX4/Full ");
+	}
 	if (did1 && (mask & ADVERTISED_20000baseMLD2_Full)) {
 		fprintf(stdout, "\n");
 		fprintf(stdout, "	%*s", indent, "");
-- 
1.7.5.4
