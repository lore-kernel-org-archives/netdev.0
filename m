From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Set truesize in pskb_expand_head
Date: Sat, 25 Sep 2004 09:35:55 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924233555.GA7962@gondor.apana.org.au>
References: <20040924232053.GA7807@gondor.apana.org.au> <20040924163328.7597352c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040924163328.7597352c.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Sep 24, 2004 at 04:33:28PM -0700, David S. Miller wrote:
> On Sat, 25 Sep 2004 09:20:53 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > In order for the skb trimming to work, we need to set truesize in
> > pskb_expand_head.  This patch does exactly that.
> 
> I tried to warn people about this earlier in the netlink
> NLMSG_GOODSIZE thread.... ho hum.
> 
> This change mucks up socket buffer accounting.
> 
> If you change skb->truesize, then when the kfree_skb(skb)
> happens a different skb->truesize will be subtracted from
> the socket buffer allocation than what was used when the
> skb was first charged to the socket.

Dave, it hasn't been charged yet...
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
