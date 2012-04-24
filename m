From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net-next] tcp: sk_add_backlog() is too agressive
 for TCP
Date: Mon, 23 Apr 2012 22:27:35 -0400 (EDT)
Message-ID: <20120423.222735.96654838533519471.davem@davemloft.net>
References: <20120423.160149.1515408777176168288.davem@davemloft.net>
	<1335213446.5205.65.camel@edumazet-glaptop>
	<1335234012.5205.97.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org, therbert@google.com,
	ncardwell@google.com, maze@google.com, ycheng@google.com,
	ilpo.jarvinen@helsinki.fi
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34480 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756250Ab2DXC2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 22:28:00 -0400
In-Reply-To: <1335234012.5205.97.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Apr 2012 04:20:12 +0200

> On Mon, 2012-04-23 at 22:37 +0200, Eric Dumazet wrote:
> 
>> We could try to coalesce ACKs before backlogging them. I'll work on
>> this.
>> 
> 
> I did an experiment, and found a basic coalescing was not working in
> case of packet loss and SACK storm.
> 
> Doing a smart coalescing in this case sounds really complex.
> 
> Should we really continue this way ? 

We can consider it later, but for now let's defer.

I'll apply your sk_add_backlog patches for the time being.

Thanks Eric.
