From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/16] ixgbe: DCB 82598 devices, tx_idx and rx_idx swapped
Date: Tue, 21 Jun 2011 01:33:42 -0700
Message-ID: <1308645228-32444-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1308645228-32444-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34914 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754405Ab1FUIeD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2011 04:34:03 -0400
In-Reply-To: <1308645228-32444-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index 3a88fb6..f829d36 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4636,8 +4636,8 @@ static void ixgbe_get_first_reg_idx(struct ixgbe_adapter *adapter, u8 tc,
 
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
1.7.5.4

