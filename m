From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri10ge: fix indentation
Date: Mon, 24 Nov 2008 14:43:57 -0800 (PST)
Message-ID: <20081124.144357.65741555.davem@davemloft.net>
References: <49295DFD.9050609@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46705
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753493AbYKXWn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 17:43:57 -0500
In-Reply-To: <49295DFD.9050609@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Sun, 23 Nov 2008 14:43:25 +0100

> Bring the indentation in line with the output of the Lindent script.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>

Please don't blindly apply tools like this.

>  static const struct net_device_ops myri10ge_netdev_ops = {
> -	.ndo_open		= myri10ge_open,
> -	.ndo_stop		= myri10ge_close,
> -	.ndo_start_xmit		= myri10ge_xmit,
> -	.ndo_get_stats		= myri10ge_get_stats,
> -	.ndo_validate_addr	= eth_validate_addr,
> -	.ndo_change_mtu		= myri10ge_change_mtu,
> +	.ndo_open = myri10ge_open,
> +	.ndo_stop = myri10ge_close,
> +	.ndo_start_xmit = myri10ge_xmit,
> +	.ndo_get_stats = myri10ge_get_stats,
> +	.ndo_validate_addr = eth_validate_addr,
> +	.ndo_change_mtu = myri10ge_change_mtu,
>  	.ndo_set_multicast_list = myri10ge_set_multicast_list,
> -	.ndo_set_mac_address	= myri10ge_set_mac_address,
> +	.ndo_set_mac_address = myri10ge_set_mac_address,
>  };
>  

I specifically used tabs here when applying this, on the left side of
the equal sign, in order to line everything up nicely.  And now this
patch is undoing that.

Patch not applied.
