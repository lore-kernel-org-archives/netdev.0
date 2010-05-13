From: Shirley Ma <mashirle@us.ibm.com>
Subject: [PATCH net-next] ixgbevf: Enable GRO by default
Date: Thu, 13 May 2010 12:51:14 -0700
Message-ID: <1273780274.30943.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:46677 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932610Ab0EMTv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 15:51:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable GRO by default for performance. 

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---
 
 drivers/net/ixgbevf/ixgbevf_main.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 40f47b8..1bbb05e 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -3415,6 +3415,7 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 	netdev->features |= NETIF_F_IPV6_CSUM;
 	netdev->features |= NETIF_F_TSO;
 	netdev->features |= NETIF_F_TSO6;
+	netdev->features |= NETIF_F_GRO;
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
 	netdev->vlan_features |= NETIF_F_IP_CSUM;


