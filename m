From: Mike Christie <michaelc@cs.wisc.edu>
Subject: [PATCH 1/3] add open iscsi netlink interface to iscsi transport
	class
Date: Sun, 15 May 2005 12:29:57 -0700
Message-ID: <1116185397.17312.10.camel@mina>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-scsi-owner@vger.kernel.org>
To: open-iscsi@googlegroups.com, netdev@oss.sgi.com,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org,
	inux-iscsi-devel@lists.sourceforge.netl
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

include/linux/netlink.h changes (added new protocol NETLINK_ISCSI)

Thanks,

Linux-iscsi Team

Signed-off-by: Alex Aizman <itn780@yahoo.com>
Signed-off-by: Dmitry Yusupov <dmitry_yus@yahoo.com>
Signed-off-by: Mike Christie <michaelc@cs.wisc.edu>


--- linux-2.6.12-rc3.orig/include/linux/netlink.h	2005-04-20 17:03:16.000000000 -0700
+++ linux-2.6.12-rc3/include/linux/netlink.h	2005-05-04 18:06:44.000000000 -0700
@@ -14,6 +14,7 @@
 #define NETLINK_SELINUX		7	/* SELinux event notifications */
 #define NETLINK_ARPD		8
 #define NETLINK_AUDIT		9	/* auditing */
+#define NETLINK_ISCSI		10	/* iSCSI Open Interface */
 #define NETLINK_ROUTE6		11	/* af_inet6 route comm channel */
 #define NETLINK_IP6_FW		13
 #define NETLINK_DNRTMSG		14	/* DECnet routing messages */


