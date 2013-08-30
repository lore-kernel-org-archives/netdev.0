From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] USB2NET : SR9700 : One Chip USB 1.1 USB2NET SR9700
 Device Driver Support
Date: Thu, 29 Aug 2013 21:42:41 -0700
Message-ID: <1377837761.1928.139.camel@joe-AO722>
References: <1377746832-6201-1-git-send-email-liujunliang_ljl@163.com>
	 <20130829230644.GA12124@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: liujunliang_ljl@163.com, davem@davemloft.net, horms@verge.net.au,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	sunhecheng@vip.126.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130829230644.GA12124@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-08-30 at 01:06 +0200, Francois Romieu wrote:

just trivia:

> diff --git a/drivers/net/usb/sr9700.c b/drivers/net/usb/sr9700.c
[]
> @@ -288,19 +291,19 @@ static void sr9700_set_multicast(struct net_device *net)
[]
> +static int sr9700_set_mac_address(struct net_device *netdev, void *p)
[]
> -	memcpy(net->dev_addr, addr->sa_data, net->addr_len);
> -	sr_write_async(dev, PAR, 6, dev->net->dev_addr);
> +	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
> +	sr_write_async(dev, PAR, 6, netdev->dev_addr);

s/6/ETH_ALEN/
 
