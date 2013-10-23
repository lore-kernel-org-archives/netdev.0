From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Wed, 23 Oct 2013 14:26:00 +0200
Message-ID: <20131023122600.GB22316@secunet.com>
References: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de>
 <20131022.154638.1989281525248160764.davem@davemloft.net>
 <20131023081255.GB10148@secunet.com>
 <1748378.n7GIUzQXTX@h2o.as.studentenwerk.mhn.de>
 <1382529601.7572.2.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wolfgang Walter <linux@stwm.de>,
	David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53214 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753376Ab3JWM0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Oct 2013 08:26:04 -0400
Content-Disposition: inline
In-Reply-To: <1382529601.7572.2.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 23, 2013 at 05:00:01AM -0700, Eric Dumazet wrote:
> On Wed, 2013-10-23 at 13:33 +0200, Wolfgang Walter wrote:
> 
> > I don't know what this value actually means. But on 3.4.x it is much higher. 
> > On a machine with 512MB ram it is 32768, on a machine with 1GB ram it is 
> > 262144 and with 16GB ram it is 4194304.
> > 
> 
> Such huge values should not be needed. We should have at most one dst
> per packet in flight.

We have one cache entry for each packet flow we have already seen.
So a static value should be not too high, because remote entities
can control how many cache entries we have, similar to the routing
cache.
