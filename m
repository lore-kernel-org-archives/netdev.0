From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v5] IPv6: add the option to use anycast addresses as source addresses in echo reply
Date: Wed, 8 Jan 2014 00:39:29 +0100
Message-ID: <20140107233929.GN30393@order.stressinduktion.org>
References: <1389103047-3380-1-git-send-email-fx.lebail@yahoo.com> <20140107175507.fb543c70.billfink@mindspring.com> <20140107.183305.1907441201345858474.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: billfink@mindspring.com, fx.lebail@yahoo.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:46655 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753585AbaAGXjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 18:39:31 -0500
Content-Disposition: inline
In-Reply-To: <20140107.183305.1907441201345858474.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 07, 2014 at 06:33:05PM -0500, David Miller wrote:
> From: Bill Fink <billfink@mindspring.com>
> Date: Tue, 7 Jan 2014 17:55:07 -0500
> 
> > Why is ICMPV6 Echo Reply special?  Can't the internal structure
> > of the network be divined from other ICMPv6 responses such as
> > Destination Unreachable, Time Exceeded (Hop Limit), and Parameter
> > Problem.
> 
> Right, this RFC is talking about source address selection in general,
> so this anycast handling should be in a generic place too.

I think it would be reasonable to change future behavior to always
send back icmp errors with the anycast address (same as original packet
destination). Ping is a bit special as it is used for service discovery.

UDP sockets can use their source address at will. So I still think this change
is reasonable.
