From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC Patch net-next] ipv6: look up neighbours on demand in ip6_finish_output2()
Date: Tue, 15 Jan 2013 21:22:33 +0900
Message-ID: <50F54A09.2040206@linux-ipv6.org>
References: <1358170515-1383-1-git-send-email-xiyou.wangcong@gmail.com> <20130114.133004.19237632940616685.davem@davemloft.net> <50F4BEB2.2050201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	roland@purestorage.com, Eric Dumazet <eric.dumazet@gmail.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:41023 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750964Ab3AOMWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 07:22:35 -0500
In-Reply-To: <50F4BEB2.2050201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang wrote:
> On 01/15/2013 02:30 AM, David Miller wrote:
>>
>> This is a very incomplete patch.
>>
>> If this change were so simple, it would have been done by someone
>> else a long time ago.
>>
>> You must, in addition to the incredibly obvious changes in the packet
>> output path, completely eliminate the caching of the neighbour entry
>> in the ipv6 routes themselves.
>>
>> This means replacing every rt6->n access or test with something
>> equivalent.
>>
> 
> THanks, David and Eric!
> 
> I knew this is probably incomplete, that is why I added "RFC". Fortunately, YOSHIFUJI just sent a more complete patch:
> 
> [RFC net-next] ipv6 route: Do not attach neighbour on route.
> 
> So, please ignore mine and use his. :)

Well, in fact, it did't work.  Tt really needs further work.

--yoshfuji
