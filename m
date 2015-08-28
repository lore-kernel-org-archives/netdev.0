From: Weilong Chen <chenweilong@huawei.com>
Subject: Re: [PATCH net-next] net: Check frag_lists first to prevent data out
 of order
Date: Fri, 28 Aug 2015 13:34:13 +0800
Message-ID: <55DFF2D5.7080102@huawei.com>
References: <1440641561.8932.36.camel@edumazet-glaptop2.roam.corp.google.com>
 <1440642184.8932.37.camel@edumazet-glaptop2.roam.corp.google.com>
 <55DFD70C.2030001@huawei.com>
 <20150827.212639.868701692675372953.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet@gmail.com>, <edumazet@google.com>,
	<alexander.h.duyck@redhat.com>, <willemb@google.com>,
	<hannes@stressinduktion.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:64337 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358AbbH1Feq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 01:34:46 -0400
In-Reply-To: <20150827.212639.868701692675372953.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Weilong Chen <chenweilong@huawei.com>
> Date: Fri, 28 Aug 2015 11:35:40 +0800
>
>> In my test, @to has a fraglist, but skb_tailroom(to) is not 0!
>> The test is about tipc, the function tipc_buf_append will merge 3 skbs
>> to one:
>> packet 1: len = 1420 skb_tailroom = 190
>> packet 2: len = 1420
>> 	packet 2 will be add to 1' fraglist, but not update skb_tailroom
>
> This operation is illegal.
>
> Once there are frags, tailroom is not permitted.
>
> .
>

Agree

Thanks
