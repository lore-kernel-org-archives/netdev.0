From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [PATCH] IB/mlx5_core: remove unreachable function call in module
 init
Date: Sun, 9 Mar 2014 08:37:46 +0200
Message-ID: <20140309063746.GF20224@mtldesk30>
References: <1394232505-12142-1-git-send-email-klebers@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eli Cohen <eli@mellanox.com>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org
To: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:48781 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbaCIGhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 01:37:50 -0500
Received: by mail-we0-f175.google.com with SMTP id q58so7011487wes.20
        for <netdev@vger.kernel.org>; Sat, 08 Mar 2014 22:37:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1394232505-12142-1-git-send-email-klebers@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Eli Cohen <eli@mellanox.com>

On Fri, Mar 07, 2014 at 07:48:25PM -0300, Kleber Sacilotto de Souza wrote:
> The call to mlx5_health_cleanup() in the module init function can never
> be reached. Removing it.
> 
> Signed-off-by: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/main.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
> index 6f7c866..77ac95f 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
> @@ -531,7 +531,6 @@ static int __init init(void)
>  
>  	return 0;
>  
> -	mlx5_health_cleanup();
>  err_debug:
>  	mlx5_unregister_debugfs();
>  	return err;
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
