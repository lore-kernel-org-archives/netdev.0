From: Parav Pandit <parav.pandit@emulex.com>
Subject: [PATCHv1] ethtool: added support for 40G link.
Date: Wed, 27 Jun 2012 19:26:39 +0530
Message-ID: <847203bd-a11e-41c6-b451-abdeced5c5bf@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Parav Pandit <parav.pandit@emulex.com>
To: <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:13966 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753538Ab2F0JvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 05:51:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. defined values for KR4, CR4, SR4, LR4 PHY.

Signed-off-by: Parav Pandit <parav.pandit@emulex.com>
---
 ethtool-copy.h |    8 ++++++++
 ethtool.c      |    4 ++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 3027ca3..0e90e9b 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -913,6 +913,10 @@ enum ethtool_sfeatures_retval_bits {
 #define SUPPORTED_10000baseR_FEC	(1 << 20)
 #define SUPPORTED_20000baseMLD2_Full	(1 << 21)
 #define SUPPORTED_20000baseKR2_Full	(1 << 22)
+#define SUPPORTED_40000baseKR4_Full	(1 << 23)
+#define SUPPORTED_40000baseCR4_Full	(1 << 24)
+#define SUPPORTED_40000baseSR4_Full	(1 << 25)
+#define SUPPORTED_40000baseLR4_Full	(1 << 26)
 
 /* Indicates what features are advertised by the interface. */
 #define ADVERTISED_10baseT_Half		(1 << 0)
@@ -938,6 +942,10 @@ enum ethtool_sfeatures_retval_bits {
 #define ADVERTISED_10000baseR_FEC	(1 << 20)
 #define ADVERTISED_20000baseMLD2_Full	(1 << 21)
 #define ADVERTISED_20000baseKR2_Full	(1 << 22)
+#define ADVERTISED_40000baseKR4_Full	(1 << 23)
+#define ADVERTISED_40000baseCR4_Full	(1 << 24)
+#define ADVERTISED_40000baseSR4_Full	(1 << 25)
+#define ADVERTISED_40000baseLR4_Full	(1 << 26)
 
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the
diff --git a/ethtool.c b/ethtool.c
index b0d3eea..6e9418e 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -460,6 +460,10 @@ dump_link_caps(const char *prefix, const char *an_prefix, u32 mask)
 		{ 0, ADVERTISED_10000baseT_Full,    "10000baseT/Full" },
 		{ 0, ADVERTISED_10000baseKX4_Full,  "10000baseKX4/Full" },
 		{ 0, ADVERTISED_20000baseMLD2_Full, "20000baseMLD2/Full" },
+		{ 0, ADVERTISED_40000baseKR4_Full,  "40000baseKR4/Full" },
+		{ 0, ADVERTISED_40000baseCR4_Full,  "40000baseCR4/Full" },
+		{ 0, ADVERTISED_40000baseSR4_Full,  "40000baseSR4/Full" },
+		{ 0, ADVERTISED_40000baseLR4_Full,  "40000baseLR4/Full" },
 	};
 	int indent;
 	int did1, new_line_pend, i;
-- 
1.6.0.2
