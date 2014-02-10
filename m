From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] USB2NET : SR9800 : One chip USB2.0 USB2NET SR9800
 Device Driver Support
Date: Sun, 09 Feb 2014 21:47:01 -0800
Message-ID: <1392011221.3178.18.camel@joe-AO722>
References: <1392010419-5217-1-git-send-email-liujunliang_ljl@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org, romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sunhecheng-i49A8sVr+H5BDgjK7y7TUQ@public.gmane.org
To: liujunliang_ljl-9Onoh4P/yGk@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1392010419-5217-1-git-send-email-liujunliang_ljl-9Onoh4P/yGk@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-02-10 at 13:33 +0800, liujunliang_ljl-9Onoh4P/yGk@public.gmane.org wrote:
> diff --git a/drivers/net/usb/sr9800.c b/drivers/net/usb/sr9800.c
[]
> +	netdev_dbg(dev->net, "mac addr : 0x%x:0x%x:0x%x:0x%x:0x%x:0x%x\n",
> +		   dev->net->dev_addr[0], dev->net->dev_addr[1],
> +		   dev->net->dev_addr[2], dev->net->dev_addr[3],
> +		   dev->net->dev_addr[4], dev->net->dev_addr[5]);

mac addresses are assumed to be hex and don't need 0x prefixes.
Also, there's a kernel vsprintf extension "%pM" for mac addresses.

	netdev_dbg(dev->net, "mac addr: %pM\n", dev->net->dev_addr);


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
