From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [BUG 2.6.12-rc4] IPv6 xfrm tunnel oops with large packets
Date: Mon, 23 May 2005 13:11:39 -0700 (PDT)
Message-ID: <20050523.131139.51421880.davem@davemloft.net>
References: <1116702611.14509.10.camel@leto.cs.pocnet.net>
	<20050521194932.GA10959@gondor.apana.org.au>
	<20050522.051817.122678688.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, christophe@saout.de,
        linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050522.051817.122678688.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Sun, 22 May 2005 05:18:17 +0900 (JST)

> In article <20050521194932.GA10959@gondor.apana.org.au> (at Sun, 22 May 2005 05:49:32 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:
> 
> > On Sat, May 21, 2005 at 07:10:11PM +0000, Christophe Saout wrote:
> > > 
> > > The oops occurs in line 391 in net/ipv6/icmp.c:
> > > 
> > > >        idev = in6_dev_get(skb->dev);
> > 
> > Here is a minimal fix.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> 
> Acked-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

Applied, thanks everyone.
