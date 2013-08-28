From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Source routing without rules?
Date: Wed, 28 Aug 2013 03:14:37 +0200
Message-ID: <20130828011437.GA30092@order.stressinduktion.org>
References: <CALCETrVRZF0XLtH9o37Y=ZVMyyExBs7dLYFLOgJ-=vFqy+a_ig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50419 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753496Ab3H1BOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 21:14:38 -0400
Content-Disposition: inline
In-Reply-To: <CALCETrVRZF0XLtH9o37Y=ZVMyyExBs7dLYFLOgJ-=vFqy+a_ig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 27, 2013 at 05:16:21PM -0700, Andy Lutomirski wrote:
> I'm about to implement a trivial source routing policy for the third
> time, and this is IMO stupid.  I want to have two routes to a network.
>  Each route should specify a src, and, if the flow matches the src,
> then that route should win.
> 
> The rules that don't work are:
> 
> ip route add <net> via <gw1> dev <dev1> metric 0
> ip route add <net> via <gw2> dev <dev2> src <dev2addr> metric 10

src is actually the preferred src address. In ipv6 land there is a RTA_SRC
(look for ip route *from* parameter) route attribute settable to only
select routes if the from-source matches the route. If you implement
such a feature I would go with the same design (IPV6_SUBTREES).

Greetings,

  Hannes
