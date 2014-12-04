From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH] net: less interrupt masking in NAPI
Date: Thu, 4 Dec 2014 10:10:41 +0800
Message-ID: <547FC2A1.60105@huawei.com>
References: <1414937973.31792.37.camel@edumazet-glaptop2.roam.corp.google.com>	 <20141103.122538.387451917276174830.davem@davemloft.net>	 <547EBC66.4040301@huawei.com>	 <1417592482.5303.132.camel@edumazet-glaptop2.roam.corp.google.com>	 <547ED728.2010703@huawei.com> <1417607546.5303.133.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:38579 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093AbaLDCKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 21:10:53 -0500
In-Reply-To: <1417607546.5303.133.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/12/3 19:52, Eric Dumazet wrote:
> On Wed, 2014-12-03 at 17:26 +0800, Yang Yingliang wrote:
> 
>> Before this patch, when a large network flow arrives, some other processes
>> response slowly or even don't response because the cpu is dealing with softirq.
>>
>> After this patch, under pressure, much more softirq is doing in ksoftirqd. The other
>> processes be scheduled.
>>
>> My system has dual core.
> 
> Which NIC driver are you using ?
> 
The driver we developed ourself, it's not upstreamed.
