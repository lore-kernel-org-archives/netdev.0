From: David Miller <davem@davemloft.net>
Subject: Re: How exactly does CHECKSUM_COMPLETE works?
Date: Tue, 30 Sep 2014 16:14:24 -0400 (EDT)
Message-ID: <20140930.161424.679705969149272577.davem@davemloft.net>
References: <B5657A6538887040AD3A81F1008BEC63B4152D@avmb3.qlogic.org>
	<1412104977.30721.94.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412105832.30721.95.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49340 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695AbaI3UO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 16:14:26 -0400
In-Reply-To: <1412105832.30721.95.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 30 Sep 2014 12:37:12 -0700

> On Tue, 2014-09-30 at 12:22 -0700, Eric Dumazet wrote:
>> On Tue, 2014-09-30 at 19:05 +0000, Yuval Mintz wrote:
>> 
>> > Can you pinpoint me to what exactly in the code corrects NAPI_GRO_CB(skb)->csum
>> > by negating the ipv4 part in the ones' complete checksum?
>> > 
>> > E.g., for ipv6 [in ipv6_gro_receive()] I can see that skb_gro_postpull_rcsum() is
>> > called after pulling the ipv6 header [and before proceeding to the next protocol],
>> > but I can't seem to find anything similar to this for ipv4 [in inet_gro_receive()].
>> > 
>> 
>> 
>> IPv4 header is supposed to have a 0 checksum ;)
>> 
> 
> Or if you prefer :

Someone please submit this formally :)
