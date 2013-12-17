From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: use interface mtu for determining if
 packet-too-big should be send
Date: Tue, 17 Dec 2013 16:42:56 -0500 (EST)
Message-ID: <20131217.164256.473228543329254152.davem@davemloft.net>
References: <20131216080914.GA28677@order.stressinduktion.org>
	<1387201782.19078.230.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131216140124.GA5164@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49264 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425Ab3LQVm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 16:42:58 -0500
In-Reply-To: <20131216140124.GA5164@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 16 Dec 2013 15:01:24 +0100

> On Mon, Dec 16, 2013 at 05:49:42AM -0800, Eric Dumazet wrote:
>> On Mon, 2013-12-16 at 09:09 +0100, Hannes Frederic Sowa wrote:
>> > IPv6 forwarding path should also not depend on the path mtu values to
>> > judge if a packet should get dropped and an ICMP PTB should be returned.
>> > 
>> > For the accompanying change in IPv4, have a look at "ipv4: introduce
>> > ip_dst_mtu_secure and protect forwarding path against pmtu spoofing".
>> > 
>> 
>> No commit sha1 (truncated to 12 digits) ?
> 
> The patch is not yet committed.

It's confusing to propose an ipv6 version of an ipv4 patch that hasn't
been integrated yet, please don't do this.

I would suggest instead fo post the ipv4 and ipv6 variants together
when you want me to consider applying them, or to provide them as
a unit for review.
