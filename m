From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [PATCH -next] ixgbe: use NETIF_F_LRO
Date: Tue, 29 Jun 2010 16:38:57 +0200
Message-ID: <20100629163857.0dcc1245@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61830 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756151Ab0F2OjC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jun 2010 10:39:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both ETH_FLAG_LRO and NETIF_F_LRO have the same value, but NETIF_F_LRO
is intended to use with netdev->features.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 873b45e..e2ab4ae 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2227,7 +2227,7 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 				break;
 			}
 		} else if (!adapter->rx_itr_setting) {
-			netdev->features &= ~ETH_FLAG_LRO;
+			netdev->features &= ~NETIF_F_LRO;
 			if (data & ETH_FLAG_LRO)
 				e_info("rx-usecs set to 0, "
 					"LRO/RSC cannot be enabled.\n");
-- 
1.5.5.6

