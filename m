From: Ingo Molnar <mingo@elte.hu>
Subject: Re: KERNEL: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at net/netlink/af_netlink.c (126)
Date: Tue, 29 Mar 2005 13:49:26 +0200
Message-ID: <20050329114926.GA14986@elte.hu>
References: <20050327091524.GA23215@elte.hu> <E1DFUaZ-0001Hg-00@gondolin.me.apana.org.au> <20050327133811.GA5569@elte.hu> <20050329104906.GA19836@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050329104906.GA19836@gondor.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sun, Mar 27, 2005 at 03:38:11PM +0200, Ingo Molnar wrote:
> > 
> > no vrrpd on this box. There's ipsec and wshaper on the box - both use 
> 
> ipsec: Depends on whether you're using ipsec-tools or *swan.
> 
> The former doesn't use netlink while the latter does.

it's openswan/pluto.

> wshaper: Yes when it's setting things up.

so it could be both - the ipsec startup/restart script that is used on 
the box uses wshaper too.

> > netlink? No ULOG target AFAIK (it's a pretty much stock FC4 install).
> 
> cat /proc/net/netlink
> 
> should tell you what's using it all the time.

pluto (ipsec/openswan), dbus-daemon, hald.

(i guess the debug message should be extended to do a dump_stack() so 
that we see which process does?)

	Ingo
