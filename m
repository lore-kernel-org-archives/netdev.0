From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v3] Add support for GPIOs for SMSC LAN95xx chips.
Date: Thu, 09 Oct 2014 18:45:58 -0400 (EDT)
Message-ID: <20141009.184558.619106178447500762.davem@davemloft.net>
References: <CAN_we7MbMywYzysn_Q_iRAOZZuE+KU_jDJxMW-Qz0KK0RHwSRQ@mail.gmail.com>
	<1412806498-22556-1-git-send-email-boger@contactless.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dforsi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: boger-hVk9LwgH4SrGCOCKMErq+g@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1412806498-22556-1-git-send-email-boger-hVk9LwgH4SrGCOCKMErq+g@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Evgeny Boger <boger-hVk9LwgH4SrGCOCKMErq+g@public.gmane.org>
Date: Thu,  9 Oct 2014 02:14:58 +0400

> There might be 11 GPIOs in total.
> Last three GPIOs  (offsets 8-10, 0-based) are shared with FDX, LNKA, SPD
> LEDs respectively. The LEDs are driven by chip by default at startup time.
> Once the corresponding GPIO is requested, the chip LED drive logic is disabled.
> 
> The numbering scheme according to datasheets differs a bit between LAN9500
> and LAN951x.
> 
> For LAN951x:
> GPIOs with offsets 0-7 are named "GPIO3" - "GPIO7",
> offsets 8-10 are for "GPIO0" - "GPIO2" (these three are multiplexed with nFDX_LED,
> nLNKA_LED, nSPD_LED).
> 
> For LAN9500:
> The datasheet name is the same as the corresponding offset, i.e. offsets 0-10 are
> for "GPIO0"-"GPIO10".
> 
> Signed-off-by: Evgeny Boger <boger-hVk9LwgH4SrGCOCKMErq+g@public.gmane.org>

Please either "select GPIOLIB" from USB_NET_SMSC95XX, or add a new
config option "UBS_NET_SMSC95XX_GPIO" which does it.  I would prefer
the former, and then you can get rid of all of the ifdefs in your
patch.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
