From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC PATCH 00/04]: VLAN vs. packet socket inconsistencies
Date: Wed, 09 Jul 2008 00:48:38 +0200
Message-ID: <4873EEC6.1060306@trash.net>
References: <20080708.151233.259338088.davem@davemloft.net>	<4873EA6C.40408@trash.net>	<20080708.153510.107686198.davem@davemloft.net> <20080708.153850.195636789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41811 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbYGHWsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 18:48:41 -0400
In-Reply-To: <20080708.153850.195636789.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 08 Jul 2008 15:35:10 -0700 (PDT)
>
>   
>> From: Patrick McHardy <kaber@trash.net>
>> Date: Wed, 09 Jul 2008 00:30:04 +0200
>>
>>     
>>> That sounds good. Userspace needs to know about the size of
>>> the tpacket_hdr before setting the ring parameters so it can
>>> size the ring frames appropriately for the largest packet size
>>> it wants to receive. This means the offset field in the
>>> tpacket_hdr is redundant, so I'll just add a getsockopt
>>> option for getting the size. Unless we want to be able to
>>> include only a partial tpacket_hdr, but I don't think that
>>> would be very useful.
>>>       
>> Ok, in that case using a getsockopt() to query the size sounds great.
>>     
>
> BTW, what you might want to do is say that if the user
> makes the new getsockopt() size query, he understands
> and wants the new style tpacket_hdr layout.
>   

I'm torn between "nice hack" and "doesn't belong there".
I'll see how I feel about this once I get to that point :)
