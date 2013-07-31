From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/4] USB & USBNET: loose DMA SG check and support usbnet
 DMA SG
Date: Wed, 31 Jul 2013 08:25:40 -0700
Message-ID: <1375284340.10515.105.camel@edumazet-glaptop>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Freddy Xin <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Grant Grundler <grundler-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375267909-30373-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-07-31 at 18:51 +0800, Ming Lei wrote:
> Hi,
> 
> This patchset allows drivers to pass sg buffers which size can't be divided
> by max packet size of endpoint if the host controllers support this kind
> of sg buffers.
> 
> Previously we add check[1] on the situation and don't allow these sg buffers
> passed to USB HCD, looks the check is too strict because some applications(such
> as network stack) can't provide this sg buffers which size can be divided by
> max packet size, so this patch looses the check in case that the host controllers
> support it.
> 
> Also patch 3/4 implements DMA SG on usbnet driver, and patch 4/4
> enables it on ax88179_178a USB3 NIC, so CPU utilization can be
> decreased much with usbnet DMA SG when the USB3 NIC is attached to
> xHCI controller.

This looks very promising to me, thanks a lot for doing this Ming.


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
