From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/13] net_sched: misc cleanups and improvements
Date: Tue, 04 Nov 2014 14:56:18 -0500 (EST)
Message-ID: <20141104.145618.511225947658504800.davem@davemloft.net>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
	<1415125250.25370.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org, jhs@mojatatu.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58700 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303AbaKDT4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 14:56:21 -0500
In-Reply-To: <1415125250.25370.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 04 Nov 2014 10:20:50 -0800

> On Tue, 2014-11-04 at 09:56 -0800, Cong Wang wrote:
>> Minor code cleanups for TC qdiscs and filters, each patch has
>> more details.
>> 
>> Cong Wang (13):
>>       net_sched: refactor out tcf_exts
>>       net_sched: introduce qdisc_peek() helper function
>>       net_sched: rename ->gso_skb to ->dequeued_skb
>>       net_sched: rename qdisc_drop() to qdisc_drop_skb()
>>       net_sched: introduce qdisc_drop() helper function
>>       net_sched: move some qdisc flag into qdisc ops
>>       net_sched: move TCQ_F_MQROOT into qdisc ops
>>       net_sched: use a flag to indicate fifo qdiscs instead of the name
>>       net_sched: redefine qdisc_create_dflt()
>>       net_sched: forbid setting default qdisc to inappropriate ones
>>       net_sched: remove hashmask from Qdisc_class_hash
>>       net_sched: remove useless qdisc_stab_lock
>>       net_sched: return NULL instead of ERR_PTR for qdisc_alloc()
>> 
> 
> NACK for the whole serie.
> 
> I am tired of your inexistent changelogs and code churn in qdisc.
> 
> If you do not care of writing good changelogs and explain why you want
> all this, why should I care spending time to review all this stuff ?
> 
> What is the plan, beyond all this code churn ?

+1
