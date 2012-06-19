From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Early TCP socket demux.
Date: Mon, 18 Jun 2012 23:07:23 -0700 (PDT)
Message-ID: <20120618.230723.612232275251003129.davem@davemloft.net>
References: <1340079938.7491.2172.camel@edumazet-glaptop>
	<20120618.212721.2148947025741866390.davem@davemloft.net>
	<1340080661.7491.2205.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50969 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752615Ab2FSGH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 02:07:26 -0400
In-Reply-To: <1340080661.7491.2205.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 Jun 2012 06:37:41 +0200

> On Mon, 2012-06-18 at 21:27 -0700, David Miller wrote:
> 
>> How are we not using it?  We use the cached SKB socket no matter what
>> happens.
>> 
>> Look at how inet hash lookup works.
>> 
>> The error tells the caller solely whether a route lookup is still
>> necessary.
> 
> OK, remove the unlikely() in __inet_lookup_skb() so that its obvious we
> have this skb_steal_sock() thing :)

Sure thing.

We also need to add some dst->ops->check() handling as well.
