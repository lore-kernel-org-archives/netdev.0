From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/40] ixgbe: DCB 82598 devices, tx_idx and rx_idx swapped
Date: Tue,  7 Jun 2011 05:32:51 -0700
Message-ID: <1307449995-9458-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43685 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752799Ab1FGMdZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 08:33:25 -0400
In-Reply-To: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

The tx_idx and rx_idx values are swapped on 82598 devices
with DCB enabled.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 747da66..111c3f9 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4635,8 +4635,8 @@ static void ixgbe_get_first_reg_idx(struct ixgbe_adapter *adapter, u8 tc,
 
 	switch (hw->mac.type) {
 	case ixgbe_mac_82598EB:
-		*tx = tc << 3;
-		*rx = tc << 2;
+		*tx = tc << 2;
+		*rx = tc << 3;
 		break;
 	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
-- 
1.7.5.2

