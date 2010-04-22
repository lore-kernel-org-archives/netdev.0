From: Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>
Subject: Re: Subject: re-submit4 [ANNOUNCEMENT] NET: usb: sierra_net.c
	driver
Date: Thu, 22 Apr 2010 16:16:48 -0700
Message-ID: <1271978208.12776.7.camel@Linuxdev4-laptop>
References: <1271963973.10035.6.camel@Linuxdev4-laptop>
	 <20100422194435.GA14544@kroah.com>
	 <1271970906.26097.72.camel@localhost.localdomain>
	 <20100422222723.GB3187@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org" <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Rory Filer <rfiler-usJ8hg9QsBLWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100422222723.GB3187-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-04-22 at 15:27 -0700, Greg KH wrote:

> > > > +
> > > > +	status = usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
> > > > +			USB_CDC_SEND_ENCAPSULATED_COMMAND,
> > > > +			USB_DIR_OUT|USB_TYPE_CLASS|USB_RECIP_INTERFACE,	0,
> > > > +			priv->ifnum, cmd, cmdlen, 0);
> > > 
> > > No timeout?
Good catch. Will fix.

> > > No timeout?
Will fix.
> > > 
> > > > +		if (unlikely(len < 0)) {
> > > > +			netdev_err(dev->net,
> > > > +				"usb_control_msg failed, status %d\n", len);
> > > 
> > > You don't need "unlikely", this is an extreemly slow path here.
Will fix.

> Well, if the return value is less than what you expect it to be,
> something went wrong and you should error out.  Some of the calls handle
> this properly in this driver, some do not.  Consistency is key :)
Good point. Thanks. Will check for consistency and resubmit.

Elina


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
