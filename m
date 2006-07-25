From: Rick Jones <rick.jones2@hp.com>
Subject: Re: RDMA will be reverted
Date: Tue, 25 Jul 2006 09:29:11 -0700
Message-ID: <44C646D7.3040701@hp.com>
References: <44C565D1.6070202@hp.com>	<20060724.174518.52116903.davem@davemloft.net>	<44C56BFC.7080000@hp.com> <20060724.182108.37154478.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, rdreier@cisco.com, tom@opengridcomputing.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:19114 "EHLO palrel13.hp.com")
	by vger.kernel.org with ESMTP id S964786AbWGYQ3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 12:29:19 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060724.182108.37154478.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Mon, 24 Jul 2006 17:55:24 -0700
> 
> 
>>Even enough bits for 1024 or 2048 CPUs in the single system image?  I have seen 
>>1024 touted by SGI, and with things going so multi-core, perhaps 16384 while 
>>sounding initially bizzare would be in the realm of theoretically possible 
>>before tooooo long.
> 
> 
> Read the RSS NDIS documents from Microsoft. 

I'll see about hunting them down.

> You aren't going to want
> to demux to more than, say, 256 cpus for single network adapter even
> on the largest machines.

I suppose, it just seems to tweak _small_ alarms in my intuition - maybe because 
it still sounds like networking telling the scheduler where to run threads of 
execution, and even though I'm a networking guy I seem to have the notion that 
it should be the other way 'round.

>>That would cover TCP, are there similarly fungible fields in SCTP or
>>other ULPs?  And if we were to want to get HW support for the thing,
>>getting it adopted in a de jure standards body would probably be in
>>order :)
> 
> 
> Microsoft never does this, neither do we.  LRO came out of our own
> design, the network folks found it reasonable and thus they have
> started to implement it.  The same is true for Microsofts RSS stuff.
> 
> It's a hardware interpretation, therefore it belongs in a driver API
> specification, nowhere else.

It may be a hardware interpretation, but doesn't it have non-trivial system 
implications - where one runs threads/processes etc?

rick jones
