From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: pskb change in dst->output
Date: Thu, 8 Jul 2004 09:12:21 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040707231221.GA30565@gondor.apana.org.au>
References: <20040707130652.GA26822@gondor.apana.org.au> <Xine.LNX.4.44.0407071013080.26759-100000@thoron.boston.redhat.com> <20040707212805.GA29899@gondor.apana.org.au> <20040707150132.5dc470b6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040707150132.5dc470b6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 07, 2004 at 03:01:32PM -0700, David S. Miller wrote:
> On Thu, 8 Jul 2004 07:28:05 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > OK.  Can you please tell me which caller of dst_output() passes
> > a cloned skb to it?
> 
> The case James's patch tries to deal with is when multicast
> loops back packets to localhost, see ip_mc_output().
> Since the SKB is a clone, if we do anything with the checksum
> state of the clone, this messes up the hw checksumming state
> of the original SKB and we get output packets with corrupt
> checksums.

Thanks.  I have no problems with that.  But ip_mc_output() as far
as I can see does not call dst_output.

So is there a caller to dst_output that does this as well?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
