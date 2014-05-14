From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH net-next] dccp: make the request_retries minimum is 1
Date: Wed, 14 May 2014 04:01:14 -0600
Message-ID: <20140514040120.31c13b73@199-7-159-29.eng.wind.ca>
References: <53718A36.1040907@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <dccp@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spey.erg.abdn.ac.uk ([139.133.204.173]:38088 "EHLO
	spey.erg.abdn.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbaENKdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 06:33:32 -0400
In-Reply-To: <53718A36.1040907@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>


> ---
>  net/dccp/sysctl.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/dccp/sysctl.c b/net/dccp/sysctl.c
> index 607ab71..53731e4 100644
> --- a/net/dccp/sysctl.c
> +++ b/net/dccp/sysctl.c
> @@ -20,6 +20,7 @@
>  
>  /* Boundary values */
>  static int		zero     = 0,
> +			one      = 1,
>  			u8_max   = 0xFF;
>  static unsigned long	seqw_min = DCCPF_SEQ_WMIN,
>  			seqw_max = 0xFFFFFFFF;		/* maximum on 32 bit */
> @@ -58,7 +59,7 @@ static struct ctl_table dccp_default_table[] = {
>  		.maxlen		= sizeof(sysctl_dccp_request_retries),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_minmax,
> -		.extra1		= &zero,
> +		.extra1		= &one,
>  		.extra2		= &u8_max,
>  	},
>  	{
