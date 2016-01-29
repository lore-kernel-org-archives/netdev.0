From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: early demux should be aware of fragments
Date: Fri, 29 Jan 2016 12:24:37 -0800 (PST)
Message-ID: <20160129.122437.2258453843319826058.davem@davemloft.net>
References: <1453856382.11327.49.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160127.170203.701586924097928864.davem@davemloft.net>
	<1454080926.7627.49.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@ovn.org, netdev@vger.kernel.org, fw@strlen.de,
	hannes@stressinduktion.org, pshelar@ovn.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39525 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752830AbcA2UYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 15:24:38 -0500
In-Reply-To: <1454080926.7627.49.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 Jan 2016 07:22:06 -0800

> On Wed, 2016-01-27 at 17:02 -0500, David Miller wrote:
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Tue, 26 Jan 2016 16:59:42 -0800
>> 
>> > From: Eric Dumazet <edumazet@google.com>
>> > 
>> > We should not assume a valid protocol header is present,
>> > as this is not the case for IPv4 fragments.
>> > 
>> > Lets avoid extra cache line misses and potential bugs
>> > if we actually find a socket and incorrectly uses its dst.
>> > 
>> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>> 
>> Applied, thanks.
> 
> David, I do not see this patch in net tree ?

This should be fixed now, thanks for letting me know.
