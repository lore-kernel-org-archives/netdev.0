From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH] net: less interrupt masking in NAPI
Date: Wed, 3 Dec 2014 17:26:00 +0800
Message-ID: <547ED728.2010703@huawei.com>
References: <1414937973.31792.37.camel@edumazet-glaptop2.roam.corp.google.com>	 <20141103.122538.387451917276174830.davem@davemloft.net>	 <547EBC66.4040301@huawei.com> <1417592482.5303.132.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:39296 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061AbaLCJ1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 04:27:22 -0500
In-Reply-To: <1417592482.5303.132.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/12/3 15:41, Eric Dumazet wrote:
> On Wed, 2014-12-03 at 15:31 +0800, Yang Yingliang wrote:
> 
>> This patch can resolve my performance problem.
>> Will/Can this patch queue for stable ?
> 
> Hmm.. please give us more details, I am surprised it can have
> a big impact.
> 
> 
> 
> 
Before this patch, when a large network flow arrives, some other processes
response slowly or even don't response because the cpu is dealing with softirq.

After this patch, under pressure, much more softirq is doing in ksoftirqd. The other
processes be scheduled.

My system has dual core.

Regards,
Yang
