From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] ixgbe: use NETIF_F_LRO
Date: Thu, 01 Jul 2010 16:58:25 -0700
Message-ID: <20100701235811.16456.66115.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:60653
	"EHLO qmta04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753172Ab0GAX6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 19:58:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stanislaw Gruszka <sgruszka@redhat.com>

Both ETH_FLAG_LRO and NETIF_F_LRO have the same value, but NETIF_F_LRO
is intended to use with netdev->features.

Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
Acked-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index b50b5ea..5275e9c 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -2237,7 +2237,7 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 				break;
 			}
 		} else if (!adapter->rx_itr_setting) {
-			netdev->features &= ~ETH_FLAG_LRO;
+			netdev->features &= ~NETIF_F_LRO;
 			if (data & ETH_FLAG_LRO)
 				e_info("rx-usecs set to 0, "
 					"LRO/RSC cannot be enabled.\n");

