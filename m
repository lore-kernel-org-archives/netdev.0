From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [AH6] Rearrange routing headers
Date: Sun, 25 Jul 2004 05:31:58 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040724193158.GA15897@gondor.apana.org.au>
References: <20040724083709.GA9416@gondor.apana.org.au> <200407250222.22934.kazunori@miyazawa.org> <20040724.142203.15175626.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kazunori@miyazawa.org, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040724.142203.15175626.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jul 24, 2004 at 02:22:03PM -0400, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
>
> > I saw roughly the packet.
> > It needs to check direction of the process.
> > We don't need to do that in INBOUND.
> 
> Here's the patch (on top of the Xu's patch).

This is unnecessary because if we're calling this from ah6_input(), then
rthdr->segments_left must be zero.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
