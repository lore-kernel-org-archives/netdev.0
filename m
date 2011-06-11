From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/13] ixgbe: DCB and perfect filters can coexist
Date: Fri, 10 Jun 2011 20:02:17 -0700
Message-ID: <1307761341-5267-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307761341-5267-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:29360 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758552Ab1FKDC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 23:02:29 -0400
In-Reply-To: <1307761341-5267-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

Now flow directors perfect filters features can coexist with DCB.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_dcb_nl.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index b229feb..08c7aeb 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -135,7 +135,6 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 		case ixgbe_mac_82599EB:
 		case ixgbe_mac_X540:
 			adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
-			adapter->flags &= ~IXGBE_FLAG_FDIR_PERFECT_CAPABLE;
 			break;
 		default:
 			break;
-- 
1.7.5.2

