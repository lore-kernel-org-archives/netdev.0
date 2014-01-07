From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] IPv6: add the option to use anycast
 addresses as source addresses in echo reply
Date: Tue, 07 Jan 2014 18:33:05 -0500 (EST)
Message-ID: <20140107.183305.1907441201345858474.davem@davemloft.net>
References: <1389103047-3380-1-git-send-email-fx.lebail@yahoo.com>
	<20140107175507.fb543c70.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fx.lebail@yahoo.com, netdev@vger.kernel.org,
	hannes@stressinduktion.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: billfink@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753380AbaAGXdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 18:33:10 -0500
In-Reply-To: <20140107175507.fb543c70.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bill Fink <billfink@mindspring.com>
Date: Tue, 7 Jan 2014 17:55:07 -0500

> Why is ICMPV6 Echo Reply special?  Can't the internal structure
> of the network be divined from other ICMPv6 responses such as
> Destination Unreachable, Time Exceeded (Hop Limit), and Parameter
> Problem.

Right, this RFC is talking about source address selection in general,
so this anycast handling should be in a generic place too.
