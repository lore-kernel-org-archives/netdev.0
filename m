From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 43/47] staging: et131x: remove unused prototype et131x_vlan_rx_register
Date: Wed, 20 Jul 2011 16:54:45 +0200
Message-ID: <1311173689-17419-44-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	gregkh@suse.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32148 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752310Ab1GTO4Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:56:16 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/staging/et131x/et131x_netdev.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/et131x/et131x_netdev.c b/drivers/staging/et131x/et131x_netdev.c
index b25bae2..95555d2 100644
--- a/drivers/staging/et131x/et131x_netdev.c
+++ b/drivers/staging/et131x/et131x_netdev.c
@@ -97,7 +97,6 @@ int et131x_tx(struct sk_buff *skb, struct net_device *netdev);
 void et131x_tx_timeout(struct net_device *netdev);
 int et131x_change_mtu(struct net_device *netdev, int new_mtu);
 int et131x_set_mac_addr(struct net_device *netdev, void *new_mac);
-void et131x_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp);
 void et131x_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid);
 void et131x_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid);
 
-- 
1.7.6

