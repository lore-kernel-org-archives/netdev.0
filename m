From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][IPsec] fix process of error from crypto module
Date: Thu, 27 Jan 2005 16:20:58 +1100
Message-ID: <20050127052058.GB2060@gondor.apana.org.au>
References: <E1Cttr8-0005S6-00@gondolin.me.apana.org.au> <41F87368.7060909@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Kazunori Miyazawa <kazunori@miyazawa.org>
Content-Disposition: inline
In-Reply-To: <41F87368.7060909@miyazawa.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 27, 2005 at 01:51:52PM +0900, Kazunori Miyazawa wrote:
>
> BTW, esp6_destroy seem to be similar to esp_destroy.
> Should we export esp_destroy and IPv4 and IPv6 use it?
> Do we have any reason to define the functions separately?

esp_destroy is certainly not the only function that can be merged.

One of my dreams is to abstract out the family-dependent code
from ah/esp/ipcomp so that we can have a family-independent code
base.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
