From: akpm@linux-foundation.org
Subject: [patch 2/4] drivers/net/bonding/bond_sysfs.c: suppress uninitialized var warning
Date: Fri, 28 Mar 2008 14:37:30 -0700
Message-ID: <200803282137.m2SLbUn3011629@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, fubar@us.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36393 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755927AbYC1Vn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:43:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

drivers/net/bonding/bond_sysfs.c: In function `bonding_store_slaves':
drivers/net/bonding/bond_sysfs.c:250: warning: 'original_mtu' might be used uninitialized in this function

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/bonding/bond_sysfs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/bonding/bond_sysfs.c~drivers-net-bonding-bond_sysfsc-suppress-uninitialized-var-warning drivers/net/bonding/bond_sysfs.c
--- a/drivers/net/bonding/bond_sysfs.c~drivers-net-bonding-bond_sysfsc-suppress-uninitialized-var-warning
+++ a/drivers/net/bonding/bond_sysfs.c
@@ -247,7 +247,7 @@ static ssize_t bonding_store_slaves(stru
 	char command[IFNAMSIZ + 1] = { 0, };
 	char *ifname;
 	int i, res, found, ret = count;
-	u32 original_mtu;
+	u32 uninitialized_var(original_mtu);
 	struct slave *slave;
 	struct net_device *dev = NULL;
 	struct bonding *bond = to_bond(d);
_
