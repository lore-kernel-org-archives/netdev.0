From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] vxge: Add const to ethtool_driver_stats_keys
Date: Wed, 01 Apr 2015 12:29:13 -0700
Message-ID: <1427916553.31790.70.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Jon Mason <jdmason@kudzu.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0096.hostedemail.com ([216.40.44.96]:55160 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753368AbbDAT3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 15:29:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move about half a KB of data to text.

Miscellanea:

o Move strings out of the .h file into the .c file
  in case the .h file is ever #included twice

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/neterion/vxge/vxge-ethtool.c | 19 +++++++++++++++++++
 drivers/net/ethernet/neterion/vxge/vxge-ethtool.h | 19 -------------------
 2 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c b/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c
index b07d552..be916eb 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c
@@ -18,6 +18,25 @@
 
 #include "vxge-ethtool.h"
 
+static const char ethtool_driver_stats_keys[][ETH_GSTRING_LEN] = {
+	{"\n DRIVER STATISTICS"},
+	{"vpaths_opened"},
+	{"vpath_open_fail_cnt"},
+	{"link_up_cnt"},
+	{"link_down_cnt"},
+	{"tx_frms"},
+	{"tx_errors"},
+	{"tx_bytes"},
+	{"txd_not_free"},
+	{"txd_out_of_desc"},
+	{"rx_frms"},
+	{"rx_errors"},
+	{"rx_bytes"},
+	{"rx_mcast"},
+	{"pci_map_fail_cnt"},
+	{"skb_alloc_fail_cnt"}
+};
+
 /**
  * vxge_ethtool_sset - Sets different link parameters.
  * @dev: device pointer.
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-ethtool.h b/drivers/net/ethernet/neterion/vxge/vxge-ethtool.h
index 6cf3044..065a2c0 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-ethtool.h
+++ b/drivers/net/ethernet/neterion/vxge/vxge-ethtool.h
@@ -19,25 +19,6 @@
 /* Ethtool related variables and Macros. */
 static int vxge_ethtool_get_sset_count(struct net_device *dev, int sset);
 
-static char ethtool_driver_stats_keys[][ETH_GSTRING_LEN] = {
-	{"\n DRIVER STATISTICS"},
-	{"vpaths_opened"},
-	{"vpath_open_fail_cnt"},
-	{"link_up_cnt"},
-	{"link_down_cnt"},
-	{"tx_frms"},
-	{"tx_errors"},
-	{"tx_bytes"},
-	{"txd_not_free"},
-	{"txd_out_of_desc"},
-	{"rx_frms"},
-	{"rx_errors"},
-	{"rx_bytes"},
-	{"rx_mcast"},
-	{"pci_map_fail_cnt"},
-	{"skb_alloc_fail_cnt"}
-};
-
 #define VXGE_TITLE_LEN			5
 #define VXGE_HW_VPATH_STATS_LEN 	27
 #define VXGE_HW_AGGR_STATS_LEN  	13
