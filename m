From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] vxlan: Advertise SCTP checksum offloads
Date: Mon, 28 Apr 2014 12:52:15 -0700
Message-ID: <1398714735-23920-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7535 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751460AbaD1Twh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 15:52:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Some HW can offload encapsulated SCTP checksums.  Advertise the capability
for such cases.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Acked-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/vxlan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1dfee9a..988208f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2293,6 +2293,7 @@ static void vxlan_setup(struct net_device *dev)
 	dev->features	|= NETIF_F_SG | NETIF_F_HW_CSUM;
 	dev->features   |= NETIF_F_RXCSUM;
 	dev->features   |= NETIF_F_GSO_SOFTWARE;
+	dev->features   |= NETIF_F_SCTP_CSUM;
 
 	dev->vlan_features = dev->features;
 	dev->features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
-- 
1.9.0
