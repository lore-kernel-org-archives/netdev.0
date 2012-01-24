From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net] netprio_cgroup.h: dont include module.h from other includes
Date: Tue, 24 Jan 2012 16:33:19 -0500
Message-ID: <1327440799-1057-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, jdb@comx.dk, eric.dumazet@gmail.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: nhorman@tuxdriver.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:47409 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757577Ab2AXVdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 16:33:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A considerable effort was invested in wiping out module.h
from being present in all the other standard includes.  This
one leaked back in, but once again isn't strictly necessary,
so remove it.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

---

[x86-64 modconfig, yesconfig and ppc64 defconfig all build OK]

diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index e503b87..7b2d431 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -13,7 +13,6 @@
 
 #ifndef _NETPRIO_CGROUP_H
 #define _NETPRIO_CGROUP_H
-#include <linux/module.h>
 #include <linux/cgroup.h>
 #include <linux/hardirq.h>
 #include <linux/rcupdate.h>
-- 
1.7.7.2
