From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] ixgbe: Remove DPRINTK messages in DCB mode
Date: Thu, 16 Jul 2009 16:43:31 -0700
Message-ID: <20090716234331.23595.48405.stgit@localhost.localdomain>
References: <20090716234303.23595.85275.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Lucy Liu <lucy.liu@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:36609
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933219AbZGPXtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 19:49:42 -0400
In-Reply-To: <20090716234303.23595.85275.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucy Liu <lucy.liu@intel.com>

Remove debug DPRINTK in DCB mode netlink interface.

Signed-off-by: Lucy Liu <lucy.liu@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 5b8dab2..da2c851 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -106,8 +106,6 @@ static u8 ixgbe_dcbnl_get_state(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	DPRINTK(DRV, INFO, "Get DCB Admin Mode.\n");
-
 	return !!(adapter->flags & IXGBE_FLAG_DCB_ENABLED);
 }
 
@@ -116,8 +114,6 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 	u8 err = 0;
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	DPRINTK(DRV, INFO, "Set DCB Admin Mode.\n");
-
 	if (state > 0) {
 		/* Turn on DCB */
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)

