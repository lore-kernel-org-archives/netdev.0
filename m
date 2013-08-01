From: Joe Perches <joe@perches.com>
Subject: [PATCH 8/8] cls_cgroup.h netprio_cgroup.h: Remove extern from function prototypes
Date: Wed, 31 Jul 2013 17:31:39 -0700
Message-ID: <2d25335e101a20b760b0cd422b24d91aef60c720.1375316912.git.joe@perches.com>
References: <cover.1375316912.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1375316912.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/cls_cgroup.h     | 2 +-
 include/net/netprio_cgroup.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/cls_cgroup.h b/include/net/cls_cgroup.h
index 0fee061..f55c145 100644
--- a/include/net/cls_cgroup.h
+++ b/include/net/cls_cgroup.h
@@ -24,7 +24,7 @@ struct cgroup_cls_state
 	u32 classid;
 };
 
-extern void sock_update_classid(struct sock *sk);
+void sock_update_classid(struct sock *sk);
 
 #if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
 static inline u32 task_cls_classid(struct task_struct *p)
diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index 50ab8c2..379dd5d 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -29,7 +29,7 @@ struct cgroup_netprio_state {
 	struct cgroup_subsys_state css;
 };
 
-extern void sock_update_netprioidx(struct sock *sk);
+void sock_update_netprioidx(struct sock *sk);
 
 #if IS_BUILTIN(CONFIG_NETPRIO_CGROUP)
 
-- 
1.8.1.2.459.gbcd45b4.dirty
