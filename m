From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NAT-T] NON-IKE encapsulation
Date: Fri, 25 Jun 2004 07:41:37 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040624214137.GA4620@gondor.apana.org.au>
References: <20040624123603.GA1241@gondor.apana.org.au> <20040624124654.36b31815.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: agruen@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040624124654.36b31815.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 24, 2004 at 12:46:54PM -0700, David S. Miller wrote:
> 
> > I'm having trouble understanding why we need to increase alen by
> > two bytes for NON-IKE.  As far as I can see it's adding two bytes
> > of random data to the end of the packet.  Is there something
> > obvious that I'm missing?
> 
> It is intentional as far as I remember.  If it's any other length,
> then the other side implementing this non-IKE encap stuff won't
> accept the packet, it must be that length.

Which impelementation does that? The implementation in FreeS/WAN
certainly doesn't and it has talked to many commercial NAT-T
software using NON-IKE.

There is also nothing like this in the draft for NON-IKE.

Even if we do need this, we should fill those two bytes with some
data.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
