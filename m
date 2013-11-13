From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] usbnet: fix status interrupt urb handling
Date: Wed, 13 Nov 2013 09:01:12 +0100
Message-ID: <1384329672.5724.6.camel@linux-fkkt.site>
References: <1384270481-30972-1-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1384270481-30972-1-git-send-email-nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-11-12 at 16:34 +0100, Felix Fietkau wrote:
> Since commit 7b0c5f21f348a66de495868b8df0284e8dfd6bbf
> "sierra_net: keep status interrupt URB active", sierra_net triggers
> status interrupt polling before the net_device is opened (in order to
> properly receive the sync message response).
> 
> To be able to receive further interrupts, the interrupt urb needs to be
> re-submitted, so this patch removes the bogus check for netif_running().

And what about the other drivers for whom this patch means added
traffic? This fix is done with a sledge hammer and cares only about
some drivers.
I'd much prefer you introduced a driver flag for this.

	Regards
		Oliver


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
