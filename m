From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Wed, 19 Sep 2012 10:28:40 -0700
Message-ID: <505A00C8.5050302@hp.com>
References: <20120917.121243.1665284878800146060.davem@davemloft.net> <1347901326.26523.149.camel@edumazet-glaptop> <1347901493.26523.151.camel@edumazet-glaptop> <20120917.130732.1894375657044880827.davem@davemloft.net> <1348067659.26523.949.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:39909 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756570Ab2ISR2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 13:28:44 -0400
In-Reply-To: <1348067659.26523.949.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2012 08:14 AM, Eric Dumazet wrote:
> I did some tests and got no problem so far, even using splice() [ this
> one was tricky because it only deals with order-0 pages at this moment ]
>
> NIC tested : ixgbe, igb, bnx2x, tg3, mellanox mlx4
>
> On loopback, performance of netperf goes from 31900 Mb/s to 38500 Mb/s,
> thats a 20 % increase.

I guess Brutus will need a new baseline for his TCP Friends patch then :)

BTW, what is the change, if any for TCP_RR?

happy benchmarking,

rick jones
