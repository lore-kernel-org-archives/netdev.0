From: David Miller <davem@davemloft.net>
Subject: Re: increase the number of routing tables
Date: Sun, 29 Jan 2012 16:01:52 -0500 (EST)
Message-ID: <20120129.160152.1463516627658543873.davem@davemloft.net>
References: <CANj2EbfR0cBaBd+t1yCZyErRpVzSC00DZohvtyazK8_9bv2aEQ@mail.gmail.com>
	<1327804887.2805.20.camel@edumazet-laptop>
	<4F24B2E9.3010600@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, simonchennj@gmail.com,
	netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59759 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751834Ab2A2VB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2012 16:01:59 -0500
In-Reply-To: <4F24B2E9.3010600@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Sat, 28 Jan 2012 18:46:01 -0800

> On 01/28/2012 06:41 PM, Eric Dumazet wrote:
>> Its is possible, but probably not scalable.
> 
> I've run with a few thousand routing tables and probably 5000 or so
> rules.  It seems to run OK....
> 
>> You really should not have too many "ip rule" entries, since they are
>> evaluated linearly.
> 
> For every packet, or maybe just until conn-track gets an entry
> for the connection?

When the routing cache is removed, using a huge number of rules is not
going to be something you want to do any more because the rule table
will be inspected on every route lookup.
