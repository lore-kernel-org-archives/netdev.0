From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [ESP] Only one algorithm is required
Date: Sun, 15 Aug 2004 05:24:12 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814192412.GA24399@gondor.apana.org.au>
References: <20040814105245.GA20646@gondor.apana.org.au> <Xine.LNX.4.44.0408141012510.26617-100000@dhcp83-76.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0408141012510.26617-100000@dhcp83-76.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Aug 14, 2004 at 10:16:17AM -0400, James Morris wrote:
> On Sat, 14 Aug 2004, Herbert Xu wrote:
> 
> > Both encryption and authentication are optional for ESP.  However, at
> > least one of them must be present.  The following patch changes init_state
> > to match that specification.
> 
> This is userland level policy and I don't think the kernel should be
> enforcing this.

We should remove the ealg check altogether then?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
