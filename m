From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 3/3] wanrouter: Remove kernel_lock annotations
Date: Mon,  7 Nov 2011 09:24:21 +0100
Message-ID: <1320654261-4473-1-git-send-email-richard@nod.at>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Richard Weinberger <richard@nod.at>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The BKL is gone, these annotations are useless.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 net/wanrouter/wanproc.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/wanrouter/wanproc.c b/net/wanrouter/wanproc.c
index f346395..c43612e 100644
--- a/net/wanrouter/wanproc.c
+++ b/net/wanrouter/wanproc.c
@@ -81,7 +81,6 @@ static struct proc_dir_entry *proc_router;
  *	Iterator
  */
 static void *r_start(struct seq_file *m, loff_t *pos)
-	__acquires(kernel_lock)
 {
 	struct wan_device *wandev;
 	loff_t l = *pos;
@@ -103,7 +102,6 @@ static void *r_next(struct seq_file *m, void *v, loff_t *pos)
 }
 
 static void r_stop(struct seq_file *m, void *v)
-	__releases(kernel_lock)
 {
 	mutex_unlock(&config_mutex);
 }
-- 
1.7.7
