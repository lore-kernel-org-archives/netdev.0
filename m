From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 5/5] drivers: net: usb: rtl8150: making the code a bit
 better looking
Date: Mon, 20 May 2013 15:52:15 +0100
Message-ID: <1369061535.4616.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <alpine.DEB.2.02.1305182314500.16874@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1305182314500.16874@fry.nucleusys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2013-05-18 at 23:21 +0300, Petko Manolov wrote:
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
>  };
>  
>  static int rtl8150_probe(struct usb_interface *intf,
[...]
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
>  };

These looked better before.  Lining up initialisers in a structure
definition is good style.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
