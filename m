From: Lukas Tribus <luky-37@hotmail.com>
Subject: RE: IPv6 routing table max_size badly dimensioned compared to IPv4
Date: Fri, 4 Apr 2014 18:03:42 +0200
Message-ID: <DUB123-W32175F346BC24A876CDAA2ED6F0@phx.gbl>
References: <1393532583.26794.26.camel@edumazet-glaptop2.roam.corp.google.com>,<20140227205010.GB27495@order.stressinduktion.org>,<1393534920.26794.40.camel@edumazet-glaptop2.roam.corp.google.com>,<20140227.174755.801004637112620140.davem@davemloft.net>,<20140228110735.GA13494@xs.powerdns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: bert hubert <bert.hubert@netherlabs.nl>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc3-s33.dub0.hotmail.com ([157.55.2.42]:37793 "EHLO
	dub0-omc3-s33.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753229AbaDDQIy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2014 12:08:54 -0400
In-Reply-To: <20140228110735.GA13494@xs.powerdns.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Thu, Feb 27, 2014 at 05:47:55PM -0500, David Miller wrote:
>>> If we need to perform 10000 inserts per second, and gc timeout is 60
>>> seconds, tree contains 600.000 entries, gc takes forever...
>>
>> The only long term solution is to align ipv6 to be more like ipv4.
>
> Yes please. There appears to be a lingering assumption IPv6 is small scale.
>
> T-Mobile USA is now providing IPv6 only service via DNA64/NAT64, creating
> (dozens of) millions of IPv6 only clients. (More on this 'hack' on
> http://blog.powerdns.com/2013/05/17/ripe-66-powerdns-and-dns64nat64/ )
>
> So aligning IPv6 scalability with IPv4 scalability would be grand, thanks!

FYI, this was also mentioned by Paul Saab from Facebook in a
presentation [1] during last months V6 World Congress [2].

Looks like more and more people start hitting this.



Best regards,

Lukas


[1] https://www.facebook.com/groups/2234775539/10152303014725540/
[2] http://www.uppersideconferences.com/v6world2014/v6world2014introduction.html 		 	   		  