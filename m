From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [patch 1/1] ixp4xx_eth: fix ptp_ixp46x build failure
Date: Mon, 6 Aug 2012 08:23:22 +0200
Message-ID: <20120806062321.GA2189@netboy.at.omicron.at>
References: <20120805203042.509148064@rtp-net.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Krzysztof Halasa <khc@pm.waw.pl>
To: Arnaud Patard <arnaud.patard@rtp-net.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:56908 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446Ab2HFGXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 02:23:32 -0400
Received: by wgbfm10 with SMTP id fm10so1165964wgb.1
        for <netdev@vger.kernel.org>; Sun, 05 Aug 2012 23:23:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120805203042.509148064@rtp-net.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 05, 2012 at 10:30:11PM +0200, Arnaud Patard wrote:
> When building with ixp4xx_eth and ptp_ixp46x as module, one is getting the
> following error:
> 
> ERROR: "ixp46x_phc_index" [drivers/ptp/ptp_ixp46x.ko] undefined!
> 
> This has been introduced by commit 509a7c25729feab353502e1b544c614772a1d49a.

Thanks for patching this.

Acked-by: Richard Cochran <richardcochran@gmail.com>
 
> Signed-off-by: Arnaud Patard <arnaud.patard@rtp-net.org>
> Index: efika/drivers/net/ethernet/xscale/ixp4xx_eth.c
> ===================================================================
> --- efika.orig/drivers/net/ethernet/xscale/ixp4xx_eth.c	2012-07-29 14:03:12.710197591 +0200
> +++ efika/drivers/net/ethernet/xscale/ixp4xx_eth.c	2012-08-05 11:13:13.188037295 +0200
> @@ -1003,6 +1003,7 @@ static int ixp4xx_nway_reset(struct net_
>  }
>  
>  int ixp46x_phc_index = -1;
> +EXPORT_SYMBOL_GPL(ixp46x_phc_index);
>  
>  static int ixp4xx_get_ts_info(struct net_device *dev,
>  			      struct ethtool_ts_info *info)
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
