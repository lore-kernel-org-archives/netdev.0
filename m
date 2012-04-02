From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: check the length of the data before dereferencing
 it
Date: Mon, 02 Apr 2012 00:14:29 -0400 (EDT)
Message-ID: <20120402.001429.145178038621256162.davem@davemloft.net>
References: <1333338345.2325.6591.camel@edumazet-glaptop>
	<20120401.235533.147910953675133023.davem@davemloft.net>
	<1333339105.2325.6622.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, kaber@trash.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47484 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717Ab2DBEQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 00:16:38 -0400
In-Reply-To: <1333339105.2325.6622.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Apr 2012 05:58:25 +0200

> On Sun, 2012-04-01 at 23:55 -0400, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Mon, 02 Apr 2012 05:45:45 +0200
>> 
>> > Usually not a problem since we have many bytes after our head.
>> 
>> We always have bytes after the head, it's guarenteed, and whether it's
>> garbage bytes or skb_shared_info() it simply doesn't matter.
> 
> Then you have to add a kmemcheck_something() to make this clear and
> avoid possible warnings.

That's perfectly fine and would document the situation.  And we can
add a similar annotation to the two other nearly identical pieces of
code in net/netfilter/nf_conntrack_proto_tcp.c
