From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: pskb change in dst->output
Date: Fri, 9 Jul 2004 18:14:43 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040709081443.GA11101@gondor.apana.org.au>
References: <20040708011100.GA31600@gondor.apana.org.au> <Xine.LNX.4.44.0407072327390.29365-100000@thoron.boston.redhat.com> <20040708040235.GA32678@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040708040235.GA32678@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jul 08, 2004 at 02:02:35PM +1000, herbert wrote:
> 
> That's only because the dst->output() functions are calling
> skb_checksum_help().  Since those same functions assume the
> skb to be "uncloned" anyway (they modify it directly by adding
> headers etc.), they only need to call a version of
> skb_checksum_help() that does not do a copy of the skb.

If there are no objections, I'd like to create a version of
skb_checksum_help() that doesn't copy the packet, and call
that version from ah_output()/esp_output()/ipcomp_output().

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
