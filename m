From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCH 1/5] initdev:kernel: Asynchronously-discovered device
 synchronization, v5
Date: Sat, 2 May 2009 10:16:39 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0905021010200.23879-100000@netrider.rowland.org>
References: <20090502133153.GA8116@atlas.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sergey Vlasov <vsu-u2l5PoMzF/Uox3rIn2DAYQ@public.gmane.org>,
	Kernel development list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	SCSI development list <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
To: David VomLehn <dvomlehn-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090502133153.GA8116-2JxNCdI+WHxBDLzU/O5InQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I agree with Sergey's comments.  In addition:

On Fri, May 01, 2009 at 07:25:51PM -0700, David VomLehn wrote:

> +initdev_wait(enum initdev_type type, bool (*done)(void))
> +	Wait until one of two conditions is met:
> +	o	All possible init devices of the given type have been probed
> +	o	The "done" function returns true
> +
> +	The type is one of:
> +		BOOTDEV_CONSOLE
> +		BOOTDEV_NETDEV
> +		BOOTDEV_BLOCK

These should be named INITDEV_CONSOLE_TYPE and so on, with the final 
_TYPE suffix to help prevent confusion with INITDEV_CONSOLE_MASK.

Also, in patch 3/5:

> --- a/drivers/accessibility/braille/braille_console.c
> +++ b/drivers/accessibility/braille/braille_console.c
> @@ -35,6 +35,7 @@
>  #include <linux/keyboard.h>
>  #include <linux/kbd_kern.h>
>  #include <linux/input.h>
> +#include <linux/initdev.h>

What does this do?  It looks like a typo.

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
