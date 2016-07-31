From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] net: i10e: use matching format indentifiers
Date: Sun, 31 Jul 2016 11:39:28 +0200
Message-ID: <1469957968-726-1-git-send-email-xypron.glpk@gmx.de>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:50059 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751333AbcGaJkm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2016 05:40:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

i is defined as int but output as %u several times.
Change the definition to unsigned.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index c912e04..8b08a69 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1532,7 +1532,7 @@ static void i40e_get_strings(struct net_device *netdev, u32 stringset,
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
 	char *p = (char *)data;
-	int i;
+	unsigned int i;
 
 	switch (stringset) {
 	case ETH_SS_TEST:
-- 
2.8.1
