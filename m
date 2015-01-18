From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] switchdev: fix compilation without CONFIG_NET_SWITCHDEV
Date: Sun, 18 Jan 2015 14:36:42 +0100
Message-ID: <1421588202-9270-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55558 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751586AbbARNgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jan 2015 08:36:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

The static inline declaration cannot end with a semicolon,
fix that to allow compilation without CONFIG_NET_SWITCHDEV.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/net/switchdev.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 201120e18e4d..205e63698da9 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -69,7 +69,7 @@ static inline int unregister_netdev_switch_notifier(struct notifier_block *nb)
 }
 
 static inline int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
-					       struct netdev_switch_notifier_info *info);
+					       struct netdev_switch_notifier_info *info)
 {
 	return NOTIFY_DONE;
 }
-- 
2.1.4
