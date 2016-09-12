From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v5 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 12 Sep 2016 19:56:31 -0400
Message-ID: <99274ae5-4f40-fc08-3d35-9b2fe7f792b5@mojatatu.com>
References: <1473723029-16533-1-git-send-email-jhs@emojatatu.com>
 <1473723645.18970.109.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com, john.r.fastabend@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33429 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750747AbcILX4e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 19:56:34 -0400
Received: by mail-oi0-f66.google.com with SMTP id y2so20584857oie.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 16:56:33 -0700 (PDT)
In-Reply-To: <1473723645.18970.109.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-12 07:40 PM, Eric Dumazet wrote:
> On Mon, 2016-09-12 at 19:30 -0400, Jamal Hadi Salim wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
>> +
>> +static struct tc_action_ops act_skbmod_ops = {
>> +	.kind		=	"skbmod",
>> +	.type		=	TCA_ACT_SKBMOD,
>> +	.owner		=	THIS_MODULE,
>> +	.act		=	tcf_skbmod_run,
>> +	.dump		=	tcf_skbmod_dump,
>> +	.init		=	tcf_skbmod_init,
>> +	.walk		=	tcf_skbmod_walker,
>> +	.lookup		=	tcf_skbmod_search,
>> +	.size		=	sizeof(struct tcf_skbmod),
>> +};
>
> Looks like you missed a .cleanup() handler ?
>
> Otherwise, d->skbmod_p wont be freed .
>
>
>

Yes, I did ;->
Another version coming. Is there a good way to catch
something like this (ala userspace valgrind)?

cheers,
jamal
