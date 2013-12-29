From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] bonding: make local function static
Date: Sun, 29 Dec 2013 11:41:25 -0800
Message-ID: <20131229114125.1db8d541@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:41827 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752307Ab3L2Tl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 14:41:29 -0500
Received: by mail-pd0-f174.google.com with SMTP id x10so10721676pdj.33
        for <netdev@vger.kernel.org>; Sun, 29 Dec 2013 11:41:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_xmit_slave_id is only used in main.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 drivers/net/bonding/bond_main.c |    2 +-
 drivers/net/bonding/bonding.h   |    1 -
 2 files changed, 1 insertion(+), 2 deletions(-)

--- a/drivers/net/bonding/bond_main.c	2013-12-24 15:15:26.649742798 -0800
+++ b/drivers/net/bonding/bond_main.c	2013-12-24 15:16:00.429288806 -0800
@@ -3511,7 +3511,7 @@ unwind:
  * it fails, it tries to find the first available slave for transmission.
  * The skb is consumed in all cases, thus the function is void.
  */
-void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id)
+static void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id)
 {
 	struct list_head *iter;
 	struct slave *slave;
--- a/drivers/net/bonding/bonding.h	2013-12-24 15:15:26.649742798 -0800
+++ b/drivers/net/bonding/bonding.h	2013-12-24 15:16:00.429288806 -0800
@@ -417,7 +417,6 @@ struct bond_net;
 
 int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond, struct slave *slave);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
-void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id);
 int bond_create(struct net *net, const char *name);
 int bond_create_sysfs(struct bond_net *net);
 void bond_destroy_sysfs(struct bond_net *net);
