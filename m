From: Ingo Molnar <mingo@elte.hu>
Subject: Re: KERNEL: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at net/netlink/af_netlink.c (126)
Date: Sun, 27 Mar 2005 15:38:11 +0200
Message-ID: <20050327133811.GA5569@elte.hu>
References: <20050327091524.GA23215@elte.hu> <E1DFUaZ-0001Hg-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1DFUaZ-0001Hg-00@gondolin.me.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > this was on a box that is DSL connected and thus gets lots of trash 
> > packets over the wire. It is running -RT ontop of 2.6.12-rc1, and got 
> > this message after 2 days of uptime.
> 
> This assertion can only be caused by netlink applications.  What 
> netlink applications do you use on this machine? Examples include 
> ip(8), the ULOG target of iptables, vrrpd, etc.

no vrrpd on this box. There's ipsec and wshaper on the box - both use 
netlink? No ULOG target AFAIK (it's a pretty much stock FC4 install).

	Ingo
