From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: KERNEL: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at net/netlink/af_netlink.c (126)
Date: Sun, 27 Mar 2005 20:01:47 +1000
Message-ID: <E1DFUaZ-0001Hg-00@gondolin.me.apana.org.au>
References: <20050327091524.GA23215@elte.hu>
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
To: mingo@elte.hu (Ingo Molnar)
In-Reply-To: <20050327091524.GA23215@elte.hu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar <mingo@elte.hu> wrote:
> 
> i got one such message:
> 
> KERNEL: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at
> net/netlink/af_netlink.c (126)

Interesting.  I've seen one report about this assertion before yours.
Unfortunately there was very little to go on there apart from the
fact that vrrpd was involved.

> this was on a box that is DSL connected and thus gets lots of trash 
> packets over the wire. It is running -RT ontop of 2.6.12-rc1, and got 
> this message after 2 days of uptime.

This assertion can only be caused by netlink applications.  What
netlink applications do you use on this machine? Examples include
ip(8), the ULOG target of iptables, vrrpd, etc.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
