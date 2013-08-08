From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 3/4] USBNET: support DMA SG
Date: Thu, 08 Aug 2013 09:27:35 -0700
Message-ID: <1375979255.4004.109.camel@edumazet-glaptop>
References: <1375969705-24877-1-git-send-email-ming.lei@canonical.com>
	 <1375969705-24877-4-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375969705-24877-4-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-08-08 at 21:48 +0800, Ming Lei wrote:
> This patch introduces support of DMA SG if the USB host controller
> which usbnet device is attached to is capable of building packet from
> discontinuous buffers.


> diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
> index 8fbc008..9cb2fe8 100644
> --- a/include/linux/usb/usbnet.h
> +++ b/include/linux/usb/usbnet.h
> @@ -35,6 +35,7 @@ struct usbnet {
>  	unsigned char		suspend_count;
>  	unsigned char		pkt_cnt, pkt_err;
>  	unsigned short		rx_qlen, tx_qlen;
> +	unsigned		can_dma_sg:1;

We try to use "unsigned int" instead of plain "unsigned", but its a
minor point and should not block your patches.

Apart from this :

Reviewed-by: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
