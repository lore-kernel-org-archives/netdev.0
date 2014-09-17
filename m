From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v3] net: sched: cls_u32: rcu can not be last
 node
Date: Wed, 17 Sep 2014 11:51:25 -0700
Message-ID: <1410979885.7106.244.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140917181144.9571.68528.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:52096 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755881AbaIQSv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 14:51:27 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq14so2667544pab.11
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 11:51:26 -0700 (PDT)
In-Reply-To: <20140917181144.9571.68528.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-17 at 11:11 -0700, John Fastabend wrote:
> tc_u32_sel 'sel' in tc_u_knode expects to be the last element in the
> structure and pads the structure with tc_u32_key fields for each key.
> 
>  kzalloc(sizeof(*n) + s->nkeys*sizeof(struct tc_u32_key), GFP_KERNEL)
> 
> CC: Eric Dumazet <edumazet@google.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/cls_u32.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)

Thanks John !

Acked-by: Eric Dumazet <edumazet@google.com>
