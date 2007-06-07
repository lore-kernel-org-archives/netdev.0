From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [Devel] Re: [PATCH] Virtual ethernet tunnel
Date: Thu, 07 Jun 2007 11:30:22 +0200
Message-ID: <4667D02E.2090404@bull.net>
References: <4666CEAA.8010903@openvz.org>	<20070606.124758.85411179.davem@davemloft.net>	<4667BE65.2060307@sw.ru> <20070607.020733.123970478.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dev@sw.ru, containers@lists.osdl.org, netdev@vger.kernel.org,
	dev@openvz.org, kaber@trash.net, xemul@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:47964 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193AbXFGJd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 05:33:28 -0400
In-Reply-To: <20070607.020733.123970478.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Kirill Korotaev <dev@sw.ru>
> Date: Thu, 07 Jun 2007 12:14:29 +0400
> 
>> David Miller wrote:
>>> From: Pavel Emelianov <xemul@openvz.org>
>>> Date: Wed, 06 Jun 2007 19:11:38 +0400
>>>
>>>
>>>> Veth stands for Virtual ETHernet. It is a simple tunnel driver
>>>> that works at the link layer and looks like a pair of ethernet
>>>> devices interconnected with each other.
>>>
>>> I would suggest choosing a different name.
>>>
>>> 'veth' is also the name of the virtualized ethernet device
>>> found on IBM machines, driven by driver/net/ibmveth.[ch]
>> AFAICS, ibmveth.c registers ethX devices, while this driver registers
>> vethX by default, so there is no much conflict IMHO.
> 
> If that's the case, veth is fine with me.

I like Daniel's proposals with the tunnel or pipe thing in the name.
I think it is more explicit about what the device really is.

I'm currently using etun, Eric Biederman's implementation. It will be 
nice to have this kind of device merged.

-- Benjamin

-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
