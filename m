From: FNST-Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/1] netcore: minor cleanup for register_netdevice
Date: Thu, 06 Sep 2007 13:27:24 +0800
Message-ID: <46DF8FBC.20106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wang Chen <ellre923@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:59615 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751647AbXIFF1w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2007 01:27:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- minor logic cleanup

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

diff -Nurp linux-2.6.22.4.org/net/core/dev.c  linux-2.6.22.4/net/core/dev.c
--- linux-2.6.22.4.org/net/core/dev.c    2007-08-22 15:33:40.000000000 
+0800
+++ linux-2.6.22.4/net/core/dev.c    2007-09-06 13:27:35.000000000 +0800
@@ -3075,8 +3075,6 @@ int register_netdevice(struct net_device
    dev->xmit_lock_owner = -1;
    spin_lock_init(&dev->ingress_lock);

-    dev->iflink = -1;
-
    /* Init, if this function is available */
    if (dev->init) {
        ret = dev->init(dev);
@@ -3093,8 +3091,7 @@ int register_netdevice(struct net_device
    }

    dev->ifindex = dev_new_index();
-    if (dev->iflink == -1)
-        dev->iflink = dev->ifindex;
+    dev->iflink = dev->ifindex;

    /* Check for existence of name */
    head = dev_name_hash(dev->name);





