From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: xfrm_user: fix selector family initialization
Date: Thu, 10 Apr 2008 02:55:46 +0200
Message-ID: <47FD6592.609@trash.net>
References: <47F4EB73.1040705@trash.net>	<47FBC2AF.7050508@trash.net>	<47FCE30F.8060400@trash.net> <20080409.150931.93235087.davem@davemloft.net> <47FD5B1C.3060005@miyazawa.org> <47FD5CBC.6040905@trash.net> <47FD6464.2000608@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, pupilla@hotmail.com,
	netdev@vger.kernel.org
To: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64402 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197AbYDJAzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Apr 2008 20:55:50 -0400
In-Reply-To: <47FD6464.2000608@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kazunori MIYAZAWA wrote:
> Patrick McHardy wrote:
>> Kazunori MIYAZAWA wrote:
>>>
>>> Sorry, I missed the thread.
>>> I have no idea to solve the regression.
>>
>>
>> Wouldn't explicitly initializing the SA family for
>> inter-family tunnels work?
> 
> I guess it is same as the original Herbert's patch.
> It needs to explicitly initialize the family for inter-family tunnel.


Thanks for looking into this, I haven't seen Herbert's patch,
but I'd assume comparing the SA family to the policy family
would work for determining whether its an inter-family tunnel
in case the family in explicitly initialized. The only thing
that would need to be changed in the kernel is the check
in xfrm_init_state().


