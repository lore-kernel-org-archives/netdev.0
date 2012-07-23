From: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] USB: plusb: Add support for PL-2501
Date: Mon, 23 Jul 2012 14:25:37 +0400
Message-ID: <500D26A1.50500@mvista.com>
References: <alpine.LNX.2.02.1207222138410.1183@bas>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Greg Kroah-Hartman <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kyak <bas-v2SRCKu5KfM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.02.1207222138410.1183@bas>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 22-07-2012 21:42, kyak wrote:

> From: Mikhail Peselnik <peselnik-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

> This patch adds support for PL-2501 by adding the appropriate USB
> ID's. This chip is used in several USB 'Easy Trasfer' Cables.

> Signed-off-by: Mikhail Peselnik <peselnik-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Tested-by: Mikhail Peselnik <peselnik-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
> Now with proper sign-offs and right people in cc.
> plusb driver (drivers/net/usb/plusb.c) doesn't recognize PL2501 chip.
> Since PL2501 uses the same code as PL2301/PL2302 (PL2501 works in
> compatibility mode with PL2301/PL2302), the fix is trivial and
> attached as a patch.

> Just to note: the patch is not mine, it can be found here and there on
> Internet.
> I've tested the patch and it works great.

> Thank you.

> --- linux-3.5/drivers/net/usb/plusb.c.orig      2012-07-22
> 21:06:41.905802795 +0400
> +++ linux-3.5/drivers/net/usb/plusb.c   2012-07-22 21:07:00.345552404 +0400
[...]
> @@ -158,5 +161,5 @@ static struct usb_driver plusb_driver =
>   module_usb_driver(plusb_driver);
>
>   MODULE_AUTHOR("David Brownell");
> -MODULE_DESCRIPTION("Prolific PL-2301/2302/25A1 USB Host to Host Link Driver");
> +MODULE_DESCRIPTION("Prolific PL-2301/2302/25A1/2501 USB Host to Host
> Link Driver");

    Your patch is line wrapped. Seeems easy to fix though...

WBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
