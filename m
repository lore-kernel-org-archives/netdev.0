From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH 4/5] smsc95xx: refactor entering suspend modes
Date: Mon, 26 Nov 2012 14:48:40 +0100
Message-ID: <874nkcscef.fsf@nemi.mork.no>
References: <1353607526-19307-1-git-send-email-steve.glendinning@shawell.net>
	<1353607526-19307-5-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1353607526-19307-5-git-send-email-steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org>
	(Steve Glendinning's message of "Thu, 22 Nov 2012 18:05:25 +0000")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[adding linux-usb to CC as this is very USB specific]

Steve Glendinning <steve.glendinning-nksJyM/082jR7s880joybQ@public.gmane.org> writes:

> +	smsc95xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);

That does look a bit strange to me.  This is a USB interface driver.
The USB device is handled by the generic "usb" USB device driver, which
will DTRT for you.  I don't think you need to set any USB device
features here.

Sorry for not commenting on this earlier.... It took me a while to
understand why that part surprised me.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
