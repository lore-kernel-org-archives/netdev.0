From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: KERNEL: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at net/netlink/af_netlink.c (126)
Date: Tue, 29 Mar 2005 20:49:06 +1000
Message-ID: <20050329104906.GA19836@gondor.apana.org.au>
References: <20050327091524.GA23215@elte.hu> <E1DFUaZ-0001Hg-00@gondolin.me.apana.org.au> <20050327133811.GA5569@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Content-Disposition: inline
In-Reply-To: <20050327133811.GA5569@elte.hu>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 27, 2005 at 03:38:11PM +0200, Ingo Molnar wrote:
> 
> no vrrpd on this box. There's ipsec and wshaper on the box - both use 

ipsec: Depends on whether you're using ipsec-tools or *swan.

The former doesn't use netlink while the latter does.

wshaper: Yes when it's setting things up.

> netlink? No ULOG target AFAIK (it's a pretty much stock FC4 install).

cat /proc/net/netlink

should tell you what's using it all the time.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
