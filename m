From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] ixgbe: set the correct DCB bit for pg tx settings
Date: Wed, 27 Jan 2010 18:37:44 -0800
Message-ID: <20100128023717.19441.27328.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:51035
	"EHLO qmta04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755835Ab0A1CiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 21:38:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Set the correct bit BIT_PG_TX when tx PG settings are set.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 56f37f6..383e799 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -223,7 +223,7 @@ static void ixgbe_dcbnl_set_pg_bwg_cfg_tx(struct net_device *netdev, int bwg_id,
 
 	if (adapter->temp_dcb_cfg.bw_percentage[0][bwg_id] !=
 	    adapter->dcb_cfg.bw_percentage[0][bwg_id]) {
-		adapter->dcb_set_bitmap |= BIT_PG_RX;
+		adapter->dcb_set_bitmap |= BIT_PG_TX;
 		adapter->dcb_set_bitmap |= BIT_RESETLINK;
 	}
 }

