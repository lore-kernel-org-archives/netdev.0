From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 12/13] net: sched: add support for TCQ_F_NOLOCK
 subqueues to sch_mq
Date: Wed, 17 Aug 2016 16:18:36 -0700
Message-ID: <57B4F0CC.9020102@gmail.com>
References: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
 <20160817193838.27032.29727.stgit@john-Precision-Tower-5810>
 <1471475056.29842.55.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, brouer@redhat.com,
	john.r.fastabend@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35995 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752761AbcHQXSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 19:18:50 -0400
Received: by mail-pf0-f194.google.com with SMTP id y134so244822pfg.3
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 16:18:49 -0700 (PDT)
In-Reply-To: <1471475056.29842.55.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-17 04:04 PM, Eric Dumazet wrote:
> On Wed, 2016-08-17 at 12:38 -0700, John Fastabend wrote:
>> The sch_mq qdisc creates a sub-qdisc per tx queue which are then
>> called independently for enqueue and dequeue operations. However
>> statistics are aggregated and pushed up to the "master" qdisc.
>>
>> This patch adds support for any of the sub-qdiscs to be per cpu
>> statistic qdiscs. To handle this case add a check when calculating
>> stats and aggregate the per cpu stats if needed.
>>
>> Also exports __gnet_stats_copy_queue() to use as a helper function.
> 
> 
> Looks like this patch should be happening earlier in the series ?
> 
> 

hmm yep patches 12 and 13 should come before 11 to avoid introducing
a bug and subsequently fixing them.
