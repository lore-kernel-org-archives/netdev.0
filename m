From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: rtl8150: use default MTU of 1500
Date: Thu, 31 Jan 2008 17:42:34 +0200 (EET)
Message-ID: <alpine.DEB.1.00.0801311741400.4476@bender.nucleusys.com>
References: <20080130193742.GA13631@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n152-u15.cabletel.bg ([89.253.152.15]:58169 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753566AbYAaPnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 10:43:03 -0500
In-Reply-To: <20080130193742.GA13631@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Jan 2008, Lennert Buytenhek wrote:

> The RTL8150 driver uses an MTU of 1540 by default, which causes a
> bunch of problems -- it prevents booting from NFS root, for one.

Agreed, although it is a bit strange how this particular bug has sneaked 
up for so long...


cheers,
Petko



> Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>
> Cc: Petko Manolov <petkan@nucleusys.com>
>
> --- linux-2.6.24-git7.orig/drivers/net/usb/rtl8150.c	2008-01-24 23:58:37.000000000 +0100
> +++ linux-2.6.24-git7/drivers/net/usb/rtl8150.c	2008-01-30 20:29:00.000000000 +0100
> @@ -925,9 +925,8 @@
> 	netdev->hard_start_xmit = rtl8150_start_xmit;
> 	netdev->set_multicast_list = rtl8150_set_multicast;
> 	netdev->set_mac_address = rtl8150_set_mac_address;
> 	netdev->get_stats = rtl8150_netdev_stats;
> -	netdev->mtu = RTL8150_MTU;
> 	SET_ETHTOOL_OPS(netdev, &ops);
> 	dev->intr_interval = 100;	/* 100ms */
>
> 	if (!alloc_all_urbs(dev)) {
>
