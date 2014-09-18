From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 1/2] net: cls_u32: fix missed pcpu_success free_percpu
Date: Wed, 17 Sep 2014 18:17:06 -0700
Message-ID: <541A3292.70308@gmail.com>
References: <20140917191131.20529.91136.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f48.google.com ([209.85.219.48]:60601 "EHLO
	mail-oa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753741AbaIRBRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 21:17:20 -0400
Received: by mail-oa0-f48.google.com with SMTP id g18so126379oah.35
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 18:17:19 -0700 (PDT)
In-Reply-To: <20140917191131.20529.91136.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/17/2014 12:11 PM, John Fastabend wrote:
> This fixes a missed free_percpu in the unwind code path and when
> keys are destroyed.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>   net/sched/cls_u32.c |    6 ++++++
>   1 file changed, 6 insertions(+)
>

This patch still misses free'ing pcpu_success in an error path
so I'll address it when I send a v2 to address comments on the
second patch

-- 
John Fastabend         Intel Corporation
