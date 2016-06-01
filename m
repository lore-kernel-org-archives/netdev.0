From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH 4/4] inotify: Don't include inotify.h when !CONFIG_INOTIFY_USER
Date: Wed,  1 Jun 2016 10:53:00 +0300
Message-ID: <1464767580-22732-5-git-send-email-kernel@kyup.com>
References: <1464767580-22732-1-git-send-email-kernel@kyup.com>
Cc: jack@suse.cz, linux-kernel@vger.kernel.org, gorcunov@openvz.org,
	avagin@openvz.org, netdev@vger.kernel.org,
	operations@siteground.com, Nikolay Borisov <kernel@kyup.com>
To: john@johnmccutchan.com, eparis@redhat.com, ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464767580-22732-1-git-send-email-kernel@kyup.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---
 fs/notify/fdinfo.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/notify/fdinfo.c b/fs/notify/fdinfo.c
index fd98e5100cab..62068f89d144 100644
--- a/fs/notify/fdinfo.c
+++ b/fs/notify/fdinfo.c
@@ -13,7 +13,10 @@
 #include <linux/proc_fs.h>
 #include <linux/exportfs.h>
 
+#ifdef CONFIG_INOTIFY_USER
 #include "inotify/inotify.h"
+#endif
+
 #include "../fs/mount.h"
 
 #if defined(CONFIG_PROC_FS)
-- 
2.5.0
