From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: add missing sentinel for addrconf procfs
Date: Tue, 20 Jan 2004 09:42:23 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040120.094223.76534381.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Sorry, I forgot to increase the number of members in the array and 
that the sentinel was removed.
So, add missing sentinel explicitly.

===== net/ipv6/addrconf.c 1.85 vs edited =====
--- 1.85/net/ipv6/addrconf.c	Fri Jan 16 19:05:24 2004
+++ edited/net/ipv6/addrconf.c	Tue Jan 20 09:34:19 2004
@@ -3039,7 +3039,7 @@
 static struct addrconf_sysctl_table
 {
 	struct ctl_table_header *sysctl_header;
-	ctl_table addrconf_vars[16];
+	ctl_table addrconf_vars[17];
 	ctl_table addrconf_dev[2];
 	ctl_table addrconf_conf_dir[2];
 	ctl_table addrconf_proto_dir[2];
@@ -3180,6 +3180,9 @@
 			.mode		=	0644,
 			.proc_handler	=	&proc_dointvec,
 		},
+		{
+			.ctl_name	=	0,	/* sentinel */
+		}
 	},
 	.addrconf_dev = {
 		{



-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
