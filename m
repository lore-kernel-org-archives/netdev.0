From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 4180] New: masquarade and source ip
Date: Tue, 08 Feb 2005 21:34:37 +1100
Message-ID: <E1CyShZ-0003AO-00@gondolin.me.apana.org.au>
References: <42088259.000022.13502@pantene.yandex.ru>
Cc: kaber@trash.net, netdev@oss.sgi.com
To: spied@yandex.ru
In-Reply-To: <42088259.000022.13502@pantene.yandex.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

spied <spied@yandex.ru> wrote:
>>The masquerading code got simplified and uses inet_select_addr() instead
>>of querying routing for the source address now.
> 
> why?

Because the previous approach of looking up the route again was
prone to failure with multi-path routing.  More importantly it
doesn't always return the correct route (that is the route the
packet received before it entered POSTROUTING).
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
