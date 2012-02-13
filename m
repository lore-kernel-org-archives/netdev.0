From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next] net: implement IP_RECVTOS for
 IP_PKTOPTIONS
Date: Mon, 13 Feb 2012 00:49:56 -0500 (EST)
Message-ID: <20120213.004956.197165779762330530.davem@davemloft.net>
References: <20120209203441.24c97aa3@griffin>
	<20120209203549.09ced962@griffin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478Ab2BMFt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 00:49:59 -0500
In-Reply-To: <20120209203549.09ced962@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Thu, 9 Feb 2012 20:35:49 +0100

> Currently, it is not easily possible to get TOS/DSCP value of packets from
> an incoming TCP stream. The mechanism is there, IP_PKTOPTIONS getsockopt
> with IP_RECVTOS set, the same way as incoming TTL can be queried. This is
> not actually implemented for TOS, though.
> 
> This patch adds this functionality, both for IPv4 (IP_PKTOPTIONS) and IPv6
> (IPV6_2292PKTOPTIONS). For IPv4, like in the IP_RECVTTL case, the value of
> the TOS field is stored from the other party's ACK.
> 
> This is needed for proxies which require DSCP transparency. One such example
> is at http://zph.bratcheda.org/.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

All new features should be submitted against the net-next tree, and this
patch didn't apply there cleanly.

I fixed up the problems, but now that you've been warned I won't do so
for you next time.
