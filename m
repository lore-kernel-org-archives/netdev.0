From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v2 1/2] net: cls_u32: fix missed pcpu_success
 free_percpu
Date: Sat, 20 Sep 2014 18:18:29 -0700
Message-ID: <1411262309.26859.109.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140920045003.9869.16851.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:56558 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbaIUBSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 21:18:31 -0400
Received: by mail-pd0-f172.google.com with SMTP id y10so2242085pdj.3
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 18:18:30 -0700 (PDT)
In-Reply-To: <20140920045003.9869.16851.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-19 at 21:50 -0700, John Fastabend wrote:
> This fixes a missed free_percpu in the unwind code path and when
> keys are destroyed.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/cls_u32.c |   13 +++++++++++++
>  1 file changed, 13 insertions(+)

Acked-by: Eric Dumazet <edumazet@google.com>
