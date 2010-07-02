From: kaber@trash.net
Subject: [PATCH 3/9] netfilter: xt_IDLETIMER needs kdev_t.h
Date: Fri,  2 Jul 2010 11:52:16 +0200
Message-ID: <1278064342-19059-4-git-send-email-kaber@trash.net>
References: <1278064342-19059-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1278064342-19059-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Add header file to fix build error:
net/netfilter/xt_IDLETIMER.c:276: error: implicit declaration of function 'MKDEV'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_IDLETIMER.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/xt_IDLETIMER.c b/net/netfilter/xt_IDLETIMER.c
index e11090a..be1f22e 100644
--- a/net/netfilter/xt_IDLETIMER.c
+++ b/net/netfilter/xt_IDLETIMER.c
@@ -36,6 +36,7 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_IDLETIMER.h>
+#include <linux/kdev_t.h>
 #include <linux/kobject.h>
 #include <linux/workqueue.h>
 #include <linux/sysfs.h>
-- 
1.7.0.4

