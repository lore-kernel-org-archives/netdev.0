From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: xfrm_user: fix selector family initialization
Date: Thu, 10 Apr 2008 02:18:04 +0200
Message-ID: <47FD5CBC.6040905@trash.net>
References: <47F4EB73.1040705@trash.net>	<47FBC2AF.7050508@trash.net>	<47FCE30F.8060400@trash.net> <20080409.150931.93235087.davem@davemloft.net> <47FD5B1C.3060005@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, pupilla@hotmail.com,
	netdev@vger.kernel.org
To: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63636 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389AbYDJASH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2008 20:18:07 -0400
In-Reply-To: <47FD5B1C.3060005@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kazunori MIYAZAWA wrote:
> David Miller wrote:
>> From: Patrick McHardy <kaber@trash.net>
>> Date: Wed, 09 Apr 2008 17:38:55 +0200
>>
>>>     [XFRM]: xfrm_user: fix selector family initialization
>>>         Commit df9dcb45 ([IPSEC]: Fix inter address family IPsec 
>>> tunnel handling)
>>>     broke openswan by removing the selector initialization for tunnel 
>>> mode
>>>     in case it is uninitialized.
>>>         This patch restores the initialization, fixing openswan, but 
>>> probably
>>>     breaking inter-family tunnels again (unknown since the patch author
>>>     disappeared). The correct thing for inter-family tunnels is probably
>>>     to simply initialize the selector family explicitly.
>>>         Signed-off-by: Patrick McHardy <kaber@trash.net>
>>
>> I've applied this to net-2.6, thanks Patrick.
>>
>> Once we resolve how to get inter-family working without
>> breaking existing setups, we can put better logic back
>> in here.  But for now the regression is more important.
> 
> Sorry, I missed the thread.
> I have no idea to solve the regression.


Wouldn't explicitly initializing the SA family for
inter-family tunnels work?
