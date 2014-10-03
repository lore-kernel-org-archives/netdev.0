From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH v1 2/2] net: sched: replace ematch calls to use struct net
Date: Fri, 3 Oct 2014 15:40:04 -0700
Message-ID: <CAHA+R7PWrAk1+ds8SNytf0dABwcSQYqSAvK9dTN44kQqRiq4Rw@mail.gmail.com>
References: <20141003054558.20925.67091.stgit@nitbit.x32>
	<20141003054624.20925.28150.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:56601 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754905AbaJCWkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 18:40:06 -0400
Received: by mail-lb0-f170.google.com with SMTP id u10so1791309lbd.29
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 15:40:04 -0700 (PDT)
In-Reply-To: <20141003054624.20925.28150.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 2, 2014 at 10:46 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> diff --git a/net/sched/cls_basic.c b/net/sched/cls_basic.c
> index 81ddfa6..f37e4fb 100644
> --- a/net/sched/cls_basic.c
> +++ b/net/sched/cls_basic.c
> @@ -32,7 +32,7 @@ struct basic_filter {
>         struct tcf_exts         exts;
>         struct tcf_ematch_tree  ematches;
>         struct tcf_result       res;
> -       struct tcf_proto        *tp;
> +       struct net              *net;
>         struct list_head        link;
>         struct rcu_head         rcu;
>  };

I guess storing this net pointer to struct tcf_ematch_tree is better,
since it is only used by ematch?
