From: Andrew Morton <akpm@osdl.org>
Subject: Re: experimental net driver queue updated
Date: Sun, 11 Jan 2004 00:45:40 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040111004540.403ca854.akpm@osdl.org>
References: <4000C5A3.5070101@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4000C5A3.5070101@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> wrote:
>
> Patch:
>  http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/2.6.1-bk1-netdev2.patch.bz2

net/core/netpoll.c: In function `netpoll_setup':
net/core/netpoll.c:572: warning: too many arguments for format
net/core/netpoll.c:572: warning: too many arguments for format

--- 25/net/core/netpoll.c~netpoll-warning-fix	2004-01-11 00:43:24.000000000 -0800
+++ 25-akpm/net/core/netpoll.c	2004-01-11 00:43:50.000000000 -0800
@@ -569,7 +569,7 @@ int netpoll_setup(struct netpoll *np)
 		if (time_before(jiffies, atleast)) {
 			printk(KERN_NOTICE "%s: carrier detect appears flaky,"
 			       " waiting 10 seconds\n",
-			       np->name, np->dev_name);
+			       np->name);
 			while (time_before(jiffies, atmost))
 				cond_resched();
 		}

_
