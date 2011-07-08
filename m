From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] hso: fix a use after free condition
Date: Fri, 08 Jul 2011 09:08:13 -0700 (PDT)
Message-ID: <20110708.090813.1807341905527902786.davem@davemloft.net>
References: <20110708134525.GA5069@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110708134525.GA5069-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Date: Fri, 8 Jul 2011 06:45:25 -0700

> This needs to go to netdev:
> 
> From: Octavian Purdila <octavian.purdila-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> In hso_free_net_device hso_net pointer is freed and then used to
> cleanup urb pools. Catched with SLAB_DEBUG during S3 resume:
 ...
> Signed-off-by: Octavian Purdila <octavian.purdila-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
