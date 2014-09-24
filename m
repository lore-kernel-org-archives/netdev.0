From: Lars Melin <larsm17-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] usb: gadget: f_rndis: fix usb_interface_descriptor for
 rndis
Date: Wed, 24 Sep 2014 19:25:30 +0700
Message-ID: <5422B83A.8030406@gmail.com>
References: <1411541339-32400-1-git-send-email-hs@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>, Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrzej Pietrasiewicz <andrzej.p-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Michal Nazarewicz <mina86-deATy8a+UHjQT0dZR+AlfA@public.gmane.org>,
	Kyungmin Park <kyungmin.park-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Macpaul Lin <macpaul-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1411541339-32400-1-git-send-email-hs-ynQEQJNshbs@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2014-09-24 13:48, Heiko Schocher wrote:
> use the values for RNDIS over Ethernet as defined in
> http://www.usb.org/developers/defined_class
> (search for RDNIS):
>
> - baseclass: 0xef (miscellaneous)
> - subclass: 0x04
> - protocol: 0x01
>
That is usb class, it is not the same thing as communication device class.
> --- a/include/uapi/linux/usb/cdc.h
> +++ b/include/uapi/linux/usb/cdc.h
> @@ -12,6 +12,7 @@
>   #include <linux/types.h>
>   
>   #define USB_CDC_SUBCLASS_ACM			0x02
> +#define USB_CDC_SUBCLASS_RNDIS			0x04
No, no, no.
There is no CDC_SUBCLASS_RNDIS and you can not define one over an 
already used cdc subclass number,  0x04 is  Multi-Channel Control Model
