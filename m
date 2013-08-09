From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v4 0/4] USB & USBNET: loose SG check and support usbnet
 DMA SG
Date: Fri, 09 Aug 2013 14:12:17 -0700 (PDT)
Message-ID: <20130809.141217.555889385998745188.davem@davemloft.net>
References: <1375969705-24877-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, oneukum-l3A5Bk7waGM@public.gmane.org,
	sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1375969705-24877-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date: Thu,  8 Aug 2013 21:48:21 +0800

> This patchset allows drivers to pass sg buffers which size can't be divided
> by max packet size of endpoint if the host controllers(such ax xHCI) support
> this kind of sg buffers.
> 
> Previously we added check[1] on the situation and don't allow these sg buffers
> passed to USB HCD, looks the check is too strict to make use of new feature of
> new hardware(xHCI) for some applications(such as network stack) which can't
> provide this kind of sg buffers to usbnet driver, so the patch looses the check
> in case that the host controller supports it.
> 
> Patch 3/4 implements DMA SG on usbnet driver, and patch 4/4 uses it on ax88179_178a
> USB3 NIC for supporting TSO, so both CPU utilization and tx throughput can be
> improved with TSO and DMA SG in case of the USB NIC is attached to xHCI controller.
> 
> This patchset depends on both net-next and usb-next tree, so hope David and Greg
> to figure out one elegent way to merge it.

Greg feel free to merge this in via your USB tree with my:

Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
