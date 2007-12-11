From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] NET: Fix wrong comments for unregister_net*
Date: Tue, 11 Dec 2007 16:50:10 +0800
Message-ID: <475E4F42.8060102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:56618 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751907AbXLKIxQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 03:53:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH] NET: Fix wrong comments for unregister_net*

There are some return value comments for void functions.
Fixed it.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 dev.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

--- linux-2.6.24.rc4.org/net/core/dev.c	2007-12-11 16:40:36.000000000 +0800
+++ linux-2.6.24.rc4/net/core/dev.c	2007-12-11 16:42:40.000000000 +0800
@@ -3959,8 +3959,7 @@ void synchronize_net(void)
  *	@dev: device
  *
  *	This function shuts down a device interface and removes it
- *	from the kernel tables. On success 0 is returned, on a failure
- *	a negative errno code is returned.
+ *	from the kernel tables.
  *
  *	Callers must hold the rtnl semaphore.  You may want
  *	unregister_netdev() instead of this.
@@ -3978,8 +3977,7 @@ void unregister_netdevice(struct net_dev
  *	@dev: device
  *
  *	This function shuts down a device interface and removes it
- *	from the kernel tables. On success 0 is returned, on a failure
- *	a negative errno code is returned.
+ *	from the kernel tables.
  *
  *	This is just a wrapper for unregister_netdevice that takes
  *	the rtnl semaphore.  In general you want to use this and not

