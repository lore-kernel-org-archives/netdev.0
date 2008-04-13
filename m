From: Patrick McHardy <kaber@trash.net>
Subject: Re: Re-queueing of skb in vlan_skb_recv
Date: Sun, 13 Apr 2008 06:47:13 +0200
Message-ID: <48019051.3090009@trash.net>
References: <47FF5DAB.1060906@trash.net>	<20080411125313.GI9785@ZenIV.linux.org.uk>	<47FF614E.7040500@trash.net> <20080411.105413.34923074.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, Brian_Oostenbrink@pmc-sierra.com,
	linux-net@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32790 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbYDMErS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 00:47:18 -0400
In-Reply-To: <20080411.105413.34923074.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Fri, 11 Apr 2008 15:02:06 +0200
> 
>> Al Viro wrote:
>>> Another possibility would be to allow ->func() of packet_type to return an
>>> skb for reprocessing...
 >>>
>> That should work fine for VLAN, but not for loopback since its
>> called on the TX path. I think I prefer Eric's suggested way
>> because it doesn't require to change all the other existing
>> packet_type users.
> 
> I think Al's idea is the most elegant proposed so far and we could do
> something similar on the TX side as well.
> 
> Yes, it means diddling with a lot of call sites, but we do that all
> the time and it's heaps better then these "check the stack space
> remaining" hacks being proposed.

Agreed on second thought, I guess I was just being lazy :)


