From: Jan Oravec <jan.oravec@6com.sk>
Subject: Re: problem setting net.ipvX.conf.all.forwarding via sysctl() system call
Date: Fri, 8 Aug 2003 11:11:24 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030808091124.GA17961@wsx.ksp.sk>
References: <20030803154427.GA12926@wsx.ksp.sk> <20030808.174504.14391608.yoshfuji@linux-ipv6.org>
Reply-To: Jan Oravec <jan.oravec@6com.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20030808.174504.14391608.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,


this is a new patch

> It seems correct, however, this patch cannot apply against 
> current tree.  Pleaes resend the patch.
> And please make sure to diff like this:
> diff -u linux-2.6/net/ipv4/sysctl_net_ipv4.c.old linux-2.6/net/ipv4/sysctl_net_ipv4.c

diff -u linux-2.6.0-test2/net/ipv4/sysctl_net_ipv4.c.old linux-2.6.0-test2/net/ipv4/sysctl_net_ipv4.c
--- linux-2.6.0-test2/net/ipv4/sysctl_net_ipv4.c.old	2003-07-27 19:06:19.000000000 +0200
+++ linux-2.6.0-test2/net/ipv4/sysctl_net_ipv4.c	2003-08-08 10:56:31.000000000 +0200
@@ -109,8 +109,9 @@
 		}
 	}
 
+	ipv4_devconf.forwarding = new;
 	inet_forward_change();
-	return 1;
+	return 0;
 }
 
 ctl_table ipv4_table[] = {


Thanks,

-- 
Jan Oravec                           XS26 coordinator
6COM s.r.o.                          'Access to IPv6'
http://www.6com.sk                   http://www.xs26.net
