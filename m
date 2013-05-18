From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 5/5] drivers: net: usb: rtl8150: bug fixing and cleanup
Date: Sat, 18 May 2013 23:10:41 +0200
Message-ID: <20130518211041.GD26590@electric-eye.fr.zoreil.com>
References: <alpine.DEB.2.02.1305181905490.7518@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42248 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753319Ab3ERVKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 May 2013 17:10:46 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1305181905490.7518@fry.nucleusys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Petko Manolov <petkan@nucleusys.com> :
[...]
> @@ -681,16 +681,15 @@ static int rtl8150_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
>  }
>  
>  static const struct net_device_ops rtl8150_netdev_ops = {
> -	.ndo_open		= rtl8150_open,
> -	.ndo_stop		= rtl8150_close,
> -	.ndo_do_ioctl		= rtl8150_ioctl,
> -	.ndo_start_xmit		= rtl8150_start_xmit,
> -	.ndo_tx_timeout		= rtl8150_tx_timeout,
> -	.ndo_set_rx_mode	= rtl8150_set_multicast,
> -	.ndo_set_mac_address	= rtl8150_set_mac_address,
> -
> -	.ndo_change_mtu		= eth_change_mtu,
> -	.ndo_validate_addr	= eth_validate_addr,
> +	.ndo_open = rtl8150_open,
> +	.ndo_stop = rtl8150_close,
> +	.ndo_do_ioctl = rtl8150_ioctl,
> +	.ndo_start_xmit = rtl8150_start_xmit,
> +	.ndo_tx_timeout = rtl8150_tx_timeout,
> +	.ndo_set_rx_mode = rtl8150_set_multicast,
> +	.ndo_set_mac_address = rtl8150_set_mac_address,
> +	.ndo_change_mtu	= eth_change_mtu,
> +	.ndo_validate_addr = eth_validate_addr,

This is wrong.

> @@ -771,12 +770,12 @@ static void rtl8150_disconnect(struct usb_interface *intf)
>  }
>  
>  static struct usb_driver rtl8150_driver = {
> -	.name		= driver_name,
> -	.probe		= rtl8150_probe,
> -	.disconnect	= rtl8150_disconnect,
> -	.id_table	= rtl8150_table,
> -	.suspend	= rtl8150_suspend,
> -	.resume		= rtl8150_resume,
> +	.name = driver_name,
> +	.probe = rtl8150_probe,
> +	.disconnect = rtl8150_disconnect,
> +	.id_table = rtl8150_table,
> +	.suspend = rtl8150_suspend,
> +	.resume = rtl8150_resume,
>  	.disable_hub_initiated_lpm = 1,

Sic.

-- 
Ueimor
