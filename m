From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] IP_MAX_MTU value
Date: Fri, 21 Dec 2012 10:50:26 -0800
Message-ID: <50D4AF72.2020101@hp.com>
References: <1356072468.21834.4805.camel@edumazet-glaptop> <50D4A84D.1010402@hp.com> <1356114879.21834.7709.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:27370 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136Ab2LUSu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 13:50:28 -0500
In-Reply-To: <1356114879.21834.7709.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2012 10:34 AM, Eric Dumazet wrote:
> On Fri, 2012-12-21 at 10:19 -0800, Rick Jones wrote:
>
>> If you go beyond the protocol limit of an IPv4 datagram, won't it be
>> necessary to  start being a bit more conditional on IPv4 vs IPv6?
>>
>
> This IP_MAX_MTU is really an IPv4 thing (static to net/ipv4/route.c)

OK. Doesn't this:

         if (mtu > IP_MAX_MTU)
                 mtu = IP_MAX_MTU;

mean it should be OK to go to 0xFFFF but not 0x10000?  Since 65535 is 
the limit of an IPv4 datagram and so I would think would be the maximum 
MTU for an IPv4 interface.

rick
