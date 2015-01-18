From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] switchdev: fix typo in inline function definition
Date: Sun, 18 Jan 2015 10:25:56 +0100
Message-ID: <1421573156-6101-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.co
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:65357 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbbARJ0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 04:26:00 -0500
Received: by mail-wi0-f182.google.com with SMTP id n3so9270533wiv.3
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 01:25:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/switchdev.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 201120e..205e636 100644
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
1.9.3
