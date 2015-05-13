From: sfeldma@gmail.com
Subject: [PATCH net-next 1/4] switchdev: sparse warning: make __switchdev_port_obj_add static
Date: Tue, 12 May 2015 23:03:51 -0700
Message-ID: <1431497034-22153-2-git-send-email-sfeldma@gmail.com>
References: <1431497034-22153-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36507 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644AbbEMGCv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 02:02:51 -0400
Received: by pabsx10 with SMTP id sx10so39731978pab.3
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 23:02:51 -0700 (PDT)
In-Reply-To: <1431497034-22153-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 net/switchdev/switchdev.c |    3 ++-
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
1.7.10.4
