From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Thu, 20 Sep 2012 15:40:07 -0400 (EDT)
Message-ID: <20120920.154007.1073423645697694793.davem@davemloft.net>
References: <CAGK4HS_ZKKrzFh+c3WDxbkMFpDTg7ehw9ydp39k6JPFA_j1YOw@mail.gmail.com>
	<1348119475.31352.60.camel@edumazet-glaptop>
	<505B4E13.5000501@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, subramanian.vijay@gmail.com,
	netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754093Ab2ITTkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 15:40:09 -0400
In-Reply-To: <505B4E13.5000501@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 20 Sep 2012 10:10:43 -0700

> On 09/19/2012 10:37 PM, Eric Dumazet wrote:
>> loopback is lossless, so its always surprising we can have TCP
>> retransmits on this medium ;)
> 
> Is it lossless?
> 
> raj@tardy:~/netperf2_trunk$ netstat -s | grep pru
>     19 packets pruned from receive queue because of socket buffer overrun

Those packets are not being dropped by the loopback device.
