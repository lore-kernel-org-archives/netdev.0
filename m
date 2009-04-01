From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] hso: add Vendor/Product ID's for new devices
Date: Wed, 01 Apr 2009 01:07:10 -0700 (PDT)
Message-ID: <20090401.010710.261741463.davem@davemloft.net>
References: <20090331115652.GA22106@raptor>
	<49D318E7.4050404@teltonika.lt>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <49D318E7.4050404-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Date: Wed, 01 Apr 2009 10:33:59 +0300

> Jan Dumon wrote:
> > @@ -462,9 +462,16 @@ static const struct usb_device_id hso_ids[] = {
> >  	{USB_DEVICE(0x0af0, 0x7701)},
> >  	{USB_DEVICE(0x0af0, 0x7801)},
> >  	{USB_DEVICE(0x0af0, 0x7901)},
> > -	{USB_DEVICE(0x0af0, 0x7361)},
> > -	{USB_DEVICE(0x0af0, 0xd057)},
> 
> Please add comment in description why you are removing these IDs.

This isn't the first time they've been asked to do this.

--------------------

Subject: Re: [PATCH] hso: add new device id's
From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: F.Aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
Cc: gregkh-l3A5Bk7waGM@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Date: Mon, 02 Feb 2009 16:33:00 -0800 (PST)
X-Mailer: Mew version 6.1 on Emacs 22.1 / Mule 5.0 (SAKAKI)

From: "Filip Aben" <F.Aben-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
Date: Tue, 3 Feb 2009 01:26:14 +0100

> > -----Original Message-----
> > From: David Miller [mailto:davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org]
> > Sent: maandag 2 februari 2009 23:03
> > To: Filip Aben
> > Cc: gregkh-l3A5Bk7waGM@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Subject: Re: [PATCH] hso: add new device id's
> > 
> > Why won't 0xaf0/0xd051 ever be used?
> > 
> > You should explain such things in your commit message,
> > that way I don't have to ask.
> 
> That ID was used in an internal engineering version of a device and 
> will never see commercial light.
> Even if this ID will be 'recycled' in the future, which is very
> unlikely, 
> I don't know what kind of device will be behind it. Therefore it's safer
> to remove it.

Great, please add that information to the commit message
and resend your patch.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
