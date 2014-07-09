From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: support jumbo frame for RTL8153
Date: Wed, 09 Jul 2014 16:46:58 -0700 (PDT)
Message-ID: <20140709.164658.447780441521030859.davem@davemloft.net>
References: <1394712342-15778-8-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-8-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Wed, 9 Jul 2014 16:07:02 +0800

> +static int rtl8152_change_mtu(struct net_device *dev, int new_mtu)
> +{
> +	struct r8152 *tp = netdev_priv(dev);
> +
> +	if (dev->mtu == new_mtu)
> +		return 0;

This method will never be invoked if the MTU is actually not changing.

Please remove this test.
