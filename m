From: Rick Jones <rick.jones2@hp.com>
Subject: Re: ixgbe patch to provide NIC's tx/rx counters via ethtool
Date: Thu, 24 Sep 2009 09:30:43 -0700
Message-ID: <4ABB9EB3.1000307@hp.com>
References: <4ABAA2D0.4030608@candelatech.com> <4ABAB727.2020507@hp.com> <4ABAD48C.9010808@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:19702 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570AbZIXQam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 12:30:42 -0400
In-Reply-To: <4ABAD48C.9010808@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> Rick Jones wrote:
>> Ben Greear wrote:
>>
>>> When LRO is enabled, the received packet and byte counters represent the
>>> LRO'd packets, not the packets/bytes on the wire. 
>>
>>
>> When LRO is enabled, are all the bytes on the wire actually 
>> transferred into the host?
> 
> No...the ethernet, IP and TCP headers and such are not, for packets that 
> are combined into a single large SKB.
> 
> That is why the driver counts them wrong.  The bytes are off by a few 
> percentage points, but the packet count is off by an order of magnitude.

An overly philosphical question perhaps, but are ethtool stats supposed to 
represent what was on the wire, or what entered the host?

rick
