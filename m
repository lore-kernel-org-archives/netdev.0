From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 4/4] USBNET: ax88179_178a: enable tso if usb host
 supports sg dma
Date: Thu, 08 Aug 2013 09:01:42 -0700
Message-ID: <1375977702.4004.107.camel@edumazet-glaptop>
References: <1375969705-24877-1-git-send-email-ming.lei@canonical.com>
	 <1375969705-24877-5-git-send-email-ming.lei@canonical.com>
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
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375969705-24877-5-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-08-08 at 21:48 +0800, Ming Lei wrote:
> This patch enables 'can_dma_sg' flag for ax88179_178a device
> if the attached host controller supports building packet from
> discontinuous buffers(DMA SG is possible), so TSO can be enabled
> and skb fragment buffers can be passed to usb stack via urb->sg
> directly.
> 
> With the patch, system CPU utilization decreased ~50% and throughput
> increased by ~10% when doing iperf client test on one ARM A15 dual
> core board.
> 
> Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
> Cc: Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
> Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
> Cc: Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
> Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  drivers/net/usb/ax88179_178a.c |    8 ++++++++
>  1 file changed, 8 insertions(+)

Acked-by: Eric Dumazet <edumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Thanks for doing this !


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
