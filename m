From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: old NLMSG_OK fix
Date: Mon, 28 Jun 2004 19:43:37 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1Besfp-0004hd-00@gondolin.me.apana.org.au>
References: <20040627205133.11d37f0c.davem@redhat.com>
Cc: hch@lst.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com (David S. Miller)
In-Reply-To: <20040627205133.11d37f0c.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@redhat.com> wrote:
> On Sun, 27 Jun 2004 19:15:52 +0200
> Christoph Hellwig <hch@lst.de> wrote:
> 
>> http://oss.sgi.com/projects/netdev/archive/2000-09/msg00001.html
> 
> It works because there is always 16 bytes of scratch at the end of an
> SKB more than was allocated for the actual data.  So blindly deref'ing
> the nlmsg_len value is fine here.

Yes but this is also used by user-space appliations where this scratch
space may not exist.  NETLINK messages can travel from one application
to another so exploits are possible.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
