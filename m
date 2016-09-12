From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 12 Sep 2016 16:40:45 -0700
Message-ID: <1473723645.18970.109.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473723029-16533-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, john.r.fastabend@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:34657 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752585AbcILXks (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 19:40:48 -0400
Received: by mail-pa0-f65.google.com with SMTP id ph5so2268396pab.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 16:40:48 -0700 (PDT)
In-Reply-To: <1473723029-16533-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-12 at 19:30 -0400, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>

> +
> +static struct tc_action_ops act_skbmod_ops = {
> +	.kind		=	"skbmod",
> +	.type		=	TCA_ACT_SKBMOD,
> +	.owner		=	THIS_MODULE,
> +	.act		=	tcf_skbmod_run,
> +	.dump		=	tcf_skbmod_dump,
> +	.init		=	tcf_skbmod_init,
> +	.walk		=	tcf_skbmod_walker,
> +	.lookup		=	tcf_skbmod_search,
> +	.size		=	sizeof(struct tcf_skbmod),
> +};

Looks like you missed a .cleanup() handler ?

Otherwise, d->skbmod_p wont be freed .
