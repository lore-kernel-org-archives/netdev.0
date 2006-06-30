From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 15:34:42 -0400
Message-ID: <1151696083.5270.218.camel@jzny2>
References: <20060630004640.GC14627@postel.suug.ch>
	 <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch>
	 <1151675843.5270.18.camel@jzny2> <20060630141531.GG14627@postel.suug.ch>
	 <1151678118.5270.45.camel@jzny2> <20060630163229.GH14627@postel.suug.ch>
	 <20060630171348.GI14627@postel.suug.ch> <44A55CF8.2040509@trash.net>
	 <1151688732.5270.101.camel@jzny2>  <20060630174251.GK14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:42180 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S964930AbWF3Teq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jun 2006 15:34:46 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FwOlO-0002yc-Ov
	for netdev@vger.kernel.org; Fri, 30 Jun 2006 15:34:50 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060630174251.GK14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-30-06 at 19:42 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-06-30 13:32

> > Thomas makes the claim, this can be achieved only by using an ifindex.
> > And i havent been able to see how. I have a small performance problem if
> > i just use ifindex. Using ifindex will eventually save 32 bits on the
> > 64 bit machines. I posed the question as to which was more beneficial
> > as a solution that hasnt been addressed.
> 
> I'd appreciate if you'd stop sperading lies. 
>
> I claimed it to be the
> best solution, not the only one. Everyone agrees that it's possible
> to use a pointer and take a reference in netif_receive_skb() while
> it also seems obvious to most that it's not a good idea to take two
> additional atomic operations in the fast path for this purpose.

I thought we went past that point already - and i made it clear that
the reference is _not_ taken in netif_receive_skb().

So assuming it is taken in mirred (i havent thought of where it is
decremented), why would using the ifindex be better?

cheers,
jamal

