From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] tcp_westwood: fix tcp_westwood_info() style mistakes
Date: Tue, 14 Mar 2017 09:29:34 -0700
Message-ID: <20170314092934.791228ca@xeon-e3>
References: <1489476384-16892-1-git-send-email-long.chun@zte.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        zhong.weidong@zte.com.cn, wang.liang82@zte.com.cn,
        jiang.biao2@zte.com.cn, cai.qu@zte.com.cn
To: Chun Long <long.chun@zte.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34856 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751180AbdCNQ3n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 12:29:43 -0400
Received: by mail-pg0-f42.google.com with SMTP id b129so93264909pgc.2
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 09:29:42 -0700 (PDT)
In-Reply-To: <1489476384-16892-1-git-send-email-long.chun@zte.com.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Mar 2017 15:26:24 +0800
Chun Long <long.chun@zte.com.cn> wrote:

> From: chun Long <long.chun@zte.com.cn>
> 
> replace comma to semi colons in tcp_westwood_info().
> 
> ---
>  net/ipv4/tcp_westwood.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
> index fed66dc..9775453 100644
> --- a/net/ipv4/tcp_westwood.c
> +++ b/net/ipv4/tcp_westwood.c
> @@ -265,8 +265,8 @@ static size_t tcp_westwood_info(struct sock *sk, u32 ext, int *attr,
>  	if (ext & (1 << (INET_DIAG_VEGASINFO - 1))) {
>  		info->vegas.tcpv_enabled = 1;
>  		info->vegas.tcpv_rttcnt	= 0;
> -		info->vegas.tcpv_rtt	= jiffies_to_usecs(ca->rtt),
> -		info->vegas.tcpv_minrtt	= jiffies_to_usecs(ca->rtt_min),
> +		info->vegas.tcpv_rtt	= jiffies_to_usecs(ca->rtt);
> +		info->vegas.tcpv_minrtt	= jiffies_to_usecs(ca->rtt_min);
>  
>  		*attr = INET_DIAG_VEGASINFO;
>  		return sizeof(struct tcpvegas_info);

Look fine.

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
