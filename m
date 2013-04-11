From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 00/11] usbnet: usbnet: handle link change
Date: Thu, 11 Apr 2013 15:58:27 -0400 (EDT)
Message-ID: <20130411.155827.968210808922643422.davem@davemloft.net>
References: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, oneukum-l3A5Bk7waGM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1365691240-816-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date: Thu, 11 Apr 2013 22:40:29 +0800

> This patch set introduces usbnet_link_change() API and applies
> it on all usbnet drivers, then handle the link change centrally
> to stop bulk transfer when link becomes off and restart bulk
> transfer when link becomes on.
> 
> With the change, ~10% performance boost on bulk transfer
> of another device on the same bus can be obtained when link
> is off. Also, stopping bulk transfer when link becomes off
> may disable asynchonous schedule of host controller, power
> might be saved probabally.

Series applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
