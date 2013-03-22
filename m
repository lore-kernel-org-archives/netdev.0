From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] decnet: Parse netlink attributes on our
 own
Date: Fri, 22 Mar 2013 10:31:35 -0400 (EDT)
Message-ID: <20130322.103135.962113441677649820.davem@davemloft.net>
References: <5b888618a6aebfebf496c91482794a606b3bb094.1363885020.git.tgraf@suug.ch>
	<1363889099.2707.14.camel@menhir>
	<20130322142735.GA11368@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: swhiteho@redhat.com, netdev@vger.kernel.org,
	linux-decnet-user@lists.sourceforge.net
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50084 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933003Ab3CVObh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 10:31:37 -0400
In-Reply-To: <20130322142735.GA11368@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 22 Mar 2013 14:27:35 +0000

> On 03/21/13 at 06:04pm, Steven Whitehouse wrote:
>> You shouldn't need any special hardware to test this. A copy of iproute2
>> should be enough as you should be able to use that to create an
>> interface or two and a route between them, etc. Although DECnet routing
>> works in a different way to ip routing, the Linux implementation tries
>> to stick fairly closely to the ip way of doing things whenever it can in
>> order to share infrastructure. Now that ip has diverged a fair bit over
>> time that isn't quite as true as it was, but there shouldn't be anything
>> too surprising in there.
> 
> Alright, I did some basic testing with iproute2. I do not claim
> to understand what I did but I ran the following:
> 
> $ ip -f dnet route add 1.661 dev em1
> $ ip -f dnet route list
> 1.661 dev em1  scope link
> 
> $ ip -f dnet neigh add 6.662 dev em1
> $ ip -f dnet neigh list
> 6.662 dev em1 lladdr aa:00:04:00:96:1a PERMANENT
> 
> $ ip -f dnet addr add 1.111 dev em1
> $ ip -f dnet addr list
> 2: em1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast state DOWN qlen 1000
>     dnet 1.111/16 scope global em1

That's good enough for me, both patches applied, thanks Thomas!
