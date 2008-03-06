From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [patch (for 2.6.25?) 2/2] bluetooth: CONWISE Technology based
 adapters with buggy SCO support (bugzilla #9027)
Date: Wed, 05 Mar 2008 18:44:03 -0800 (PST)
Message-ID: <20080305.184403.58829596.davem@davemloft.net>
References: <200803042258.m24Mw8UK001381@imap1.linux-foundation.org>
	<CAB9A765-5115-4F9F-A867-44E0CDECF86F@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	sdiz-A7iEm+J7xfE@public.gmane.org
To: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAB9A765-5115-4F9F-A867-44E0CDECF86F-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Date: Wed, 5 Mar 2008 09:46:19 +0100

> Hi Andrew,
> 
> > diff -puN drivers/bluetooth/hci_usb.c~bluetooth-conwise-technology- 
> > based-adapters-with-buggy-sco-support-bugzilla-9027 drivers/ 
> > bluetooth/hci_usb.c
> > --- a/drivers/bluetooth/hci_usb.c~bluetooth-conwise-technology-based- 
> > adapters-with-buggy-sco-support-bugzilla-9027
> > +++ a/drivers/bluetooth/hci_usb.c
> > @@ -148,6 +148,9 @@ static struct usb_device_id blacklist_id
> > 	{ USB_DEVICE(0x0400, 0x0807), .driver_info = HCI_BROKEN_ISOC },
> > 	{ USB_DEVICE(0x0400, 0x080a), .driver_info = HCI_BROKEN_ISOC },
> >
> > +	/* CONWISE Technology based adapters with buggy SCO support */
> > +	{ USB_DEVICE(0x0e5e, 0x6622), .driver_info = HCI_BROKEN_ISOC },
> 
> this is the one with the proper description and acked by me. Please  
> drop the other one.

I've added this to net-2.6
--
To unsubscribe from this list: send the line "unsubscribe linux-bluetooth" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
