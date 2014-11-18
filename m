From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH] usbnet: rtl8150: remove unused variable
Date: Tue, 18 Nov 2014 17:30:42 +0200
Message-ID: <20141118153042.GB18659@vm-taos-petkan.jnpr.net>
References: <1416315599-16939-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lan.nucleusys.com ([92.247.61.126]:48767 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755650AbaKRQFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 11:05:32 -0500
Content-Disposition: inline
In-Reply-To: <1416315599-16939-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14-11-18 18:29:59, Sudip Mukherjee wrote:
> we were just returning the initial value of res, instead now
> we are returning the value directly.

Looks OK, but could you please fix the wording of the commit message to something like:

	Remove unused variable.

This is a tiny patch and the code speaks for itself.


		Petko


> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
> ---
>  drivers/net/usb/rtl8150.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
> index 6e87e57..d37b7dc 100644
> --- a/drivers/net/usb/rtl8150.c
> +++ b/drivers/net/usb/rtl8150.c
> @@ -753,14 +753,13 @@ static int rtl8150_open(struct net_device *netdev)
>  static int rtl8150_close(struct net_device *netdev)
>  {
>  	rtl8150_t *dev = netdev_priv(netdev);
> -	int res = 0;
>  
>  	netif_stop_queue(netdev);
>  	if (!test_bit(RTL8150_UNPLUG, &dev->flags))
>  		disable_net_traffic(dev);
>  	unlink_all_urbs(dev);
>  
> -	return res;
> +	return 0;
>  }
>  
>  static void rtl8150_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *info)
> -- 
> 1.8.1.2
> 
