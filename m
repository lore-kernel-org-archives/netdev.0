From: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [00/04] HSO driver bugfixes and updates
Date: Thu, 14 Aug 2008 04:45:01 -0400
Message-ID: <48A3F08D.2000109@pobox.com>
References: <20080808190023.GA2953@kroah.com> <200808081353.30130.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jari Tenhunen <jari.tenhunen-X3B1VOXEql0@public.gmane.org>,
	Olivier Blin <blino-4qZELD6FgxhWk0Htik3J/w@public.gmane.org>,
	Andrew Bird <ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org>,
	Paul Rolland <rol-fjEKYshTNZ1eoWH0uzbU5w@public.gmane.org>,
	Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200808081353.30130.david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Brownell wrote:
> On Friday 08 August 2008, Greg KH wrote:
>> Jeff,
>>
>> Here are 4 patches against 2.6.27-rc2 for the drivers/net/usb/hso.c
>> driver.
> 
> And here's a fifth (resent) ... just fixing brokenKconfig.
> 
> ==== CUT HERE
> From: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
> 
> Move the Kconfig for the new "Option" driver so it's not in the
> middle of the usbnet-based drivers, so the dependency displays
> in the Kconfig user interfaces don't get trashed.
> 
> Signed-off-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
> ---
>  drivers/net/usb/Kconfig |   21 ++++++++++-----------
>  1 file changed, 10 insertions(+), 11 deletions(-)
> 
> --- a/drivers/net/usb/Kconfig	2008-07-26 17:11:01.000000000 -0700
> +++ b/drivers/net/usb/Kconfig	2008-07-26 17:40:33.000000000 -0700
> @@ -154,17 +154,6 @@ config USB_NET_AX8817X
>  	  This driver creates an interface named "ethX", where X depends on
>  	  what other networking devices you have in use.
>  
> -config USB_HSO
> -	tristate "Option USB High Speed Mobile Devices"
> -	depends on USB && RFKILL
> -	default n
> -	help
> -	  Choose this option if you have an Option HSDPA/HSUPA card.
> -	  These cards support downlink speeds of 7.2Mbps or greater.
> -
> -	  To compile this driver as a module, choose M here: the
> -	  module will be called hso.
> -
>  config USB_NET_CDCETHER
>  	tristate "CDC Ethernet support (smart devices such as cable modems)"
>  	depends on USB_USBNET
> @@ -337,5 +326,15 @@ config USB_NET_ZAURUS
>  	  really need this non-conformant variant of CDC Ethernet (or in
>  	  some cases CDC MDLM) protocol, not "g_ether".
>  
> +config USB_HSO
> +	tristate "Option USB High Speed Mobile Devices"
> +	depends on USB && RFKILL
> +	default n
> +	help
> +	  Choose this option if you have an Option HSDPA/HSUPA card.
> +	  These cards support downlink speeds of 7.2Mbps or greater.
> +
> +	  To compile this driver as a module, choose M here: the
> +	  module will be called hso.
>  
>  endmenu

applied


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
