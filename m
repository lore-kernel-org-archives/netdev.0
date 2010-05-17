From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: [PATCH] netfilter: fix description of expected checkentry return code on xt_target
Date: Mon, 17 May 2010 23:00:30 +0300
Message-ID: <1274126430-13744-1-git-send-email-luciano.coelho@nokia.com>
Cc: kaber@trash.net
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The text describing the return codes that are expected on calls to
checkentry() was incorrect.  Instead of returning true or false, or an error
code, it should return 0 or an error code.

Signed-off-by: Luciano Coelho <luciano.coelho@nokia.com>
---
 include/linux/netfilter/x_tables.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index c2ee5d8..c00cc0c 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -333,7 +333,7 @@ struct xt_target {
 	/* Called when user tries to insert an entry of this type:
            hook_mask is a bitmask of hooks from which it can be
            called. */
-	/* Should return true or false, or an error code (-Exxxx). */
+	/* Should return 0 on success or an error code otherwise (-Exxxx). */
 	int (*checkentry)(const struct xt_tgchk_param *);
 
 	/* Called when entry of this type deleted. */
-- 
1.6.3.3

