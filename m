From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH 2/2] netdev: docbook comment update
Date: Tue, 23 Sep 2008 09:19:36 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809230917020.27041@shark.he.net>
References: <20080923083750.59eaac97@extreme> <20080923091035.102d4106@extreme>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Randy.Dunlap" <rdunlap@xenotime.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:33518 "HELO xenotime.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751550AbYIWQTp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 12:19:45 -0400
Received: from shark.he.net ([66.160.160.2]) by xenotime.net for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 09:19:36 -0700
In-Reply-To: <20080923091035.102d4106@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Sep 2008, Stephen Hemminger wrote:

> Add more docbook comments to network device functions and cleanup
> the comments.

Thanks!

> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> --- a/net/core/dev.c	2008-09-23 08:32:48.000000000 -0700
> +++ b/net/core/dev.c	2008-09-23 08:36:09.000000000 -0700
> @@ -3322,6 +3323,12 @@ static void dev_addr_discard(struct net_
>  	netif_addr_unlock_bh(dev);
>  }
>  
> +/**
> + *	dev_get_flags - get flags reported to userspace
> + *	@dev: device
> + *
> + *	Get the combination of flag bits exported throug API's to userspace.

                                                  through
and preferably                                            APIs


> + */
>  unsigned dev_get_flags(const struct net_device *dev)
>  {
>  	unsigned flags;
> @@ -3439,6 +3461,13 @@ int dev_set_mtu(struct net_device *dev, 
>  	return err;
>  }
>  
> +/**
> + *	dev_set_mtu - Change Media Access Control Address

Wrong func name.

> + *	@dev: device
> + *	@sa: new address
> + *
> + *	Change the hardware (MAC) address of the device
> + */
>  int dev_set_mac_address(struct net_device *dev, struct sockaddr *sa)
>  {
>  	int err;

cya,
-- 
~Randy
