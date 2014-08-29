From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next] tcp: whitespace fixes
Date: Fri, 29 Aug 2014 05:27:04 -0700
Message-ID: <CAL3LdT78uED7mqzYYbUvNyw3d100ehzBfrcCNFnExmFCV6G88g@mail.gmail.com>
References: <20140829000646.0647e9c5@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:62985 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608AbaH2M1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 08:27:05 -0400
Received: by mail-oi0-f42.google.com with SMTP id v63so1550622oia.1
        for <netdev@vger.kernel.org>; Fri, 29 Aug 2014 05:27:04 -0700 (PDT)
In-Reply-To: <20140829000646.0647e9c5@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 29, 2014 at 12:06 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> Fix places where there is space before tab, long lines, and
> awkward if(){.
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>
>
> --- a/net/ipv4/tcp_bic.c        2014-05-05 23:44:19.000000000 -0700
> +++ b/net/ipv4/tcp_bic.c        2014-08-22 17:17:51.448069718 -0700
> @@ -50,7 +50,7 @@ MODULE_PARM_DESC(smooth_part, "log(B/(B*
>  /* BIC TCP Parameters */
>  struct bictcp {
>         u32     cnt;            /* increase cwnd by 1 after ACKs */
> -       u32     last_max_cwnd;  /* last maximum snd_cwnd */
> +       u32     last_max_cwnd;  /* last maximum snd_cwnd */
>         u32     loss_cwnd;      /* congestion window at last loss */
>         u32     last_cwnd;      /* the last snd_cwnd */
>         u32     last_time;      /* time when updated last_cwnd */
> @@ -103,7 +103,7 @@ static inline void bictcp_update(struct
>
>         /* binary increase */
>         if (cwnd < ca->last_max_cwnd) {
> -               __u32   dist = (ca->last_max_cwnd - cwnd)
> +               __u32   dist = (ca->last_max_cwnd - cwnd)
>                         / BICTCP_B;
>
>                 if (dist > max_increment)
> --- a/net/ipv4/tcp_cubic.c      2014-06-16 14:48:29.000000000 -0700
> +++ b/net/ipv4/tcp_cubic.c      2014-08-22 17:20:10.368073438 -0700
> @@ -82,7 +82,7 @@ MODULE_PARM_DESC(hystart_ack_delta, "spa
>  /* BIC TCP Parameters */
>  struct bictcp {
>         u32     cnt;            /* increase cwnd by 1 after ACKs */
> -       u32     last_max_cwnd;  /* last maximum snd_cwnd */
> +       u32     last_max_cwnd;  /* last maximum snd_cwnd */
>         u32     loss_cwnd;      /* congestion window at last loss */
>         u32     last_cwnd;      /* the last snd_cwnd */
>         u32     last_time;      /* time when updated last_cwnd */
> @@ -263,9 +263,9 @@ static inline void bictcp_update(struct
>
>         /* c/rtt * (t-K)^3 */
>         delta = (cube_rtt_scale * offs * offs * offs) >> (10+3*BICTCP_HZ);
> -       if (t < ca->bic_K)                                      /* below origin*/
> +       if (t < ca->bic_K)                            /* below origin*/
>                 bic_target = ca->bic_origin_point - delta;
> -       else                                                    /* above origin*/
> +       else                                          /* above origin*/
>                 bic_target = ca->bic_origin_point + delta;
>
>         /* cubic function - calc bictcp_cnt*/
> @@ -291,7 +291,7 @@ static inline void bictcp_update(struct
>                         ca->tcp_cwnd++;
>                 }
>
> -               if (ca->tcp_cwnd > cwnd){       /* if bic is slower than tcp */
> +               if (ca->tcp_cwnd > cwnd) {      /* if bic is slower than tcp */
>                         delta = ca->tcp_cwnd - cwnd;
>                         max_cnt = cwnd / delta;
>                         if (ca->cnt > max_cnt)
> @@ -452,7 +452,7 @@ static int __init cubictcp_register(void
>          * based on SRTT of 100ms
>          */
>
> -       beta_scale = 8*(BICTCP_BETA_SCALE+beta)/ 3 / (BICTCP_BETA_SCALE - beta);
> +       beta_scale = 8*(BICTCP_BETA_SCALE+beta) / 3 / (BICTCP_BETA_SCALE - beta);

Since you are fixing up the line, shouldn't it be:
        beta_scale = 8 * (BICTCP_BETA_SCALE + beta) / 3 /
(BICTCP_BETA_SCALE - beta);

>
>         cube_rtt_scale = (bic_scale * 10);      /* 1024*c/rtt */
>
> --- a/net/ipv4/tcp_yeah.c       2014-05-05 23:44:19.000000000 -0700
> +++ b/net/ipv4/tcp_yeah.c       2014-08-22 17:15:47.788066407 -0700
> @@ -84,7 +84,7 @@ static void tcp_yeah_cong_avoid(struct s
>                 /* Scalable */
>
>                 tp->snd_cwnd_cnt += yeah->pkts_acked;
> -               if (tp->snd_cwnd_cnt > min(tp->snd_cwnd, TCP_SCALABLE_AI_CNT)){
> +               if (tp->snd_cwnd_cnt > min(tp->snd_cwnd, TCP_SCALABLE_AI_CNT)) {
>                         if (tp->snd_cwnd < tp->snd_cwnd_clamp)
>                                 tp->snd_cwnd++;
>                         tp->snd_cwnd_cnt = 0;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Cheers,
Jeff
