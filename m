From: Mike Christie <michaelc@cs.wisc.edu>
Subject: [PATCH 1/3] add open iscsi netlink interface to iscsi transport class
Date: Wed, 04 May 2005 19:53:26 -0700
Message-ID: <42798AA6.4090109@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000905020208010703030007"
Return-path: <linux-scsi-owner@vger.kernel.org>
To: netdev <netdev@oss.sgi.com>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	netdev <netdev@oss.sgi.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000905020208010703030007
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

attached add-iscsi-netlink-def.patch - include/linux/netlink.h changes 
(added new protocol NETLINK_ISCSI)

Thanks,

Linux-iscsi Team

Signed-off-by: Alex Aizman <itn780@yahoo.com>
Signed-off-by: Dmitry Yusupov <dmitry_yus@yahoo.com>
Signed-off-by: Mike Christie <michaelc@cs.wisc.edu>

--------------000905020208010703030007
Content-Type: text/x-patch;
 name="add-iscsi-netlink-def.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="add-iscsi-netlink-def.patch"

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

--------------000905020208010703030007--
