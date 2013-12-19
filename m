From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: introduce ip_dst_mtu_secure and protect
 forwarding path against pmtu spoofing
Date: Thu, 19 Dec 2013 00:12:03 -0500 (EST)
Message-ID: <20131219.001203.1942468169345523058.davem@davemloft.net>
References: <20131218.173442.336109133942416102.davem@davemloft.net>
	<CABrhC0nG8Z01G-zVtObe40OuyDo0Jm5y+Lzy_r-zr2zmjfaKjQ@mail.gmail.com>
	<20131219000759.GF3505@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58930 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848Ab3LSFMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 00:12:07 -0500
In-Reply-To: <20131219000759.GF3505@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 19 Dec 2013 01:07:59 +0100

> On Wed, Dec 18, 2013 at 06:55:13PM -0500, John Heffner wrote:
>> On using the interface MTU for all forwarded packets, I have a similar
>> reaction as David.  And why are forwarded packets more special than
>> local ones, from the routing code's point of view?  It seems like
>> there could be other ways to harden a router, like firewall rules.
> 
> I doubt it is trivial to set up such a filter as we have to inspect
> the payload of the icmp error. I played with it and it is certainly
> possible, but my intention was that the networking stack does try to
> prevent fragmentation and delay generation of fragments to the last
> router on the path where it is necessary.

John's more important point is why treat forwarded traffic specially
from that which is locally generated?
