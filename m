From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: question about drivers/net/usb/rtl8150.c
Date: Sun, 13 Dec 2009 02:40:29 -0800 (PST)
Message-ID: <20091213.024029.93629279.davem@davemloft.net>
References: <Pine.LNX.4.64.0912131126570.24267@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: julia-dAYI7NvHqcQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0912131126570.24267-QfmoRoYWmW9knbxzx/v8hQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Date: Sun, 13 Dec 2009 11:28:42 +0100 (CET)

> The function rtl8150_set_mac_address in the file drivers/net/usb/rtl8150.c
> contains the following code:
> 
> set_registers(dev, IDR, sizeof(netdev->dev_addr), netdev->dev_addr);
> 
> Is it correct that the size of the pointer is what is wanted?

Like cpmac.c and 3c507.c, needs to be fixed.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
