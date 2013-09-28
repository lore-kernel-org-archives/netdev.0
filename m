From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v1] USBNET: fix handling padding packet
Date: Sat, 28 Sep 2013 15:45:41 -0400 (EDT)
Message-ID: <20130928.154541.1873056783751780882.davem@davemloft.net>
References: <1379941175-10500-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, oneukum-l3A5Bk7waGM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1379941175-10500-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date: Mon, 23 Sep 2013 20:59:35 +0800

> Commit 638c5115a7949(USBNET: support DMA SG) introduces DMA SG
> if the usb host controller is capable of building packet from
> discontinuous buffers, but missed handling padding packet when
> building DMA SG.
> 
> This patch attachs the pre-allocated padding packet at the
> end of the sg list, so padding packet can be sent to device
> if drivers require that.
> 
> Reported-by: David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>
> Acked-by: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
> Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Applied, thanks.

I still think the suggestion to disable scatter gather for
devices with the padding issue was the most sane approach
to solve this.

I guess people like supporting complicated crap and excess
code for things that pretty much do not exist, or at best
are not prominent enough to cater for at all.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
