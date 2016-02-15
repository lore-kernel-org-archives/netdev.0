From: Rami Rosen <rami.rosen@intel.com>
Subject: [PATCH net-next] core: remove unneded headers for net cgroup controllers.
Date: Mon, 15 Feb 2016 02:39:43 +0200
Message-ID: <1455496783-8478-1-git-send-email-rami.rosen@intel.com>
Cc: netdev@vger.kernel.org, tj@kernel.org, nhorman@tuxdriver.com,
	tgraf@suug.ch, Rami Rosen <rami.rosen@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:12984 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751447AbcBOAin (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Feb 2016 19:38:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 3ed80a6 (cgroup: drop module support) made including 
module.h redundant in the net cgroup controllers, 
netclassid_cgroup.c and netprio_cgroup.c. This patch 
removes them.

Signed-off-by: Rami Rosen <rami.rosen@intel.com>
---
 net/core/netclassid_cgroup.c | 1 -
 net/core/netprio_cgroup.c    | 1 -
 2 files changed, 2 deletions(-)

diff --git a/net/core/netclassid_cgroup.c b/net/core/netclassid_cgroup.c
index 0260c84..11fce17 100644
--- a/net/core/netclassid_cgroup.c
+++ b/net/core/netclassid_cgroup.c
@@ -9,7 +9,6 @@
  * Authors:	Thomas Graf <tgraf@suug.ch>
  */
 
-#include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/cgroup.h>
 #include <linux/fdtable.h>
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index f1efbc3..2ec86fc 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -11,7 +11,6 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
-#include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/types.h>
 #include <linux/string.h>
-- 
1.9.3
