From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: MultiPath Routing
Date: Fri, 06 May 2005 20:58:28 +1000
Message-ID: <E1DU0XM-0001wJ-00@gondolin.me.apana.org.au>
References: <427A70ED.3010305@rapidforum.com>
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: webmaster@rapidforum.com (Christian Schmid)
In-Reply-To: <427A70ED.3010305@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christian Schmid <webmaster@rapidforum.com> wrote:
> 
> Yes I enabled it. But it shouldnt do anything because its no forwarded traffic here. I just used 
> example-IPs. Or does the bug also break non-forwarded traffic?

Did you select one of the multipath algorithm options? If you selected
them as modules did you load them? If no algorithms are available it
will degenerate into deterministic routing.

It will also work properly if you disable IP_ROUTE_MULTIPATH_CACHED
completely.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
