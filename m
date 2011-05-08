From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 028/115] sysctl: remove .child from kernel/ (ipc)
Date: Mon,  9 May 2011 00:38:40 +0200
Message-ID: <1304894407-32201-29-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 ipc/ipc_sysctl.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/ipc/ipc_sysctl.c b/ipc/ipc_sysctl.c
index 56410fa..9e408a6 100644
--- a/ipc/ipc_sysctl.c
+++ b/ipc/ipc_sysctl.c
@@ -194,18 +194,14 @@ static struct ctl_table ipc_kern_table[] = {
 	{}
 };
 
-static struct ctl_table ipc_root_table[] = {
-	{
-		.procname	= "kernel",
-		.mode		= 0555,
-		.child		= ipc_kern_table,
-	},
-	{}
+static const __initdata struct ctl_path ipc_path[] = {
+	{ .procname = "kernel" },
+	{ }
 };
 
 static int __init ipc_sysctl_init(void)
 {
-	register_sysctl_table(ipc_root_table);
+	register_sysctl_paths(ipc_path, ipc_kern_table);
 	return 0;
 }
 
-- 
1.7.5.134.g1c08b
