From: Cong Wang <amwang@redhat.com>
Subject: [Patch] iproute2: clean up genl/genl.c::usage()
Date: Fri, 14 Dec 2012 14:10:38 +0800
Message-ID: <1355465438-20586-1-git-send-email-amwang@redhat.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57767 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751150Ab2LNGKp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2012 01:10:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gcc attribute can be used in definition, no need to
redeclare it.

Cc: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/genl/genl.c b/genl/genl.c
index 49b6596..a1e55e0 100644
--- a/genl/genl.c
+++ b/genl/genl.c
@@ -97,9 +97,7 @@ noexist:
 	return f;
 }
 
-static void usage(void) __attribute__((noreturn));
-
-static void usage(void)
+static void __attribute__((noreturn)) usage(void)
 {
 	fprintf(stderr, "Usage: genl [ OPTIONS ] OBJECT | help }\n"
 	                "where  OBJECT := { ctrl etc }\n"
