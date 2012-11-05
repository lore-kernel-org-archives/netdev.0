From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH v1 0/5] usbnet: avoiding access auto-suspended device
Date: Mon, 05 Nov 2012 10:24:57 +0100
Message-ID: <9016904.gHGBncEQ14@linux-lqwf.site>
References: <1351992594-12818-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1351992594-12818-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 04 November 2012 09:29:49 Ming Lei wrote:
> Thip patchset avoids accessing auto-suspended device in ioctl path,
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
> patcheset introduce the nopm version of the two functions which
> should be called only in the resume and suspend callback. So we
> can solve the problem by runtime resuming device before doing
> control message things.

Hi,

I am happy with these patches.
Dave, do you have a principal objection regarding these patches, too?

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
