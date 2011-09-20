From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH ethtool 1/3] ethtool: file ethtool-copy.h update.
Date: Tue, 20 Sep 2011 03:31:33 -0700
Message-ID: <1316514695-17157-2-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1316514695-17157-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:20467 "EHLO
	TX2EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754551Ab1ITKmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 06:42:42 -0400
In-Reply-To: <1316514695-17157-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Used linux-3.0.1-net-next tree for the update.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 ethtool-copy.h |   24 ++++++++++++++++++------
 1 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index c7a18f7..0fbbb25 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -265,7 +265,7 @@ struct ethtool_pauseparam {
 	__u32	cmd;	/* ETHTOOL_{G,S}PAUSEPARAM */
 
 	/* If the link is being auto-negotiated (via ethtool_cmd.autoneg
-	 * being true) the user may set 'autonet' here non-zero to have the
+	 * being true) the user may set 'autoneg' here non-zero to have the
 	 * pause parameters be auto-negotiated too.  In such a case, the
 	 * {rx,tx}_pause values below determine what capabilities are
 	 * advertised.
@@ -284,7 +284,7 @@ enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
 	ETH_SS_STATS,
 	ETH_SS_PRIV_FLAGS,
-	ETH_SS_NTUPLE_FILTERS,
+	ETH_SS_NTUPLE_FILTERS,	/* Do not use, GRXNTUPLE is now deprecated */
 	ETH_SS_FEATURES,
 };
 
@@ -307,9 +307,21 @@ struct ethtool_sset_info {
 				   __u32's, etc. */
 };
 
+/**
+ * enum ethtool_test_flags - flags definition of ethtool_test
+ * @ETH_TEST_FL_OFFLINE: if set perform online and offline tests, otherwise
+ *	only online tests.
+ * @ETH_TEST_FL_FAILED: Driver set this flag if test fails.
+ * @ETH_TEST_FL_EXTERNAL_LB: Application request to perform external loopback
+ *	test.
+ * @ETH_TEST_FL_EXTERNAL_LB_DONE: Driver performed the external loopback test
+ */
+
 enum ethtool_test_flags {
-	ETH_TEST_FL_OFFLINE	= (1 << 0),	/* online / offline */
-	ETH_TEST_FL_FAILED	= (1 << 1),	/* test passed / failed */
+	ETH_TEST_FL_OFFLINE	= (1 << 0),
+	ETH_TEST_FL_FAILED	= (1 << 1),
+	ETH_TEST_FL_EXTERNAL_LB	= (1 << 2),
+	ETH_TEST_FL_EXTERNAL_LB_DONE	= (1 << 3),
 };
 
 /* for requesting NIC test and getting results*/
@@ -739,7 +751,7 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_FLASHDEV	0x00000033 /* Flash firmware to device */
 #define ETHTOOL_RESET		0x00000034 /* Reset hardware */
 #define ETHTOOL_SRXNTUPLE	0x00000035 /* Add an n-tuple filter to device */
-#define ETHTOOL_GRXNTUPLE	0x00000036 /* Get n-tuple filters from device */
+#define ETHTOOL_GRXNTUPLE	0x00000036 /* deprecated */
 #define ETHTOOL_GSSET_INFO	0x00000037 /* Get string set info */
 #define ETHTOOL_GRXFHINDIR	0x00000038 /* Get RX flow hash indir'n table */
 #define ETHTOOL_SRXFHINDIR	0x00000039 /* Set RX flow hash indir'n table */
@@ -809,7 +821,7 @@ enum ethtool_sfeatures_retval_bits {
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the
  * devices settings, these indicate the current mode and whether
- * it was foced up into this mode or autonegotiated.
+ * it was forced up into this mode or autonegotiated.
  */
 
 /* The forced speed, 10Mb, 100Mb, gigabit, 2.5Gb, 10GbE. */
-- 
1.6.3.3
