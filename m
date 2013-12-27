From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/6] r8152: add rtl_ops
Date: Fri, 27 Dec 2013 12:28:13 -0500 (EST)
Message-ID: <20131227.122813.901851776030758668.davem@davemloft.net>
References: <1388111649-1014-1-git-send-email-hayeswang@realtek.com>
	<1388111649-1014-5-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388111649-1014-5-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Fri, 27 Dec 2013 10:34:08 +0800

>  
> +static int rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
 ...
>  
> +	if (rtl_ops_init(tp, id)) {
> +		netif_err(tp, probe, netdev, "Unknown Device");
> +		return -ENODEV;

You're completely ignoring the error code returned from rtl_ops_init()
(which, as an aside, uses -EFAULT which doesn't seem all that
appropriate).

You might as well have rtl_ops_init() return a boolean.
