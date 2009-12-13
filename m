From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Subject: question about drivers/net/usb/rtl8150.c
Date: Sun, 13 Dec 2009 11:28:42 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0912131126570.24267@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: petkan-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The function rtl8150_set_mac_address in the file drivers/net/usb/rtl8150.c
contains the following code:

set_registers(dev, IDR, sizeof(netdev->dev_addr), netdev->dev_addr);

Is it correct that the size of the pointer is what is wanted?

julia
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
