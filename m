From: Silviu-Mihai Popescu <silviupopescu1990-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] bluetooth: use PTR_RET instead of IS_ERR + PTR_ERR
Date: Tue, 12 Mar 2013 20:13:15 +0200
Message-ID: <1363111995-26866-1-git-send-email-silviupopescu1990@gmail.com>
Cc: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org, johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Silviu-Mihai Popescu <silviupopescu1990-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This uses PTR_RET instead of IS_ERR and PTR_ERR in order to increase
readability.

Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/bluetooth/hci_sysfs.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/bluetooth/hci_sysfs.c b/net/bluetooth/hci_sysfs.c
index 23b4e24..6fb5065 100644
--- a/net/bluetooth/hci_sysfs.c
+++ b/net/bluetooth/hci_sysfs.c
@@ -590,10 +590,7 @@ int __init bt_sysfs_init(void)
 	bt_debugfs = debugfs_create_dir("bluetooth", NULL);
 
 	bt_class = class_create(THIS_MODULE, "bluetooth");
-	if (IS_ERR(bt_class))
-		return PTR_ERR(bt_class);
-
-	return 0;
+	return PTR_RET(bt_class)
 }
 
 void bt_sysfs_cleanup(void)
-- 
1.7.9.5
