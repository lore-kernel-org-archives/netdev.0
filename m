From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 3/7] htb: remove pointless first initialization
 of buffer and cbuffer
Date: Fri, 08 Feb 2013 08:35:14 -0800
Message-ID: <1360341314.28557.99.camel@edumazet-glaptop>
References: <1360328327-7144-1-git-send-email-jiri@resnulli.us>
	 <1360328327-7144-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:57295 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946533Ab3BHQfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 11:35:18 -0500
Received: by mail-pa0-f54.google.com with SMTP id fa10so2188796pad.41
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 08:35:17 -0800 (PST)
In-Reply-To: <1360328327-7144-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-08 at 13:58 +0100, Jiri Pirko wrote:
> these are initialized correctly couple of lines later in the function.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/sched/sch_htb.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 14a83dc..547912e9 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -1503,9 +1503,6 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
>  			cl->prio = TC_HTB_NUMPRIO - 1;
>  	}
>  
> -	cl->buffer = hopt->buffer;
> -	cl->cbuffer = hopt->cbuffer;
> -
>  	cl->rate.rate_bps = (u64)hopt->rate.rate << 3;
>  	cl->ceil.rate_bps = (u64)hopt->ceil.rate << 3;
>  

Acked-by: Eric Dumazet <edumazet@google.com>
