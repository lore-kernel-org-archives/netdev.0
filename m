From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 3.8-stable] usbnet: smsc95xx: fix suspend failure
Date: Mon, 04 Mar 2013 13:56:08 -0500 (EST)
Message-ID: <20130304.135608.2045232567964504683.davem@davemloft.net>
References: <1362391633-27551-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, oneukum-l3A5Bk7waGM@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org
To: ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1362391633-27551-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Date: Mon,  4 Mar 2013 18:07:13 +0800

> The three below functions:
> 
>         smsc95xx_enter_suspend0()
>         smsc95xx_enter_suspend1()
>         smsc95xx_enter_suspend2()
> 
> return > 0 in case of success, so they will cause smsc95xx_suspend()
> to return > 0 and suspend failure.
> 
> This patch is backported from the upstream commit:
> 
> 	From 7643721471117d5f62ca36f328d3dc8d84af4402 Mon Sep 17 00:00:00 2001
> 	Subject: [PATCH] usbnet: smsc95xx: fix suspend failure
> 
> Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
> Cc: Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>
> Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

This is fine, Greg please apply to 3.8-stable, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
