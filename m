From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 4/4 v2] bonding: bond_sysfs.c checkpatch cleanup
Date: Tue, 23 Jul 2013 15:25:32 +0800
Message-ID: <51EE2FEC.6090009@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:17597 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754278Ab3GWHZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 03:25:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/bonding/bond_sysfs.c:1302: ERROR: else should follow close brace '}'
net/bonding/bond_sysfs.c:1314: ERROR: else should follow close brace '}'

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
---
 drivers/net/bonding/bond_sysfs.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 8a5a6a3..ae02c19 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1302,8 +1302,7 @@ static ssize_t bonding_store_active_slave(struct device *d,
 					bond->dev->name,
 					slave->dev->name);
 				goto out;
-			}
-			else {
+			} else {
 				if ((new_active) &&
 				    (old_active) &&
 				    (new_active->link == BOND_LINK_UP) &&
@@ -1314,8 +1313,7 @@ static ssize_t bonding_store_active_slave(struct device *d,
 						slave->dev->name);
 					bond_change_active_slave(bond,
 								 new_active);
-				}
-				else {
+				} else {
 					pr_info("%s: Could not set %s as"
 						" active slave; either %s is"
 						" down or the link is down.\n",
-- 
1.8.0
