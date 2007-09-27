From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] netns: CLONE_NEWNET don't use the same clone flag as the pid namespace.
Date: Thu, 27 Sep 2007 16:40:31 -0600
Message-ID: <m1hclfhgv4.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:42140 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757326AbXI0Wkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 18:40:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/sched.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index e10a0a8..d82c1f7 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -27,7 +27,7 @@
 #define CLONE_NEWUTS		0x04000000	/* New utsname group? */
 #define CLONE_NEWIPC		0x08000000	/* New ipcs */
 #define CLONE_NEWUSER		0x10000000	/* New user namespace */
-#define CLONE_NEWNET		0x20000000	/* New network namespace */
+#define CLONE_NEWNET		0x40000000	/* New network namespace */
 
 /*
  * Scheduling policies
-- 
1.5.3.rc6.17.g1911

