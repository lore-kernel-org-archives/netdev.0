From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/16] Handle redirects just like PMTU
Date: Thu, 12 Jul 2012 03:58:40 -0700 (PDT)
Message-ID: <20120712.035840.603313259204428604.davem@davemloft.net>
References: <20120712.011030.1683311016960504439.davem@davemloft.net>
	<1342082733.3265.8254.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55780 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495Ab2GLK6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 06:58:43 -0400
In-Reply-To: <1342082733.3265.8254.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 12 Jul 2012 10:45:33 +0200

> On Thu, 2012-07-12 at 01:10 -0700, David Miller wrote:
>> As described in my patch series from the other day, we need to
>> rearrange redirect handling so that the local initiators of packets
>> (sockets, tunnels, xfrms, etc.) that implement the protocols compute
>> the route and pass this down into the ipv4/ipv6 routing code.
>> 
>> These changes here do so by implementing a new dst_ops->redirect
>> method.
>> 
>> No more do we have this funny code that tries several different sets
>> of routing keys to try and figure out which route the redirect should
>> actually be applied to.
>> 
>> No more do we have the problem wherein TOS rewriting causes problems
>> for us.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Wow, this looks very good.
> 
> I did a quick review and found no obvious problem.
> 
> Bye bye ip_rt_redirect(), finally ;)

Great.  I'm feeling brave so I'll push this out to net-next after
doing some more build validation.:)
