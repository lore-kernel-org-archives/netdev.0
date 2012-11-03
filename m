From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 0/4] usbnet: avoiding access auto-suspended device
Date: Sat, 03 Nov 2012 14:52:07 -0400 (EDT)
Message-ID: <20121103.145207.70028483679120460.davem@davemloft.net>
References: <1351496709-26934-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, oneukum-l3A5Bk7waGM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1351496709-26934-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date: Mon, 29 Oct 2012 15:45:05 +0800

> Thip patchset avoids accessing auto-suspended device in ioctl path,
> which is generally triggered by some network utility(ethtool, ifconfig,
> ...)
> 
> Most of network devices have the problem, but as discussed in the
> thread:
> 
> 	http://marc.info/?t=135054860600003&r=1&w=2
> 
> the problem should be solved inside driver.
> 
> Considered that only smsc75xx and smsc95xx calls usbnet_read_cmd()
> and usbnet_write_cmd() inside its resume and suspend callback, the
> patcheset introduce the nopm version of the two functions which
> should be called only in the resume and suspend callback. So we
> can solve the problem by runtime resuming device before doing
> control message things.
> 
> The patchset is against 3.7.0-rc3-next-20121029, and has been tested
> OK on smsc95xx usbnet device.

This series doesn't apply against net-next, as there have been
changes to the smsc drivers meanwhile.

You'll need to respin this series against net-next.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
