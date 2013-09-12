From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/7] sysfs: drop semicolon from to_sysfs_dirent() definition
Date: Wed, 11 Sep 2013 22:29:03 -0400
Message-ID: <1378952949-7900-2-git-send-email-tj@kernel.org>
References: <1378952949-7900-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, kay@vrfy.org, ebiederm@xmission.com,
	netdev@vger.kernel.org, lizefan@huawei.com,
	Tejun Heo <tj@kernel.org>
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378952949-7900-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The expansion of to_sysfs_dirent() contains an unncessary trailing
semicolon making it impossible to use in the middle of statements.
Drop it.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 fs/sysfs/dir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 4d83ced..834c64c 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -28,7 +28,7 @@
 DEFINE_MUTEX(sysfs_mutex);
 DEFINE_SPINLOCK(sysfs_assoc_lock);
 
-#define to_sysfs_dirent(X) rb_entry((X), struct sysfs_dirent, s_rb);
+#define to_sysfs_dirent(X) rb_entry((X), struct sysfs_dirent, s_rb)
 
 static DEFINE_SPINLOCK(sysfs_ino_lock);
 static DEFINE_IDA(sysfs_ino_ida);
-- 
1.8.3.1
