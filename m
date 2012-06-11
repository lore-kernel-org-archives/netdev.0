From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH] usbnet: Activate the halt interrupt endpoint to fix endless "XactErr" error
Date: Mon, 11 Jun 2012 22:47:15 +0200
Message-ID: <87sje1podo.fsf@nemi.mork.no>
References: <CA+v9cxYHq4gcy11SDmsuHUhTSdLJM-G0sugYnOjSthbYWA+1Yg@mail.gmail.com>
	<20120607.145438.1351539405712214173.davem@davemloft.net>
	<CA+v9cxaLERjFKdE7joGgmpbxCUotdh=Nn4F4f-KeOXwp8nqMPg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CA+v9cxaLERjFKdE7joGgmpbxCUotdh=Nn4F4f-KeOXwp8nqMPg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Huajun Li's message of "Mon, 11 Jun 2012 22:41:03 +0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Huajun Li <huajun.li.lee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
> index 76f4396..c0bcb61 100644
> --- a/include/linux/usb/usbnet.h
> +++ b/include/linux/usb/usbnet.h
> @@ -62,13 +62,14 @@ struct usbnet {
>  	unsigned long		flags;
>  #		define EVENT_TX_HALT	0
>  #		define EVENT_RX_HALT	1
> -#		define EVENT_RX_MEMORY	2
> -#		define EVENT_STS_SPLIT	3
> -#		define EVENT_LINK_RESET	4
> -#		define EVENT_RX_PAUSED	5
> -#		define EVENT_DEV_WAKING 6
> -#		define EVENT_DEV_ASLEEP 7
> -#		define EVENT_DEV_OPEN	8
> +#		define EVENT_STS_HALT	2
> +#		define EVENT_RX_MEMORY	3
> +#		define EVENT_STS_SPLIT	4
> +#		define EVENT_LINK_RESET	5
> +#		define EVENT_RX_PAUSED	6
> +#		define EVENT_DEV_WAKING 7
> +#		define EVENT_DEV_ASLEEP 8
> +#		define EVENT_DEV_OPEN	9
>  };

Why do you renumber all of these instead of adding the new
EVENT_STS_HALT to the end of the list?


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
