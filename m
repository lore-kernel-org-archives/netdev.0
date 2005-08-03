From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6.12.2] XFRM: BEET IPsec mode for Linux
Date: Thu, 4 Aug 2005 09:40:52 +1000
Message-ID: <20050803234052.GA13216@gondor.apana.org.au>
References: <1122984099.1214.142.camel@odysse>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, infrahip@HIIT.FI, hipl-users@freelists.org,
        hipsec@ietf.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Diego Beltrami <diego.beltrami@HIIT.FI>
Content-Disposition: inline
In-Reply-To: <1122984099.1214.142.camel@odysse>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Aug 02, 2005 at 03:01:39PM +0300, Diego Beltrami wrote:
> 
> after sending the first version of BEET patch and having received a
> valuable feedback and after the discussion based upon the BEET design,
> we now send the new BEET patch which allows for BEET to work without the
> inter-family transform (i.e. inner address family different than outer
> address family).

Thanks for the new patch.  Unfortunately it really looks quite similar
to the previous patch :)

> --- linux-2.6.12.2-orig/net/ipv4/esp4.c
> +++ linux-2.6.12.2/net/ipv4/esp4.c

I thought getting rid of the interfamily stuff would remove the
need to touch this file, no?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
