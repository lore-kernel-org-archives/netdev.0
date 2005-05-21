From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [BUG 2.6.12-rc4] IPv6 xfrm tunnel oops with large packets
Date: Sun, 22 May 2005 05:18:17 +0900 (JST)
Message-ID: <20050522.051817.122678688.yoshfuji@linux-ipv6.org>
References: <1116702611.14509.10.camel@leto.cs.pocnet.net>
	<20050521194932.GA10959@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christophe@saout.de, linux-net@vger.kernel.org, netdev@oss.sgi.com,
	davem@davemloft.net
Return-path: <linux-net-owner@vger.kernel.org>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050521194932.GA10959@gondor.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20050521194932.GA10959@gondor.apana.org.au> (at Sun, 22 May 2005 05:49:32 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> On Sat, May 21, 2005 at 07:10:11PM +0000, Christophe Saout wrote:
> > 
> > The oops occurs in line 391 in net/ipv6/icmp.c:
> > 
> > >        idev = in6_dev_get(skb->dev);
> 
> Here is a minimal fix.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>


Acked-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

> BTW, icmpv6_send seems to ignore its dev argument altogether.
> Any reason why we can't just use it instead of skb->dev?

(After looking into icmpv6_send() usages,)
I don't know the reason why we needed the last argument "dev".
It seems that we already had it at the time of 2.2.16.
Probably, we can remove it.

--yoshfuji
