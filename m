From: Luis de Bethencourt <luisbg@osg.samsung.com>
Subject: [PATCH] gen_stats.c: Add description for cpu argument
Date: Sat, 19 Mar 2016 21:19:55 +0000
Message-ID: <1458422395-895-1-git-send-email-luisbg@osg.samsung.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Luis de Bethencourt <luisbg@osg.samsung.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:54908 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932222AbcCSVUD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Mar 2016 17:20:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function gnet_stats_copy_basic is missing the description of the cpu
argument in the documentation. Adding it.

Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
---
Hi,

Noticed this issue when running make htmldocs. I got the following warning:
.//net/core/gen_stats.c:155: warning: No description found for parameter 'cpu'

Thanks,
Luis

 net/core/gen_stats.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
index 1e2f46a..e640462 100644
--- a/net/core/gen_stats.c
+++ b/net/core/gen_stats.c
@@ -140,6 +140,7 @@ EXPORT_SYMBOL(__gnet_stats_copy_basic);
 /**
  * gnet_stats_copy_basic - copy basic statistics into statistic TLV
  * @d: dumping handle
+ * @cpu: copy statistic per cpu
  * @b: basic statistics
  *
  * Appends the basic statistics to the top level TLV created by
-- 
2.5.1
