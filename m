From: Joe Perches <joe@perches.com>
Subject: [PATCH 02/11] dcbevent.h: Remove extern from function prototypes
Date: Fri, 20 Sep 2013 11:23:19 -0700
Message-ID: <346f461ada19cda69e1843c2c119f54f8def4cb1.1379701322.git.joe@perches.com>
References: <597c1b62607f823af60dc4a99d59373dddfb7837.1379701322.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <597c1b62607f823af60dc4a99d59373dddfb7837.1379701322.git.joe@perches.com>
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
 include/net/dcbevent.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/dcbevent.h b/include/net/dcbevent.h
index 443626e..d2f3041 100644
--- a/include/net/dcbevent.h
+++ b/include/net/dcbevent.h
@@ -25,9 +25,9 @@ enum dcbevent_notif_type {
 };
 
 #ifdef CONFIG_DCB
-extern int register_dcbevent_notifier(struct notifier_block *nb);
-extern int unregister_dcbevent_notifier(struct notifier_block *nb);
-extern int call_dcbevent_notifiers(unsigned long val, void *v);
+int register_dcbevent_notifier(struct notifier_block *nb);
+int unregister_dcbevent_notifier(struct notifier_block *nb);
+int call_dcbevent_notifiers(unsigned long val, void *v);
 #else
 static inline int
 register_dcbevent_notifier(struct notifier_block *nb)
-- 
1.8.1.2.459.gbcd45b4.dirty
