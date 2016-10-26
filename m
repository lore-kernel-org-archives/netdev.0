From: idosch@idosch.org
Subject: [PATCH net-next] switchdev: Remove redundant variable
Date: Wed, 26 Oct 2016 12:03:03 +0300
Message-ID: <1477472583-11710-1-git-send-email-idosch@idosch.org>
Cc: netdev@vger.kernel.org, mlxsw@mellanox.com,
        Ido Schimmel <idosch@mellanox.com>
To: davem@davemloft.net, jiri@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:53197 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932302AbcJZJDo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 05:03:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Instead of storing return value in 'err' and returning, just return
directly.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 net/switchdev/switchdev.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 02beb35..6f145b5 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -624,13 +624,10 @@ EXPORT_SYMBOL_GPL(unregister_switchdev_notifier);
 int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
 			     struct switchdev_notifier_info *info)
 {
-	int err;
-
 	ASSERT_RTNL();
 
 	info->dev = dev;
-	err = raw_notifier_call_chain(&switchdev_notif_chain, val, info);
-	return err;
+	return raw_notifier_call_chain(&switchdev_notif_chain, val, info);
 }
 EXPORT_SYMBOL_GPL(call_switchdev_notifiers);
 
-- 
2.7.4
