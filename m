From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] IPV6: add missing sentinel for addrconf procfs
Date: Tue, 20 Jan 2004 10:48:20 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040120104820.77ff135f.shemminger@osdl.org>
References: <20040120.094223.76534381.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: davem@redhat.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?ISO-8859-1?B?X19fX19fX19fX19f?=
 <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040120.094223.76534381.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 20 Jan 2004 09:42:23 +0900 (JST)
YOSHIFUJI Hideaki / ____________ <yoshfuji@linux-ipv6.org> wrote:

> Sorry, I forgot to increase the number of members in the array and 
> that the sentinel was removed.
> So, add missing sentinel explicitly.

How about adding all them explicitly to prevent future errors?

diff -Nru a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
--- a/net/ipv6/addrconf.c	Tue Jan 20 10:51:20 2004
+++ b/net/ipv6/addrconf.c	Tue Jan 20 10:51:20 2004
@@ -3191,6 +3191,9 @@
 			.mode		=	0555,
 			.child		=	addrconf_sysctl.addrconf_vars,
 		},
+		{
+			.ctl_name	=	0,	/* sentinel */
+		}
 	},
 	.addrconf_conf_dir = {
 		{
@@ -3199,6 +3202,9 @@
 			.mode		=	0555,
 			.child		=	addrconf_sysctl.addrconf_dev,
 		},
+		{
+			.ctl_name	=	0,	/* sentinel */
+		}
 	},
 	.addrconf_proto_dir = {
 		{
@@ -3207,6 +3213,9 @@
 			.mode		=	0555,
 			.child		=	addrconf_sysctl.addrconf_conf_dir,
 		},
+		{
+			.ctl_name	=	0,	/* sentinel */
+		}
 	},
 	.addrconf_root_dir = {
 		{
@@ -3215,6 +3224,9 @@
 			.mode		=	0555,
 			.child		=	addrconf_sysctl.addrconf_proto_dir,
 		},
+		{
+			.ctl_name	=	0,	/* sentinel */
+		}
 	},
 };
 
