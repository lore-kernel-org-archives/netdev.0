From: "David S. Miller" <davem@redhat.com>
Subject: Re: Fw: Oops in register_proc_table (2.6.1-mm4)
Date: Mon, 19 Jan 2004 21:18:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119211800.582e4c3a.davem@redhat.com>
References: <20040116104709.2163912c.akpm@osdl.org>
	<20040117173202.76119237.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, thomas.schlichter@web.de
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040117173202.76119237.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 17 Jan 2004 17:32:02 -0800
Andrew Morton <akpm@osdl.org> wrote:

> It seems that ipv6 is registering something under /proc/net/ipv6/route
> which has a bad ctl_table.procname.  I don't know what it is - the ipv6
> sysctl code overpowered my attention span.

I believe the patches posted by Krishna and Yoshfuji today should
cure this.  I've integrated those into my tree and will push to
Linus in a bit.
