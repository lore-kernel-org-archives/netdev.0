From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] udp: don't rereference dst_entry dev pointer on rcv
Date: Fri, 12 Apr 2013 18:32:51 -0400 (EDT)
Message-ID: <20130412.183251.1449847994152577369.davem@davemloft.net>
References: <1365697961.3887.176.camel@edumazet-glaptop>
	<1365702804.3887.180.camel@edumazet-glaptop>
	<1365719193.3887.190.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tparkin@katalix.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54745 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491Ab3DLWcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 18:32:52 -0400
In-Reply-To: <1365719193.3887.190.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 11 Apr 2013 15:26:33 -0700

> On Thu, 2013-04-11 at 10:53 -0700, Eric Dumazet wrote:
>> On Thu, 2013-04-11 at 09:32 -0700, Eric Dumazet wrote:
>> 
>> > Short update : I do not understand yet why this patch is not working.
>> > 
>> > Normally, the reassembled packet should get the dst from the last skb
>> > (the one completing the packet)...
>> > 
>> > I have to make more experiments.
>> 
>> OK I think I've nailed it, please try following patch (I tried it on
>> net-next, but it should apply on previous kernels)
> 
> By the way I am ashamed by commit 64f3b9e203bd068550
> (net: ip_expire() must revalidate route)
> 
> Reading its changelog now, I understand I should have fixed this the
> way we did today...
> 
> :(

There is still time to do it the right way Eric :-)
