From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] net/mlx4: use one page fragment per incoming
 frame
Date: Mon, 03 Jun 2013 11:24:48 -0700
Message-ID: <51ACDF70.4050301@hp.com>
References: <1370282095.24311.171.camel@edumazet-glaptop> <51ACDAF5.2040008@hp.com> <1370283150.24311.179.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:41924 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754821Ab3FCSYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 14:24:50 -0400
In-Reply-To: <1370283150.24311.179.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2013 11:12 AM, Eric Dumazet wrote:
> On Mon, 2013-06-03 at 11:05 -0700, Rick Jones wrote:
>
>> I take it this is a > 10 Gbit/s NIC?
>>
>
> Well, I guess so !
>
> Or something is really strange with this NIC !

Indeed.

>> What if any is the downside to an incoming stream of small packets?
>
> These kind of NIC are aimed for performance, I was told.
>
> 1) It would be strange to use them on memory constrained machines.
>
> 2) using 1536 bytes fragments is better than most other NIC drivers, as
> they usually use 2048 or 4096 bytes frags
>
> 3) Current memory allocations done in mlx4 uses order-2 pages, and
> nobody yet complained that these allocation might fail...

I was thinking more about getting up to a socket and finding 
insufficient overhead remaining to hold the packet.

rick
