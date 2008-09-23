From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH 2/2] netdev: docbook comment update (revised)
Date: Tue, 23 Sep 2008 10:12:04 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809231010280.27041@shark.he.net>
References: <20080923083750.59eaac97@extreme> <20080923091035.102d4106@extreme>
 <Pine.LNX.4.64.0809230917020.27041@shark.he.net> <20080923100240.5168d861@extreme>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Randy.Dunlap" <rdunlap@xenotime.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:53305 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751216AbYIWRMK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 13:12:10 -0400
Received: from shark.he.net ([66.160.160.2]) by xenotime.net for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 10:12:04 -0700
In-Reply-To: <20080923100240.5168d861@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Sep 2008, Stephen Hemminger wrote:

> Add more docbook comments to network device functions and cleanup
> the comments.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> --- a/net/core/dev.c	2008-09-23 08:32:48.000000000 -0700
> +++ b/net/core/dev.c	2008-09-23 10:00:10.000000000 -0700
> @@ -3322,6 +3323,12 @@ static void dev_addr_discard(struct net_
>  	netif_addr_unlock_bh(dev);
>  }
>  
> +/**
> + *	dev_get_flags - get flags reported to userspace
> + *	@dev: device
> + *
> + *	Get the combination of flag bits exported throug APIs to userspace.


still needs:                                      through

> + */
>  unsigned dev_get_flags(const struct net_device *dev)
>  {
>  	unsigned flags;

-- 
~Randy
