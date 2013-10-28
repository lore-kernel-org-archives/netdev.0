From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] netfilter: ipvs: ip_vs_sync: Remove unused variable
Date: Mon, 28 Oct 2013 10:04:18 +0900
Message-ID: <20131028010418.GJ849@verge.net.au>
References: <1381180142-3388-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ja@ssi.bg, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:36061 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754833Ab3J1BEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 21:04:21 -0400
Content-Disposition: inline
In-Reply-To: <1381180142-3388-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 07, 2013 at 06:09:02PM -0300, Fabio Estevam wrote:
> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> Variable 'ret' is not used anywhere and it causes the following build warning: 
> 
> net/netfilter/ipvs/ip_vs_sync.c: In function 'sync_thread_master':
> net/netfilter/ipvs/ip_vs_sync.c:1640:8: warning: unused variable 'ret' [-Wunused-variable]
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> ---
>  net/netfilter/ipvs/ip_vs_sync.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index f63c238..d258125 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -1637,7 +1637,7 @@ static int sync_thread_master(void *data)
>  			continue;
>  		}
>  		while (ip_vs_send_sync_msg(tinfo->sock, sb->mesg) < 0) {
> -			int ret = __wait_event_interruptible(*sk_sleep(sk),
> +			__wait_event_interruptible(*sk_sleep(sk),
>  						   sock_writeable(sk) ||
>  						   kthread_should_stop());
>  			if (unlikely(kthread_should_stop()))

Hi Fabio,

this patch does not seem to apply against ipvs-next.
Could you please rework it and repost if you believe it is still needed.
