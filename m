From: Krishna Kumar <krkumar@us.ibm.com>
Subject: [PATCH] Oops in register_proc_table (2.6.1-mm4)
Date: Mon, 19 Jan 2004 16:06:22 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401191603410.21234-100000@linux-udp15191261uds.beaverton.ibm.com>
References: <200401200051.07144.thomas.schlichter@web.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@osdl.org, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, Thomas Schlichter <thomas.schlichter@web.de>
In-Reply-To: <200401200051.07144.thomas.schlichter@web.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

Please apply the patch below.

Thanks,

- KK

diff -ruN linux-2.6.0-rc2-bk6/net/ipv6/route.c linux-2.6.0-rc2-bk6.new/net/ipv6/route.c
--- linux-2.6.0-rc2-bk6/net/ipv6/route.c	2004-01-19 11:41:14.000000000 -0800
+++ linux-2.6.0-rc2-bk6.new/net/ipv6/route.c	2004-01-19 11:42:33.000000000 -0800
@@ -1974,6 +1974,7 @@
          	.proc_handler	=	&proc_dointvec_jiffies,
 		.strategy	=	&sysctl_jiffies,
 	},
+	{ .ctl_name = 0 }
 };

 #endif

On Tue, 20 Jan 2004, Thomas Schlichter wrote:

> Hi,
>
> Am Montag, 19. Januar 2004 20:49 schrieb Krishna Kumar:
> > Hi,
> >
> > Can you test with following patch ?
>
> Yes, and it cures the Oops here!
>
> > thanks,
>
> Thank you, too!
>
> > - KK
>
>   Thomas Schlichter
