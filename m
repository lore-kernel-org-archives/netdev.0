From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] usbnet: fix status interrupt urb handling
Date: Thu, 14 Nov 2013 02:33:21 -0500 (EST)
Message-ID: <20131114.023321.740256050148841932.davem@davemloft.net>
References: <1384270481-30972-1-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1384270481-30972-1-git-send-email-nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Date: Tue, 12 Nov 2013 16:34:41 +0100

> Since commit 7b0c5f21f348a66de495868b8df0284e8dfd6bbf
> "sierra_net: keep status interrupt URB active", sierra_net triggers
> status interrupt polling before the net_device is opened (in order to
> properly receive the sync message response).
> 
> To be able to receive further interrupts, the interrupt urb needs to be
> re-submitted, so this patch removes the bogus check for netif_running().
> 
> Signed-off-by: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>

Applied and queued up for -stable, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
