From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC Patch net-next 2/6] net_sched: introduce tcf_hash_replace()
Date: Tue, 6 Sep 2016 08:52:24 -0400
Message-ID: <9b288d0c-507f-d487-aa76-0778fd442f35@mojatatu.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472795840-31901-3-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33342 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933133AbcIFMw0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 08:52:26 -0400
Received: by mail-oi0-f66.google.com with SMTP id w78so8742695oie.0
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 05:52:25 -0700 (PDT)
In-Reply-To: <1472795840-31901-3-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-02 01:57 AM, Cong Wang wrote:

> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  include/net/act_api.h |  2 ++
>  net/sched/act_api.c   | 20 ++++++++++++++++++++
>  2 files changed, 22 insertions(+)
>
> diff --git a/include/net/act_api.h b/include/net/act_api.h
> index 82f3c91..a374bab 100644
> --- a/include/net/act_api.h

>
> +void tcf_hash_replace(struct tc_action_net *tn, struct tc_action **old,
> +		      struct tc_action *new, int bind)
> +{
> +	struct tcf_hashinfo *hinfo = tn->hinfo;
> +	unsigned int h = tcf_hash(new->tcfa_index, hinfo->hmask);
> +

WWhy do you need to recreate the index?
Old index was fine since this is just a replacement..

The rest of the patches seem fine - will let Eric comment on the
mirred.

Note: I am going to still push forward with skbmod action and I think
so should the new tunnel action code i.e we make them independent.
I'd like to switch to this when we think it is stable.

cheers,
jamal
