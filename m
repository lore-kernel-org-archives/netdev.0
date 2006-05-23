From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 6/9] ixgb: remove hardcoded number
Date: Tue, 23 May 2006 11:04:16 -0700
Message-ID: <20060523180415.17428.83288.stgit@gitlost.site>
References: <20060523180302.17428.89125.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke <auke-jan.h.kok"@intel.com,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:45317 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932154AbWEWR7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 13:59:18 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060523180302.17428.89125.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This adds a define for an awkward and uncommented value.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_ethtool.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index 4db63e0..f6baf28 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -44,6 +44,8 @@ extern void ixgb_free_rx_resources(struc
 extern void ixgb_free_tx_resources(struct ixgb_adapter *adapter);
 extern void ixgb_update_stats(struct ixgb_adapter *adapter);
 
+#define IXGB_ALL_RAR_ENTRIES 16
+
 struct ixgb_stats {
 	char stat_string[ETH_GSTRING_LEN];
 	int sizeof_stat;
@@ -300,7 +302,7 @@ ixgb_get_regs(struct net_device *netdev,
 	*reg++ = IXGB_READ_REG(hw, RXCSUM);	/*  20 */
 
 	/* there are 16 RAR entries in hardware, we only use 3 */
-	for(i = 0; i < 16; i++) {
+	for(i = 0; i < IXGB_ALL_RAR_ENTRIES; i++) {
 		*reg++ = IXGB_READ_REG_ARRAY(hw, RAL, (i << 1)); /*21,...,51 */
 		*reg++ = IXGB_READ_REG_ARRAY(hw, RAH, (i << 1)); /*22,...,52 */
 	}



--
Auke Kok <auke-jan.h.kok@intel.com>
