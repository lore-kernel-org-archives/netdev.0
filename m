From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: MultiPath Routing
Date: Thu, 05 May 2005 22:36:58 +1000
Message-ID: <E1DTfb8-0005lI-00@gondolin.me.apana.org.au>
References: <427A0EAF.2050402@rapidforum.com>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: webmaster@rapidforum.com (Christian Schmid)
In-Reply-To: <427A0EAF.2050402@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christian Schmid <webmaster@rapidforum.com> wrote:
> 
> Since this seems to be an undocumented feature.... How is this equal-cost multipath supposed to 
> work? I just want to send outgoing traffic over two gateways. I tried this:
> 
> ip route replace default scope global nexthop via 192.168.0.1 dev eth1 weight 100 nexthop via 
> 192.168.0.100 dev eth1 weight 100
> 
> It it doesnt work. It always uses the last for all download-users (around a few hundreds)

Did you enable IP_ROUTE_MULTIPATH_CACHED? If so please disable it
since it breaks multipath routing for forwarded traffic.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
