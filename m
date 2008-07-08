From: Patrick McHardy <kaber@trash.net>
Subject: Re: vlan 03/07: Add ethtool support
Date: Tue, 08 Jul 2008 16:01:16 +0200
Message-ID: <4873732C.3000508@trash.net>
References: <20080707123557.23947.70114.sendpatchset@localhost.localdomain> <20080707123601.23947.96915.sendpatchset@localhost.localdomain> <20080707165217.GC28029@solarflare.com> <48724B81.2070708@trash.net> <20080707172119.GD28029@solarflare.com> <48725698.1030809@trash.net> <20080708135415.GH28029@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61748 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbYGHOMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 10:12:31 -0400
In-Reply-To: <20080708135415.GH28029@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Patrick McHardy wrote:
>   
>> Ben Hutchings wrote:
>>     
>>> I would be surprised if there aren't some NICs that only check frames with
>>> protocol/length set to ETH_P_IP.
>>>       
>> Yes, probably. But this is only informational and it won't be
>> any wronger than on the device itself. So no big deal I'd say,
>> but if you prefer I can also remove the TX csum support.
>>     
>
> As I said there's no way to see which protocols RX csum offload works for
> anyway, so just showing whether it's enabled on the physical device is no
> worse than the current behaviour for physical devices.

I must have misunderstood you then. Thats the way I see
it as well.

>> LRO is currently not supported by the VLAN code, at least
>> not directly (drivers supporting VLAN accel can do VLAN
>> LRO though). So for now it seems useless to add it.
>>     
>
> If the physical device driver is doing VLAN LRO then doesn't it make sense
> to expose this in the VLAN device?
>   

You're right, that makes sense. I'll add a patch to my next update to do
this.
