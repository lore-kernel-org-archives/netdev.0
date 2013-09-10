From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] sfc: Staticize efx_ethtool_get_ts_info
Date: Tue, 10 Sep 2013 13:08:11 +0100
Message-ID: <1378814891.32513.29.camel@deadeye.wl.decadent.org.uk>
References: <1378806210-12155-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: Sachin Kamat <sachin.kamat@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41427 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207Ab3IJMIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 08:08:18 -0400
In-Reply-To: <1378806210-12155-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-10 at 15:13 +0530, Sachin Kamat wrote:
> 'efx_ethtool_get_ts_info' is used only in this file.
> Make it static.
> 
> Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
> ---
>  drivers/net/ethernet/sfc/ethtool.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
> index 5b471cf..c8dc407 100644
> --- a/drivers/net/ethernet/sfc/ethtool.c
> +++ b/drivers/net/ethernet/sfc/ethtool.c
> @@ -1035,8 +1035,8 @@ static int efx_ethtool_set_rxfh_indir(struct net_device *net_dev,
>  	return 0;
>  }
>  
> -int efx_ethtool_get_ts_info(struct net_device *net_dev,
> -			    struct ethtool_ts_info *ts_info)
> +static int efx_ethtool_get_ts_info(struct net_device *net_dev,
> +				   struct ethtool_ts_info *ts_info)
>  {
>  	struct efx_nic *efx = netdev_priv(net_dev);
>  

I already have this fix, but net-next is not open for changes.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
