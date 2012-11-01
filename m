From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next] sockopt: Change getsockopt() of SO_BINDTODEVICE
 to return an interface name
Date: Thu, 01 Nov 2012 10:02:25 -0400
Message-ID: <509280F1.5080504@hp.com>
References: <509184D9.8030103@hp.com> <m2wqy6jrne.fsf@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:44746 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756011Ab2KAOCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 10:02:30 -0400
In-Reply-To: <m2wqy6jrne.fsf@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/2012 04:47 PM, Andi Kleen wrote:
> Brian Haley <brian.haley@hp.com> writes:
> 
>> Instead of having the getsockopt() of SO_BINDTODEVICE return an index, which
>> will then require another call like if_indextoname() to get the actual interface
>> name, have it return the name directly.
>>
>> This also matches the existing man page description on socket(7) which mentions
>> the argument being an interface name.
>>
>> If the value has not been set, zero is returned and optlen will be set to zero
>> to indicate there is no interface name present.
> 
> That will break all existing programs using the return value, right?
> Better to fix the manpage

Dave just accepted the original code for this into net-next last week, so I
don't think it's too late to change it to be correct.

-Brian
