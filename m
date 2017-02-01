From: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4.10-rc3 03/13] net: macb: fix build errors when
 linux/phy*.h is removed from net/dsa.h
Date: Wed, 1 Feb 2017 10:40:53 +0100
Message-ID: <0a75edf8-df17-fb7f-294f-8c1e04479a3b@atmel.com>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
 <E1cYdws-0000W9-GV@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        <linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>, <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <E1cYdws-0000W9-GV-eh5Bv4kxaXIk46pC+1QYvQNdhmdF6hFW@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 31/01/2017 à 20:18, Russell King a écrit :
> drivers/net/ethernet/cadence/macb.h:862:33: sparse: expected ; at end of declaration
> drivers/net/ethernet/cadence/macb.h:862:33: sparse: Expected } at end of struct-union-enum-specifier
> drivers/net/ethernet/cadence/macb.h:862:33: sparse: got phy_interface
> drivers/net/ethernet/cadence/macb.h:877:1: sparse: Expected ; at the end of type declaration
> drivers/net/ethernet/cadence/macb.h:877:1: sparse: got }
> In file included from drivers/net/ethernet/cadence/macb_pci.c:29:0:
> drivers/net/ethernet/cadence/macb.h:862:2: error: unknown type name 'phy_interface_t'
>      phy_interface_t  phy_interface;
>      ^~~~~~~~~~~~~~~
> 
> Add linux/phy.h to macb.h
> 
> Signed-off-by: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>

Acked-by: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>

> ---
>  drivers/net/ethernet/cadence/macb.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index d67adad67be1..383da8cf5f6d 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -10,6 +10,8 @@
>  #ifndef _MACB_H
>  #define _MACB_H
>  
> +#include <linux/phy.h>
> +
>  #define MACB_GREGS_NBR 16
>  #define MACB_GREGS_VERSION 2
>  #define MACB_MAX_QUEUES 8
> 


-- 
Nicolas Ferre
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
