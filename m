From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH]: fix no_cong_thresh sysctl
Date: Tue, 22 Jul 2003 17:35:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F1D59B4.3080307@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090200040508000909040906"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090200040508000909040906
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,
these two patches fix the net.core.no_cong_thresh sysctl, the value
accessed is in fact no_cong.

Best regards,
Patrick

--------------090200040508000909040906
Content-Type: text/plain;
 name="linux-2.4.21-sysctl_net_core-no_cong_thresh.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.21-sysctl_net_core-no_cong_thresh.diff"

===== net/core/sysctl_net_core.c 1.4 vs edited =====
--- 1.4/net/core/sysctl_net_core.c	Wed Aug  7 18:17:09 2002
+++ edited/net/core/sysctl_net_core.c	Tue Jul 22 16:50:29 2003
@@ -55,7 +55,7 @@
 	 &netdev_max_backlog, sizeof(int), 0644, NULL,
 	 &proc_dointvec},
 	{NET_CORE_NO_CONG_THRESH, "no_cong_thresh",
-	 &no_cong, sizeof(int), 0644, NULL,
+	 &no_cong_thresh, sizeof(int), 0644, NULL,
 	 &proc_dointvec},
 	{NET_CORE_NO_CONG, "no_cong",
 	 &no_cong, sizeof(int), 0644, NULL,

--------------090200040508000909040906
Content-Type: text/plain;
 name="linux-2.5.75-sysctl_net_core-no_cong_thresh.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.5.75-sysctl_net_core-no_cong_thresh.diff"

===== net/core/sysctl_net_core.c 1.4 vs edited =====
--- 1.4/net/core/sysctl_net_core.c	Wed Apr 30 08:44:14 2003
+++ edited/net/core/sysctl_net_core.c	Tue Jul 22 16:51:35 2003
@@ -86,7 +86,7 @@
 	{
 		.ctl_name	= NET_CORE_NO_CONG_THRESH,
 		.procname	= "no_cong_thresh",
-		.data		= &no_cong,
+		.data		= &no_cong_thresh,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &proc_dointvec

--------------090200040508000909040906--
