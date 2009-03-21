From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 26/77] usbnet: convert to internal net_device_stats
Date: Sat, 21 Mar 2009 02:09:04 -0700
Message-ID: <200903210209.04785.david-b@pacbell.net>
References: <20090321053527.316395697@vyatta.com> <20090321053714.509353403@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp127.sbc.mail.sp1.yahoo.com ([69.147.65.186]:46405 "HELO
	smtp127.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753378AbZCUJZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 05:25:54 -0400
In-Reply-To: <20090321053714.509353403@vyatta.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 20 March 2009, Stephen Hemminger wrote:
> Default handler for net_device_stats already does same thing.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: David Brownell <dbrownell@users.sourceforge.net>



> 
> 
> --- a/drivers/net/usb/usbnet.c	2009-03-20 09:38:00.950964064 -0700
> +++ b/drivers/net/usb/usbnet.c	2009-03-20 09:38:46.383715245 -0700
> @@ -249,14 +249,6 @@ static int usbnet_change_mtu (struct net
>  
>  /*-------------------------------------------------------------------------*/
>  
> -static struct net_device_stats *usbnet_get_stats (struct net_device *net)
> -{
> -	struct usbnet	*dev = netdev_priv(net);
> -	return &dev->stats;
> -}
> -
> -/*-------------------------------------------------------------------------*/
> -
>  /* some LK 2.4 HCDs oopsed if we freed or resubmitted urbs from
>   * completion callbacks.  2.5 should have fixed those bugs...
>   */
> @@ -1180,7 +1172,6 @@ usbnet_probe (struct usb_interface *udev
>  #endif
>  
>  	net->change_mtu = usbnet_change_mtu;
> -	net->get_stats = usbnet_get_stats;
>  	net->hard_start_xmit = usbnet_start_xmit;
>  	net->open = usbnet_open;
>  	net->stop = usbnet_stop;
> 
> -- 
> 
> 


