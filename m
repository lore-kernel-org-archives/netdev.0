From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: pskb change in dst->output
Date: Thu, 8 Jul 2004 07:28:05 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707212805.GA29899@gondor.apana.org.au>
References: <20040707130652.GA26822@gondor.apana.org.au> <Xine.LNX.4.44.0407071013080.26759-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0407071013080.26759-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 07, 2004 at 10:58:21AM -0400, James Morris wrote:
> 
> >  All of the dst->output functions already assumed that they have
> > exclusive access to the skb. This is justified because all callers to
> > dst_output() makes sure that the packet is neither shared nor cloned.
> 
> Cloned skbs are regularly passed to dst_output(), thus we need to use the 
> double pointer for skb_checksum_help() in case the skb is replaced.

OK.  Can you please tell me which caller of dst_output() passes
a cloned skb to it?

I need to know this because if this is the case, we need fix the various
IPsec output functions to copy the skb.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
