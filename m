From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] vlan: adds drops accounting
Date: Fri, 04 Sep 2009 13:59:24 +0200
Message-ID: <4AA1011C.7050909@trash.net>
References: <4A9F9CD4.7040408@gmail.com> <20090903.201131.194103894.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63042 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755737AbZIDL7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2009 07:59:25 -0400
In-Reply-To: <20090903.201131.194103894.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 03 Sep 2009 12:39:16 +0200
> 
>> Its hard to tell if vlans are dropping frames, since
>> every frame given to vlan_???_start_xmit() functions
>> is accounted as fully transmitted by lower device.
>>
>> We can test dev_queue_xmit() return values to
>> properly account for dropped frames.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Applied.
> 
> But, how inappropriate would it be to keep doing the accounting
> but pass the status back to the caller?  Or will that screw up
> the qdisc running engine?

Its currently not possible to return the dev_queue_xmit() status
from ndo_start_xmit(). My patch to extend the possible return
values will allow that. I hope I'm able to take care of it today.


