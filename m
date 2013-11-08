From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net_sched: tbf: support of 64bit rates
Date: Fri, 08 Nov 2013 02:38:07 -0500 (EST)
Message-ID: <20131108.023807.1825323531703609771.davem@davemloft.net>
References: <1383877414-9488-1-git-send-email-yangyingliang@huawei.com>
	<1383878060.9412.146.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yangyingliang@huawei.com, netdev@vger.kernel.org, jhs@mojatatu.com,
	sergei.shtylyov@cogentembedded.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59396 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547Ab3KHHiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 02:38:10 -0500
In-Reply-To: <1383878060.9412.146.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Nov 2013 18:34:20 -0800

> On Fri, 2013-11-08 at 10:23 +0800, Yang Yingliang wrote:
>> With psched_ratecfg_precompute(), tbf can deal with 64bit rates.
>> Add two new attributes so that tc can use them to break the 32bit
>> limit.
>> 
>> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
>> Suggested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>> ---
>>  include/uapi/linux/pkt_sched.h |  2 ++
>>  net/sched/sch_tbf.c            | 22 ++++++++++++++++++----
>>  2 files changed, 20 insertions(+), 4 deletions(-)
> 
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
