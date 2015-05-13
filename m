From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] switchdev: make __switchdev_port_obj_add static
Date: Wed, 13 May 2015 07:53:51 +0200
Message-ID: <1431496431-12902-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, fengguang.wu@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33118 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584AbbEMFxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 01:53:55 -0400
Received: by wicmx19 with SMTP id mx19so1914833wic.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 22:53:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kill sparse warning:

>> net/switchdev/switchdev.c:190:5: sparse: symbol '__switchdev_port_obj_add' was not declared. Should it be static?

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/switchdev/switchdev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 65d49d4..a267f77 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -188,7 +188,8 @@ int switchdev_port_attr_set(struct net_device *dev, struct switchdev_attr *attr)
 }
 EXPORT_SYMBOL_GPL(switchdev_port_attr_set);
 
-int __switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj)
+static int __switchdev_port_obj_add(struct net_device *dev,
+				    struct switchdev_obj *obj)
 {
 	const struct switchdev_ops *ops = dev->switchdev_ops;
 	struct net_device *lower_dev;
-- 
1.9.3
