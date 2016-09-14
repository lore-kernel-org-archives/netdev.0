From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v2 net 1/1] net sched actions: fix GETing actions
Date: Wed, 14 Sep 2016 09:32:03 -0700
Message-ID: <CAM_iQpW5iW3vHCOKuRD+UCrGEvBMNz1zHGvPZJgvFumvmto9=g@mail.gmail.com>
References: <1473675692-8490-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35827 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759605AbcINQcY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 12:32:24 -0400
Received: by mail-it0-f67.google.com with SMTP id e20so2003733itc.2
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 09:32:23 -0700 (PDT)
In-Reply-To: <1473675692-8490-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 12, 2016 at 3:21 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> With the batch changes that translated transient actions into
> a temporary list we lost in the translation the fact that
> tcf_action_destroy() will eventually delete the action from
> the permanent location if the refcount is zero.
>
> Example of what broke:
> ...add a gact action to drop
> sudo $TC actions add action drop index 10
> ...now retrieve it, looks good
> sudo $TC actions get action gact index 10
> ...retrieve it again and find it is gone!
> sudo $TC actions get action gact index 10
>
> Fixes:
> 22dc13c837c3 ("net_sched: convert tcf_exts from list to pointer array"),
> 824a7e8863b3 ("net_sched: remove an unnecessary list_del()")
> f07fed82ad79 ("net_sched: remove the leftover cleanup_a()")
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Maybe the changelog/comment needs slightly improved,
but that is a very minor issue. So,

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
