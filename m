From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V1 4/4] net/mlx5e: Add PTP Hardware Clock (PHC)
 support
Date: Thu, 17 Dec 2015 21:20:50 +0100
Message-ID: <20151217202050.GC5975@localhost.localdomain>
References: <1450355735-30846-1-git-send-email-saeedm@mellanox.com>
 <1450355735-30846-5-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36492 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755018AbbLQUU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 15:20:56 -0500
Received: by mail-wm0-f45.google.com with SMTP id p187so36980853wmp.1
        for <netdev@vger.kernel.org>; Thu, 17 Dec 2015 12:20:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1450355735-30846-5-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2015 at 02:35:35PM +0200, Saeed Mahameed wrote:
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> index 8e86f2c..b2e5014 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
> @@ -880,6 +880,9 @@ static int mlx5e_get_ts_info(struct net_device *dev,
>  				(1 << HWTSTAMP_FILTER_ALL);
>  	}
>  
> +	if (priv->tstamp.ptp)
> +		info->phc_index = ptp_clock_index(priv->tstamp.ptp);
	else
		info->phc_index = -1;

Thanks,
Richard
