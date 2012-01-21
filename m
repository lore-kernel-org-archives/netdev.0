From: David Miller <davem@davemloft.net>
Subject: Re: Why is gre0 auto-created, and can we fix it?
Date: Sat, 21 Jan 2012 13:40:36 -0500 (EST)
Message-ID: <20120121.134036.1565691107664746948.davem@davemloft.net>
References: <4F035F2C.1000003@candelatech.com>
	<m3fwf9gdjm.fsf@intrepid.localdomain>
	<4F1AFA84.5050201@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42088 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980Ab2AUSkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2012 13:40:51 -0500
In-Reply-To: <4F1AFA84.5050201@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Sat, 21 Jan 2012 09:48:52 -0800

> On 01/21/2012 09:39 AM, Krzysztof Halasa wrote:
>> Ben Greear<greearb@candelatech.com>  writes:
>>
>>>>> As far as I can tell, no other interfaces are auto-created
>>>>> in this manner.
>>>>
>>>> ip6tnl0 and sit0 do it too, just grep for alloc_netdev() under
>>>> net/{ipv4,ipv6}/
>>>
>>> So, no changing the behaviour?
>>
>> Perhaps making it CONFIGurable would be safe enough, not that I like
>> CONFIG options for all tiny details (one may argue it's not a tiny
>> detail).
>>
>> Haven't looked at the actual code.
> 
> Seems like it could be a run-time configurable, maybe module or boot
> option
> or sysctl or something.

I would seriously prefer that you not do this.
