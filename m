From: kaber@trash.net
Subject: [PATCH 3/3] netfilter: fix description of expected checkentry return code on xt_target
Date: Thu, 20 May 2010 18:00:46 +0200
Message-ID: <1274371246-26760-4-git-send-email-kaber@trash.net>
References: <1274371246-26760-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55215 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753350Ab0ETQAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 12:00:49 -0400
In-Reply-To: <1274371246-26760-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Luciano Coelho <luciano.coelho@nokia.com>

The text describing the return codes that are expected on calls to
checkentry() was incorrect.  Instead of returning true or false, or an error
code, it should return 0 or an error code.

Signed-off-by: Luciano Coelho <luciano.coelho@nokia.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
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
1.7.0.4

