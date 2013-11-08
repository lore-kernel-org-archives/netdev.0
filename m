From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] net_sched: tbf: support of 64bit rates
Date: Thu, 07 Nov 2013 18:34:20 -0800
Message-ID: <1383878060.9412.146.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383877414-9488-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jhs@mojatatu.com,
	sergei.shtylyov@cogentembedded.com
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:65414 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756328Ab3KHCfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 21:35:17 -0500
Received: by mail-pb0-f42.google.com with SMTP id jt11so1494636pbb.29
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 18:35:17 -0800 (PST)
In-Reply-To: <1383877414-9488-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 10:23 +0800, Yang Yingliang wrote:
> With psched_ratecfg_precompute(), tbf can deal with 64bit rates.
> Add two new attributes so that tc can use them to break the 32bit
> limit.
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> Suggested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> ---
>  include/uapi/linux/pkt_sched.h |  2 ++
>  net/sched/sch_tbf.c            | 22 ++++++++++++++++++----
>  2 files changed, 20 insertions(+), 4 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
