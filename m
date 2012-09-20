From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] tcp: use order-3 pages in tcp_sendmsg()
Date: Thu, 20 Sep 2012 13:06:22 -0700
Message-ID: <505B773E.9070501@hp.com>
References: <CAGK4HS_ZKKrzFh+c3WDxbkMFpDTg7ehw9ydp39k6JPFA_j1YOw@mail.gmail.com> <1348119475.31352.60.camel@edumazet-glaptop> <505B4E13.5000501@hp.com> <20120920.154007.1073423645697694793.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, subramanian.vijay@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:43040 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754870Ab2ITUGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 16:06:24 -0400
In-Reply-To: <20120920.154007.1073423645697694793.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/2012 12:40 PM, David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Thu, 20 Sep 2012 10:10:43 -0700
>
>> On 09/19/2012 10:37 PM, Eric Dumazet wrote:
>>> loopback is lossless, so its always surprising we can have TCP
>>> retransmits on this medium ;)
>>
>> Is it lossless?
>>
>> raj@tardy:~/netperf2_trunk$ netstat -s | grep pru
>>      19 packets pruned from receive queue because of socket buffer overrun
>
> Those packets are not being dropped by the loopback device.
>

Yes, I was being too fast and loose with my wording, paying more 
attention to the netperf tests than the rest of it.  While loopback may 
be lossless, TCP retransmissions over loopback shouldn't be all *that* 
surprising.

rick
