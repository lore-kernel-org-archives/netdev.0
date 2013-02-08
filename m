From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [patch net-next 1/7] htb: use PSCHED_TICKS2NS()
Date: Fri, 08 Feb 2013 07:51:21 -0800
Message-ID: <1360338681.28557.96.camel@edumazet-glaptop>
References: <1360328327-7144-1-git-send-email-jiri@resnulli.us>
	 <1360328327-7144-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:40969 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946635Ab3BHPv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 10:51:26 -0500
Received: by mail-ie0-f182.google.com with SMTP id k14so5187975iea.41
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 07:51:26 -0800 (PST)
In-Reply-To: <1360328327-7144-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-08 at 13:58 +0100, Jiri Pirko wrote:
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/sched/sch_htb.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 51561ea..476992c 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -1512,8 +1512,8 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
>  	htb_precompute_ratedata(&cl->rate);
>  	htb_precompute_ratedata(&cl->ceil);
>  
> -	cl->buffer = hopt->buffer << PSCHED_SHIFT;
> -	cl->cbuffer = hopt->buffer << PSCHED_SHIFT;
> +	cl->buffer = PSCHED_TICKS2NS(hopt->buffer);
> +	cl->cbuffer = PSCHED_TICKS2NS(hopt->buffer);
>  
>  	sch_tree_unlock(sch);
>  

Acked-by: Eric Dumazet <edumazet@google.com>
