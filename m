From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 04/10] net: sched: replace nprio by a bool to
 make the function more readable
Date: Tue, 16 May 2017 08:09:25 -0400
Message-ID: <0553194d-9d76-bb39-4b29-c3c734a6ff44@mojatatu.com>
References: <20170515083857.3615-1-jiri@resnulli.us>
 <20170515083857.3615-5-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com,
        stephen@networkplumber.org, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34483 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751219AbdEPMJ1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 08:09:27 -0400
Received: by mail-io0-f195.google.com with SMTP id 12so14168768iol.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 05:09:27 -0700 (PDT)
In-Reply-To: <20170515083857.3615-5-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-05-15 04:38 AM, Jiri Pirko wrote:

> diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
> index 88ec1a1..0e49e6e 100644
> --- a/net/sched/cls_api.c
> +++ b/net/sched/cls_api.c
> @@ -271,7 +271,7 @@ static int tc_ctl_tfilter(struct sk_buff *skb, struct nlmsghdr *n,
>  	struct tcmsg *t;
>  	u32 protocol;
>  	u32 prio;
> -	u32 nprio;
> +	bool prio_allocate;

prio_allocated? (past tense seems more sensible)

cheers,
jamal
