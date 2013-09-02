From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next 2/5] bonding: trivial: remove outdated comment and braces
Date: Mon,  2 Sep 2013 13:51:39 +0200
Message-ID: <1378122702-28943-3-git-send-email-nikolay@redhat.com>
References: <1378122702-28943-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36237 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757866Ab3IBLzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 07:55:23 -0400
In-Reply-To: <1378122702-28943-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't have to release all slaves when closing the bond dev, so remove
the outdated comment and the braces around the left single statement.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 05e638b..486e041 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3210,12 +3210,8 @@ static int bond_close(struct net_device *bond_dev)
 
 	bond_work_cancel_all(bond);
 	bond->send_peer_notif = 0;
-	if (bond_is_lb(bond)) {
-		/* Must be called only after all
-		 * slaves have been released
-		 */
+	if (bond_is_lb(bond))
 		bond_alb_deinitialize(bond);
-	}
 	bond->recv_probe = NULL;
 
 	return 0;
-- 
1.8.1.4
