From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPROUTE]: Add support for multipath route realms
Date: Tue, 25 Jul 2006 18:21:44 +1000
Message-ID: <20060725082144.GA23383@gondor.apana.org.au>
References: <44C596EC.905@trash.net> <E1G5I8b-00063u-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33295 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932155AbWGYIVv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 04:21:51 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <E1G5I8b-00063u-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 25, 2006 at 06:19:33PM +1000, Herbert Xu wrote:
>
> > new kernel:
> > 
> > 1.2.3.4
> >        nexthop realm 1 dev dummy0 weight 1
> >        nexthop realm 2 dev dummy1 weight 1
> >        nexthop realm 3 dev dummy2 weight 1
> >        nexthop realm 4 dev dummy3 weight 1
> 
> This really looks like papering over fundamental brokenness of
> IP_ROUTE_MULTIPATH_CACHED since you wouldn't otherwise get these
> entries in the routing cache.

Nevermind, I misread your changelog.  Your patch is obviously
not related to IP_ROUTE_MULTIPATH_CACHED :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
