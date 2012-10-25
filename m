From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v1 2/5] cgroup: net_cls: Fix local variable type decleration
Date: Thu, 25 Oct 2012 16:16:56 +0200
Message-ID: <1351174619-5096-3-git-send-email-wagi@monom.org>
References: <1351174619-5096-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:52633 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759683Ab2JYORF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 10:17:05 -0400
In-Reply-To: <1351174619-5096-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

The classid type used throughout the kernel is u32.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: <netdev@vger.kernel.org>
Cc: <cgroups@vger.kernel.org>
---
 include/net/cls_cgroup.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index b6a6eeb..0fee061 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -29,7 +29,7 @@ extern void sock_update_classid(struct sock *sk);
 #if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
 static inline u32 task_cls_classid(struct task_struct *p)
 {
-	int classid;
+	u32 classid;
 
 	if (in_interrupt())
 		return 0;
-- 
1.8.0.rc0
