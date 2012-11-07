From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v4 0/5] usbnet: avoiding access auto-suspended device
Date: Wed, 07 Nov 2012 03:54:37 -0500 (EST)
Message-ID: <20121107.035437.1004450415124026375.davem@davemloft.net>
References: <1352213588-8948-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, oneukum-l3A5Bk7waGM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1352213588-8948-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date: Tue,  6 Nov 2012 22:53:03 +0800

> This patchset avoids accessing auto-suspended device in ioctl path,
> which is generally triggered by some network utility(ethtool, ifconfig,
> ...)
> 
> Most of network devices have the problem, but as discussed in the
> thread:
> 
>         http://marc.info/?t=135054860600003&r=1&w=2
> 
> the problem should be solved inside driver.
> 
> Considered that only smsc75xx and smsc95xx calls usbnet_read_cmd()
> and usbnet_write_cmd() inside its resume and suspend callback, the
> patcheset introduces the nopm version of the two functions which
> should be called only in the resume and suspend callback. So we
> can solve the problem by runtime resuming device before doing
> control message things.
> 
> The patchset is against 3.7.0-rc4-next-20121105, and has been tested
> OK on smsc95xx usbnet device.

All applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
