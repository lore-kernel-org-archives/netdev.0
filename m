From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: rtl8150: use default MTU of 1500
Date: Fri, 01 Feb 2008 13:41:23 -0500
Message-ID: <47A367D3.10401@pobox.com>
References: <20080130193742.GA13631@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Petko Manolov <petkan@nucleusys.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54940 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758702AbYBASl1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 13:41:27 -0500
In-Reply-To: <20080130193742.GA13631@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> The RTL8150 driver uses an MTU of 1540 by default, which causes a
> bunch of problems -- it prevents booting from NFS root, for one.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>
> Cc: Petko Manolov <petkan@nucleusys.com>
> 
> --- linux-2.6.24-git7.orig/drivers/net/usb/rtl8150.c	2008-01-24 23:58:37.000000000 +0100
> +++ linux-2.6.24-git7/drivers/net/usb/rtl8150.c	2008-01-30 20:29:00.000000000 +0100
> @@ -925,9 +925,8 @@
>  	netdev->hard_start_xmit = rtl8150_start_xmit;
>  	netdev->set_multicast_list = rtl8150_set_multicast;
>  	netdev->set_mac_address = rtl8150_set_mac_address;
>  	netdev->get_stats = rtl8150_netdev_stats;
> -	netdev->mtu = RTL8150_MTU;
>  	SET_ETHTOOL_OPS(netdev, &ops);
>  	dev->intr_interval = 100;	/* 100ms */
>  
>  	if (!alloc_all_urbs(dev)) {

applied


