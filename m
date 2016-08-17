From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 12/13] net: sched: add support for TCQ_F_NOLOCK
 subqueues to sch_mq
Date: Wed, 17 Aug 2016 16:04:16 -0700
Message-ID: <1471475056.29842.55.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
	 <20160817193838.27032.29727.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, brouer@redhat.com,
	john.r.fastabend@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36176 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752435AbcHQXES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 19:04:18 -0400
Received: by mail-pa0-f65.google.com with SMTP id ez1so208127pab.3
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 16:04:17 -0700 (PDT)
In-Reply-To: <20160817193838.27032.29727.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-17 at 12:38 -0700, John Fastabend wrote:
> The sch_mq qdisc creates a sub-qdisc per tx queue which are then
> called independently for enqueue and dequeue operations. However
> statistics are aggregated and pushed up to the "master" qdisc.
> 
> This patch adds support for any of the sub-qdiscs to be per cpu
> statistic qdiscs. To handle this case add a check when calculating
> stats and aggregate the per cpu stats if needed.
> 
> Also exports __gnet_stats_copy_queue() to use as a helper function.


Looks like this patch should be happening earlier in the series ?
