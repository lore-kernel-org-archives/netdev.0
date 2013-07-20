From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 4/4] bonding: bond_sysfs.c Checkpatch cleanup
Date: Sat, 20 Jul 2013 15:24:02 +0800
Message-ID: <51EA3B12.3060805@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:62062 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760Ab3GTH11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jul 2013 03:27:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/bonding/bond_sysfs.c:1302: ERROR: else should follow close brace '}'
net/bonding/bond_sysfs.c:1314: ERROR: else should follow close brace '}'

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_sysfs.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index d01a189..2a7b383 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1298,8 +1298,7 @@ static ssize_t bonding_store_active_slave(struct device *d,
 					bond->dev->name,
 					slave->dev->name);
 				goto out;
-			}
-			else {
+			} else {
 				if ((new_active) &&
 				    (old_active) &&
 				    (new_active->link == BOND_LINK_UP) &&
@@ -1310,8 +1309,7 @@ static ssize_t bonding_store_active_slave(struct device *d,
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
