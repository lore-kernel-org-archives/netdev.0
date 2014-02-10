From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] USB2NET : SR9800 : One chip USB2.0 USB2NET SR9800
 Device Driver Support
Date: Sun, 09 Feb 2014 18:58:32 -0800
Message-ID: <1392001112.3178.15.camel@joe-AO722>
References: <1391755365-9202-1-git-send-email-liujunliang_ljl@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, horms@verge.net.au, romieu@fr.zoreil.com,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	sunhecheng@vip.126.com
To: liujunliang_ljl@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391755365-9202-1-git-send-email-liujunliang_ljl@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-02-07 at 14:42 +0800, liujunliang_ljl@163.com wrote:

> +		netdev_dbg(dev->net, "Write IPG,IPG1,IPG2 failed: %d", ret);
[]
> +	netdev_dbg(dev->net, "RX_CTL is 0x%04x after all initializations",
[]
> +	netdev_dbg(dev->net, "Medium Status : 0x%04x after all initializations",
[]
> +		netdev_dbg(dev->net, "Select PHY #1 failed: %d", ret);
[]
> +	netdev_dbg(dev->net, "RX_CTL is 0x%04x after software reset", rx_ctl);
[]
> +	netdev_dbg(dev->net, "RX_CTL is 0x%04x setting to 0x0000", rx_ctl);
[]
> +	memcpy(data->mac_addr, dev->net->dev_addr, ETH_ALEN);

ether_addr_copy

> +		netdev_err(dev->net, "Failed to power down PHY : %d", ret);
[]
> +		netdev_err(dev->net, "Failed to reset PHY: %d", ret);
[]
> +		netdev_err(dev->net, "Failed to power up PHY: %d", ret);
[]
> +		netdev_err(dev->net, "Failed to reset PHY: %d", ret);
[]
> +			netdev_err(dev->net, "set LINK LED failed : %d", ret);
[]
> +		netdev_dbg(dev->net, "Failed to read MAC address: %d", ret);
[]
> +		netdev_dbg(dev->net, "Select PHY #1 failed: %d", ret);
[]
> +	netdev_dbg(dev->net, "RX_CTL is 0x%04x after software reset", rx_ctl);
[]
> +	netdev_dbg(dev->net, "RX_CTL is 0x%04x setting to 0x0000", rx_ctl);
[]
> +	netdev_dbg(dev->net, "PHYID=0x%08x", phyid);

Please make sure all of the netdev_<level> uses have a '\n'
line termination.
