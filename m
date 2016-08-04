From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH] rhashtable-test: Fix max_size parameter description
Date: Thu,  4 Aug 2016 12:37:17 +0200
Message-ID: <1470307037-2069-1-git-send-email-phil@nwl.cc>
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53342 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753685AbcHDKsf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 06:48:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks like a simple copy'n'paste error.

Fixes: 1aa661f5c3df1 ("rhashtable-test: Measure time to insert, remove & traverse entries")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/test_rhashtable.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index a8b987b77c762..6f839d98fa0a4 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -38,7 +38,7 @@ MODULE_PARM_DESC(runs, "Number of test runs per variant (default: 4)");
 
 static int max_size = 0;
 module_param(max_size, int, 0);
-MODULE_PARM_DESC(runs, "Maximum table size (default: calculated)");
+MODULE_PARM_DESC(max_size, "Maximum table size (default: calculated)");
 
 static bool shrinking = false;
 module_param(shrinking, bool, 0);
-- 
2.8.2
