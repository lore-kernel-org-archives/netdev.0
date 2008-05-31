From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sfc: Report XAUI link down at default log level
Date: Fri, 30 May 2008 22:13:02 -0400
Message-ID: <4840B42E.4030707@pobox.com>
References: <20080530211835.GE1743@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37118 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752219AbYEaCNE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 22:13:04 -0400
In-Reply-To: <20080530211835.GE1743@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> This is normal when the external link is down so don't report it as an error.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/falcon_xmac.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
> index 264e1ee..37d3cae 100644
> --- a/drivers/net/sfc/falcon_xmac.c
> +++ b/drivers/net/sfc/falcon_xmac.c
> @@ -513,7 +513,7 @@ static int falcon_check_xaui_link_up(struct efx_nic *efx)
>  		tries--;
>  	}
>  
> -	EFX_ERR(efx, "Failed to bring XAUI link back up in %d tries!\n",
> +	EFX_LOG(efx, "Failed to bring XAUI link back up in %d tries!\n",
>  		max_tries);

applied


