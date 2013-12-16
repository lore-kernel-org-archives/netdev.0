From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 6/10] bonding: make local function static
Date: Mon, 16 Dec 2013 10:42:14 -0800
Message-ID: <20131216104214.68f8d6fe@nehalam.linuxnetplumber.net>
References: <20131216103606.62524131@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:48806 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755540Ab3LPTka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 14:40:30 -0500
Received: by mail-pa0-f46.google.com with SMTP id kl14so3374553pab.19
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 11:40:29 -0800 (PST)
In-Reply-To: <20131216103606.62524131@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/bonding/bond_main.c	2013-12-14 11:18:15.297586790 -0800
+++ b/drivers/net/bonding/bond_main.c	2013-12-15 10:25:04.445785839 -0800
@@ -3511,7 +3511,7 @@ unwind:
  * it fails, it tries to find the first available slave for transmission.
  * The skb is consumed in all cases, thus the function is void.
  */
-void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id)
+static void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id)
 {
 	struct list_head *iter;
 	struct slave *slave;
--- a/drivers/net/bonding/bonding.h	2013-12-14 11:18:15.301586736 -0800
+++ b/drivers/net/bonding/bonding.h	2013-12-15 10:25:04.445785839 -0800
@@ -417,7 +417,6 @@ struct bond_net;
 
 int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond, struct slave *slave);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
-void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id);
 int bond_create(struct net *net, const char *name);
 int bond_create_sysfs(struct bond_net *net);
 void bond_destroy_sysfs(struct bond_net *net);
