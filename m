From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2.6.25] [IPV4] Reduce whitespaces in fib_rules.h.
Date: Thu, 13 Dec 2007 17:18:42 +0300
Message-ID: <20071213141842.GA9939@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, devel@openvz.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:60441 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757217AbXLMORO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 09:17:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are to many spaces between type and function name in the declaration
of fib rules manipulation routines. Eat them and save a couple of lines.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/fib_rules.h |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
index 2364db1..d20db25 100644
--- a/include/net/fib_rules.h
+++ b/include/net/fib_rules.h
@@ -101,14 +101,12 @@ static inline u32 frh_get_table(struct fib_rule_hdr *frh, struct nlattr **nla)
 	return frh->table;
 }
 
-extern int			fib_rules_register(struct fib_rules_ops *);
-extern int			fib_rules_unregister(struct fib_rules_ops *);
-extern void                     fib_rules_cleanup_ops(struct fib_rules_ops *);
+extern int fib_rules_register(struct fib_rules_ops *);
+extern int fib_rules_unregister(struct fib_rules_ops *);
+extern void fib_rules_cleanup_ops(struct fib_rules_ops *);
 
-extern int			fib_rules_lookup(struct fib_rules_ops *,
-						 struct flowi *, int flags,
-						 struct fib_lookup_arg *);
-extern int			fib_default_rule_add(struct fib_rules_ops *,
-						     u32 pref, u32 table,
-						     u32 flags);
+extern int fib_rules_lookup(struct fib_rules_ops *, struct flowi *, int flags,
+			    struct fib_lookup_arg *);
+extern int fib_default_rule_add(struct fib_rules_ops *, u32 pref, u32 table,
+				u32 flags);
 #endif
-- 
1.5.3.rc5

