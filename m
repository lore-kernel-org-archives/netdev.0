From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] openvswitch: using kfree_rcu() to simplify the code
Date: Fri, 31 Aug 2012 15:57:39 -0400 (EDT)
Message-ID: <20120831.155739.23641263564536162.davem@davemloft.net>
References: <CAPgLHd_71Qh90j9FCkT2cQ35wNMkZeLDwHT2QLP55_3gfzfjTQ@mail.gmail.com>
	<CAEP_g=_9PYpQQbu-1eH7uF-Dk1+LbOfW1GAS6v6=Vu-8hq42yg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: weiyj.lk@gmail.com, yongjun_wei@trendmicro.com.cn,
	dev@openvswitch.org, netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53019 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754932Ab2HaT5l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 15:57:41 -0400
In-Reply-To: <CAEP_g=_9PYpQQbu-1eH7uF-Dk1+LbOfW1GAS6v6=Vu-8hq42yg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Tue, 28 Aug 2012 16:00:24 -0700

> On Sun, Aug 26, 2012 at 9:20 PM, Wei Yongjun <weiyj.lk@gmail.com> wrote:
>> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>>
>> The callback function of call_rcu() just calls a kfree(), so we
>> can use kfree_rcu() instead of call_rcu() + callback function.
>>
>> spatch with a semantic match is used to found this problem.
>> (http://coccinelle.lip6.fr/)
>>
>> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Thanks Wei.
> 
> Acked-by: Jesse Gross <jesse@nicira.com>

Applied to net-next
