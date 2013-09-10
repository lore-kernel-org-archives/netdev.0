From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] sfc: Staticize efx_ef10_filter_update_rx_scatter
Date: Tue, 10 Sep 2013 13:08:43 +0100
Message-ID: <1378814923.32513.30.camel@deadeye.wl.decadent.org.uk>
References: <1378806567-30625-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: Sachin Kamat <sachin.kamat@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41440 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207Ab3IJMIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 08:08:47 -0400
In-Reply-To: <1378806567-30625-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-10 at 15:19 +0530, Sachin Kamat wrote:
> 'efx_ef10_filter_update_rx_scatter' is used only in this file.
> Make it static.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
> ---
>  drivers/net/ethernet/sfc/ef10.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
> index 5f42313..6956bd2 100644
> --- a/drivers/net/ethernet/sfc/ef10.c
> +++ b/drivers/net/ethernet/sfc/ef10.c
> @@ -2121,7 +2121,7 @@ out_unlock:
>  	return rc;
>  }
>  
> -void efx_ef10_filter_update_rx_scatter(struct efx_nic *efx)
> +static void efx_ef10_filter_update_rx_scatter(struct efx_nic *efx)
>  {
>  	/* no need to do anything here on EF10 */
>  }

Same for this.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
