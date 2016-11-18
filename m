From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH] netns: fix get_net_ns_by_fd(int pid) typo
Date: Fri, 18 Nov 2016 09:41:46 +0000
Message-ID: <1479462106-28529-1-git-send-email-stefanha@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37590 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751802AbcKRJlt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Nov 2016 04:41:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The argument to get_net_ns_by_fd() is a /proc/$PID/ns/net file
descriptor not a pid.  Fix the typo.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 include/net/net_namespace.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index fc4f757..0940598 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -170,7 +170,7 @@ static inline struct net *copy_net_ns(unsigned long flags,
 extern struct list_head net_namespace_list;
 
 struct net *get_net_ns_by_pid(pid_t pid);
-struct net *get_net_ns_by_fd(int pid);
+struct net *get_net_ns_by_fd(int fd);
 
 #ifdef CONFIG_SYSCTL
 void ipx_register_sysctl(void);
-- 
2.7.4
