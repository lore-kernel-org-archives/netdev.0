From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH next]bond: Kill directly reference of netdev->priv
Date: Tue, 02 Dec 2008 21:32:44 +0800
Message-ID: <493538FC.3060609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52976 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754729AbYLBNcx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 08:32:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simply replace netdev->priv with netdev_priv().

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/bonding/bond_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a339a80..e422dba 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1992,7 +1992,7 @@ void bond_destroy(struct bonding *bond)
 
 static void bond_destructor(struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 
 	if (bond->wq)
 		destroy_workqueue(bond->wq);
-- 
1.5.3.4


