From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: introduce netdevice gso_min_segs
 attribute
Date: Mon, 06 Oct 2014 17:54:10 -0400 (EDT)
Message-ID: <20141006.175410.2083551367207718756.davem@davemloft.net>
References: <1412529087.11091.14.camel@edumazet-glaptop2.roam.corp.google.com>
	<20141006.172149.1596496098013953331.davem@davemloft.net>
	<1412631778.11091.84.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, edumazet@google.com, netdev@vger.kernel.org,
	yevgenyp@mellanox.com, ogerlitz@mellanox.com, idos@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38548 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbaJFVyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 17:54:13 -0400
In-Reply-To: <1412631778.11091.84.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 06 Oct 2014 14:42:58 -0700

> On Mon, 2014-10-06 at 17:21 -0400, David Miller wrote:
> 
>> So exactly what value are you using for mlx4?
>> 
> 
> It seems that on ConnectX-3 family, TSO packets of 2 or 3 MSS are not
> worth using TSO engine. The cutoff point seems to be 4 (same throughput)
> 
> So I was planning to use gso_min_segs = 4 only for them.
> 
>> Because I wonder if we should just generically forfeit TSO unless
>> we have > 2 segments, for example.
> 
> When I tested on bnx2x, this was not a gain.
> 
> bnx2x is faster sending TSO packets, even if they have 2 MSS.
> 
> I'll try the experiment on I40E Intel cards.

Ok I'm sold on your patch then if two major chipsets already benefit
from differing values.

I'll apply this, thanks Eric.
