From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec and Path MTU
Date: Fri, 18 Jun 2004 09:18:51 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617231851.GA14861@gondor.apana.org.au>
References: <20040615124334.GA25164@gondor.apana.org.au> <20040616195653.GC29781@ms2.inr.ac.ru> <20040616231317.GA5742@gondor.apana.org.au> <20040617190158.GA10925@ms2.inr.ac.ru> <20040617213832.GC14089@gondor.apana.org.au> <20040617152921.730892c7.davem@redhat.com> <20040617231241.GB14739@gondor.apana.org.au> <20040617161403.2d0ee598.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040617161403.2d0ee598.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 17, 2004 at 04:14:03PM -0700, David S. Miller wrote:
> On Fri, 18 Jun 2004 09:12:41 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > In my case, the ICMP message is not coming from the remote IPsec gateway
> > or a router in front of it.  It's coming from a host behind it.  So
> > the original IP header is in the ICMP message, in the clear.
> 
> Remote gateway is supposed to encapsulate the ICMP message and send it
> back to the other gateway isn't it?

We are the other gateway :) Yes, I'm talking about what happens to
that ICMP message once we decapsulate it.
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
