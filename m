From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Fri, 23 Dec 2011 09:58:37 +0100
Message-ID: <20111223085837.GV6348@secunet.com>
References: <20111220071843.GL6348@secunet.com>
 <20111220.133542.2144336048061483258.davem@davemloft.net>
 <20111221085616.GO6348@secunet.com>
 <20111221.155615.990885397853981125.davem@davemloft.net>
 <20111222102526.GT6348@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39886 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753863Ab1LWI6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Dec 2011 03:58:40 -0500
Content-Disposition: inline
In-Reply-To: <20111222102526.GT6348@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 22, 2011 at 11:25:26AM +0100, Steffen Klassert wrote:
> > 
> > Ok, so what you're saying is that we need a way to invalidate inetpeer
> > entries, or at least invalidate their cached metrics and set
> > INETPEER_METRICS_NEW once more.
> 
> Yes, we probaply need to invalidate whenever the fib changes.
> We would have to invalidate at least the cached metrics and
> all the pmtu related stuff we have on the inetpeer now.
> Not sure if it is better to just invalidate some pieces
> or the whole inetpeer entries.
> 

I think I would favour to invalidate the inetpeer entries, we could
do this similar to the invalidation of the routing cache. Do you have
any preferences on this regarding the routing cache removal?

I'll continue to work at this in the new year, as I'll leave for
holidays in some hours.
