From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH RFC 3/31] net: Add a network namespace parameter to tasks
Date: Thu, 25 Jan 2007 12:00:05 -0700
Message-ID: <11697516333073-git-send-email-ebiederm@xmission.com>
References: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
Cc: <containers@lists.osdl.org>, <openib-general@openib.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35756 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965576AbXAYTBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 14:01:00 -0500
In-Reply-To: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric W. Biederman <ebiederm@xmission.com> - unquoted

This is the network namespace from which all which all sockets
and anything else under user control ultimately get their network
namespace parameters.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/nsproxy.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/nsproxy.h b/include/linux/nsproxy.h
index 0b9f0dc..cc76610 100644
--- a/include/linux/nsproxy.h
+++ b/include/linux/nsproxy.h
@@ -3,6 +3,7 @@
 
 #include <linux/spinlock.h>
 #include <linux/sched.h>
+#include <linux/net_namespace_type.h>
 
 struct mnt_namespace;
 struct uts_namespace;
@@ -28,6 +29,7 @@ struct nsproxy {
 	struct ipc_namespace *ipc_ns;
 	struct mnt_namespace *mnt_ns;
 	struct pid_namespace *pid_ns;
+	net_t		      net_ns;
 };
 extern struct nsproxy init_nsproxy;
 
-- 
1.4.4.1.g278f

