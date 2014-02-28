From: bert hubert <bert.hubert@netherlabs.nl>
Subject: Re: IPv6 routing table max_size badly dimensioned compared to IPv4
Date: Fri, 28 Feb 2014 12:07:35 +0100
Message-ID: <20140228110735.GA13494@xs.powerdns.com>
References: <1393532583.26794.26.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140227205010.GB27495@order.stressinduktion.org>
 <1393534920.26794.40.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140227.174755.801004637112620140.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xs.powerdns.com ([82.94.213.34]:58612 "EHLO xs.powerdns.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751021AbaB1LHk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 06:07:40 -0500
Content-Disposition: inline
In-Reply-To: <20140227.174755.801004637112620140.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 27, 2014 at 05:47:55PM -0500, David Miller wrote:
> > If we need to perform 10000 inserts per second, and gc timeout is 60
> > seconds, tree contains 600.000 entries, gc takes forever...
> 
> The only long term solution is to align ipv6 to be more like ipv4.

Yes please. There appears to be a lingering assumption IPv6 is small scale.

T-Mobile USA is now providing IPv6 only service via DNA64/NAT64, creating
(dozens of) millions of IPv6 only clients. (More on this 'hack' on
http://blog.powerdns.com/2013/05/17/ripe-66-powerdns-and-dns64nat64/ )

So aligning IPv6 scalability with IPv4 scalability would be grand, thanks!

	Bert
