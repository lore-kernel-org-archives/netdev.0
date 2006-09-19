From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH,RESEND] rtl8150: use default MTU of 1500
Date: Tue, 19 Sep 2006 16:49:25 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0609191644410.5829@bender.nucleusys.com>
References: <20060917193516.GB29851@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: petkan@users.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.nucleusys.com ([217.79.38.164]:10376 "EHLO
	zztop.nucleusys.com") by vger.kernel.org with ESMTP
	id S1751950AbWISNtd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 09:49:33 -0400
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20060917193516.GB29851@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If this fixes the issue then what else can i say?.. ;-)

However, isn't it better to just change RTL8150_MTU to 1500 instead of 
removing that line?


 		Petko



On Sun, 17 Sep 2006, Lennert Buytenhek wrote:

> The rtl8150 (ethernet) driver uses a default MTU of 1540, which causes
> all kinds of problems with for example booting off NFS root.  There isn't
> really any reason why we shouldn't use the default of 1500.
>
> Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>
>
> Index: linux-2.6.18-rc2/drivers/usb/net/rtl8150.c
> ===================================================================
> --- linux-2.6.18-rc2.orig/drivers/usb/net/rtl8150.c
> +++ linux-2.6.18-rc2/drivers/usb/net/rtl8150.c
> @@ -867,9 +867,8 @@
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
