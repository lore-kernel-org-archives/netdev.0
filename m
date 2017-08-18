From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 04/10] net: constify net_ns_type_operations
Date: Fri, 18 Aug 2017 13:46:22 -0700
Message-ID: <20170818204628.17147-5-sthemmin@microsoft.com>
References: <20170818204628.17147-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:36243 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751126AbdHRUql (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 16:46:41 -0400
Received: by mail-pg0-f49.google.com with SMTP id i12so71120354pgr.3
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 13:46:40 -0700 (PDT)
In-Reply-To: <20170818204628.17147-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This can be const.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 include/linux/netdevice.h | 2 +-
 net/core/net-sysfs.c      | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index eaa77bd9cb80..b0c928598dab 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4028,7 +4028,7 @@ static inline void netdev_class_remove_file(const struct class_attribute *class_
 	netdev_class_remove_file_ns(class_attr, NULL);
 }
 
-extern struct kobj_ns_type_operations net_ns_type_operations;
+extern const struct kobj_ns_type_operations net_ns_type_operations;
 
 const char *netdev_drivername(const struct net_device *dev);
 
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 99061b0a1ebd..2de441692f28 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -1461,7 +1461,7 @@ static const void *net_netlink_ns(struct sock *sk)
 	return sock_net(sk);
 }
 
-struct kobj_ns_type_operations net_ns_type_operations = {
+const struct kobj_ns_type_operations net_ns_type_operations = {
 	.type = KOBJ_NS_TYPE_NET,
 	.current_may_mount = net_current_may_mount,
 	.grab_current_ns = net_grab_current_ns,
-- 
2.11.0
