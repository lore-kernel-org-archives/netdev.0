From: Zhu Yanjun <yanjun.zhu@windriver.com>
Subject: [PATCH 1/1] net: bonding: remove redudant brackets
Date: Thu, 3 Dec 2015 18:00:55 +0800
Message-ID: <1449136855-13108-1-git-send-email-yanjun.zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:47465 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932791AbbLCKAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 05:00:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not necessary to use two brackets. As such, the redudant brackets
are removed.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
---
 drivers/net/bonding/bond_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9e0f8a7..09f8a48 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1351,7 +1351,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	 * the current ifenslave will set the interface down prior to
 	 * enslaving it; the old ifenslave will not.
 	 */
-	if ((slave_dev->flags & IFF_UP)) {
+	if (slave_dev->flags & IFF_UP) {
 		netdev_err(bond_dev, "%s is up - this may be due to an out of date ifenslave\n",
 			   slave_dev->name);
 		res = -EPERM;
-- 
1.7.9.5
