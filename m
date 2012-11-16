From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] net: remove unnecessary wireless includes
Date: Fri, 16 Nov 2012 21:59:21 +0100
Message-ID: <1353099561-14339-1-git-send-email-johannes@sipsolutions.net>
Cc: netdev@vger.kernel.org, Johannes Berg <johannes.berg@intel.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:54454 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752867Ab2KPU64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 15:58:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

The wireless and wext includes in net-sysfs.c aren't
needed, so remove them.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/core/net-sysfs.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index bcf02f6..b407879 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -18,11 +18,9 @@
 #include <net/sock.h>
 #include <net/net_namespace.h>
 #include <linux/rtnetlink.h>
-#include <linux/wireless.h>
 #include <linux/vmalloc.h>
 #include <linux/export.h>
 #include <linux/jiffies.h>
-#include <net/wext.h>
 
 #include "net-sysfs.h"
 
-- 
1.8.0
