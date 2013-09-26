From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next] bonding: trivial: remove forgotten bond_next_vlan()
Date: Fri, 27 Sep 2013 01:22:01 +0200
Message-ID: <1380237721-8229-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40563 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750917Ab3IZXVk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 19:21:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's a forgotten function declaration, which was removed some time ago
already.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bonding.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 5b71601..05d6268 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -429,7 +429,6 @@ static inline bool slave_can_tx(struct slave *slave)
 struct bond_net;
 
 int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond, struct slave *slave);
-struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
 void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id);
 int bond_create(struct net *net, const char *name);
-- 
1.8.4
