From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [patch net-next] ethtool: consolidate work with ethtool_ops
Date: Mon, 7 Jan 2013 17:19:19 +0100
Message-ID: <20130107161919.GB5715@netboy.at.omicron.at>
References: <1357561574-14255-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, greearb@candelatech.com,
	jeffrey.t.kirsher@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:53319 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214Ab3AGQ1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 11:27:23 -0500
Received: by mail-we0-f177.google.com with SMTP id x48so10070611wey.8
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 08:27:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1357561574-14255-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 07, 2013 at 01:26:14PM +0100, Jiri Pirko wrote:
> @@ -1346,13 +1347,9 @@ static int ethtool_get_ts_info(struct net_device *dev, void __user *useraddr)
>  	info.cmd = ETHTOOL_GET_TS_INFO;
>  
>  	if (phydev && phydev->drv && phydev->drv->ts_info) {
> -
>  		err = phydev->drv->ts_info(phydev, &info);
> -
> -	} else if (dev->ethtool_ops && dev->ethtool_ops->get_ts_info) {
> -
> +	} else if (ops->get_ts_info) {
>  		err = ops->get_ts_info(dev, &info);
> -
>  	} else {
>  		info.so_timestamping =
>  			SOF_TIMESTAMPING_RX_SOFTWARE |

Acked-by: Richard Cochran <richardcochran@gmail.com>
