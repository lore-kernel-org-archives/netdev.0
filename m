From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] bonding: remove unused variable "found"
Date: Mon, 17 May 2010 15:49:54 +0200
Message-ID: <20100517134953.GD2878@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5036 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751805Ab0EQNt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 09:49:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index b8bec08..392e291 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -219,7 +219,7 @@ static ssize_t bonding_store_slaves(struct device *d,
 {
 	char command[IFNAMSIZ + 1] = { 0, };
 	char *ifname;
-	int i, res, found, ret = count;
+	int i, res, ret = count;
 	u32 original_mtu;
 	struct slave *slave;
 	struct net_device *dev = NULL;
@@ -245,7 +245,6 @@ static ssize_t bonding_store_slaves(struct device *d,
 	if (command[0] == '+') {
 
 		/* Got a slave name in ifname.  Is it already in the list? */
-		found = 0;
 
 		dev = __dev_get_by_name(dev_net(bond->dev), ifname);
 		if (!dev) {
