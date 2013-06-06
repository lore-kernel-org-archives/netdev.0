From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net-next] net_sched: psched_ratecfg_precompute() improvements
Date: Thu, 06 Jun 2013 13:37:55 -0700
Message-ID: <51B0F323.5010003@candelatech.com>
References: <1370550451.24311.371.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36806 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340Ab3FFUh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jun 2013 16:37:58 -0400
In-Reply-To: <1370550451.24311.371.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2013 01:27 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Before allowing 64bits bytes rates, refactor
> psched_ratecfg_precompute() to get better comments
> and increased accuracy.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>   include/net/sch_generic.h |    4 +--
>   net/sched/sch_generic.c   |   42 ++++++++++++++++--------------------
>   2 files changed, 21 insertions(+), 25 deletions(-)
>
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index e7f4e21..e788397 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -679,7 +679,7 @@ static inline struct sk_buff *skb_act_clone(struct sk_buff *skb, gfp_t gfp_mask,
>   #endif
>
>   struct psched_ratecfg {
> -	u64	rate_bps;
> +	u64	rate_bps; /* bytes per second */

Seems like rate_bytes_ps would be better..rate_bps is going to
be easily confused with bits-per-second...

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
