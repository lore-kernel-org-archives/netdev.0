From: <zyjzy2000@gmail.com>
Subject: [PATCH 1/1] net: bonding: remove redudant brackets
Date: Wed, 9 Dec 2015 11:30:42 +0800
Message-ID: <1449631842-29535-1-git-send-email-zyjzy2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <j.vosburgh@gmail.com>, <vfalico@gmail.com>,
	<gospo@cumulusnetworks.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:61663 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753216AbbLIDa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 22:30:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yzhu1 <zyzy2000@gmail.com>

It is not necessary to use two brackets. As such, the redudant brackets
are removed.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: yzhu1 <zyzyj2000@gmail.com>
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
