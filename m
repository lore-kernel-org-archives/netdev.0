From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET 00/02]: MACVLAN driver
Date: Wed, 20 Jun 2007 01:44:50 +0200
Message-ID: <46786A72.9080409@trash.net>
References: <20070619130825.26769.23059.sendpatchset@localhost.localdomain>	<20070619090027.3312f2cf@localhost.localdomain>	<4678472D.5050907@trash.net> <20070619.154840.55744015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36194 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755643AbXFSXpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 19:45:21 -0400
In-Reply-To: <20070619.154840.55744015.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Tue, 19 Jun 2007 23:14:21 +0200
>
>   
>> Stephen Hemminger wrote:
>>     
>>> Looks good. I have some changes to allow devices with multiple MAC addresses
>>> (never finished).  This device could use that.
>>>       
>> How would the driver do that? I was thinking about using dev_add_mc,
>> but wasn't sure if that would work with all drivers for non-multicast
>> addresses.
>>     
>
> This is actually a real issue for virtualization, and many
> if not all current generation ethernet chips support
> programming several unicast ethernet addresses in the MAC.
>
> Networking switches in domain0 on virtualization hosts use
> this feature to support seperate MACs per guest node,
> and if the chip doesn't support this the chip is put into
> promiscuous mode.
>
> We don't have any clean interfaces by which to do this MAC
> programming, and we do need something for it soon.
>   

Stephen's suggestion sounds reasonable and easily implementable,
I'll see if I can come up with a patch.


