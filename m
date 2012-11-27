From: Steve Glendinning <steve-nksJyM/082jR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 1/2] smsc75xx: refactor entering suspend modes
Date: Tue, 27 Nov 2012 17:21:17 +0000
Message-ID: <CAKh2mn4OiN7ZAX_0SJ_XHwRNPoyKUk=+4ha5esBMAajGD4BX=w@mail.gmail.com>
References: <1354026482-10443-1-git-send-email-steve.glendinning@shawell.net>
	<1354026482-10443-2-git-send-email-steve.glendinning@shawell.net>
	<87624r9k1f.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87624r9k1f.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Bjorn,

>> +     smsc75xx_set_feature(dev, USB_DEVICE_REMOTE_WAKEUP);
>
> As mentioned in another comment to the smsc95xx driver: This is weird.
> Do you really need to do that?
>
> This is an USB interface driver.  The USB device is handled by the
> generic "usb" driver, which will do the right thing.  See
> drivers/usb/generic.c and drivers/usb/core/hub.c

Thanks, I've tested removing all these calls from the driver and
wakeup functionality seems to still work.

I'll resubmit my smsc75xx enhancement patchset with this change once
I've done some more testing.

David: please discard this patch.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
