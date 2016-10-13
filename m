From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net] qmi_wwan: add support for Quectel EC21 and EC25
Date: Thu, 13 Oct 2016 10:06:58 -0400 (EDT)
Message-ID: <20161013.100658.2004540239157240023.davem@davemloft.net>
References: <20161010191249.23814-1-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161010191249.23814-1-bjorn-yOkvZcmFvRU@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Date: Mon, 10 Oct 2016 21:12:49 +0200

> The Quectel EC21 and EC25 need the same "set DTR" request as devices
> based on the MDM9230 chipset, but has no USB3 support. Our best guess
> is that the "set DTR" functionality depends on chipset and/or
> baseband firmware generation. But USB3 is still an optional feature.
> 
> Since we cannot enable this unconditionally for all older devices, and
> there doesn't appear to be anything we can use in the USB descriptors
> to identify these chips, we are forced to use a device specific quirk
> flag.
> 
> Reported-and-tested-by: Sebastian Sjoholm <sebastian.sjoholm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
