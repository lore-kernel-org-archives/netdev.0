From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 3/3] [bonding 2.4] Backport PDE()
Date: Mon, 15 Sep 2003 12:00:42 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309151200.42616.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/include/linux/proc_fs.h b/include/linux/proc_fs.h
--- a/include/linux/proc_fs.h	2003-09-15 11:39:44.000000000 +0300
+++ b/include/linux/proc_fs.h	2003-09-15 11:39:45.000000000 +0300
@@ -209,4 +209,9 @@ extern struct proc_dir_entry proc_root;
 
 #endif /* CONFIG_PROC_FS */
 
+static inline struct proc_dir_entry *PDE(const struct inode *inode)
+{
+	return (struct proc_dir_entry *)inode->u.generic_ip;
+}
+
 #endif /* _LINUX_PROC_FS_H */
