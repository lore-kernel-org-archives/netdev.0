From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: Re: [PATCH]Fix adding SA through netlink(xfrm_user)
Date: Thu, 29 Jul 2004 07:31:24 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040728213124.GA11280@gondor.apana.org.au>
References: <20040728091224.4d577c47.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Masahide Nakamura <nakam@linux-ipv6.org>,
        James Morris <jmorris@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040728091224.4d577c47.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 28, 2004 at 09:12:24AM -0700, David S. Miller wrote:
> 
> Indeed, this is mysterious.  How come you never hit this, doesn't
> superfreeswan use netlink XFRM purely these days?

That's because it isn't purely netlink.  It still relies on af_key to
get the list of algorithms.

BTW Superfreeswan is now known as Opeswan.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
