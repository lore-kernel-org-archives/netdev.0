From: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH RFC 1/1] usb: Tell xhci when usb data might be	misaligned
Date: Thu, 30 Jan 2014 16:30:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6B553D@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6B5486@AcuExch.aculab.com>
 <20140130161721.25560.qmail@stuge.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: 'Peter Stuge' <peter-Y+HMSxxDrH8@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140130161721.25560.qmail-Y+HMSxxDrH8@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Peter Stuge 
...
> > code using libusb can generate arbitrarily long transfers that usually
> > get split into 8k fragments.
> 
> libusb splits transfers into 16k urbs, or doesn't with newer code
> when both kernel and libusb support scatter-gather.
> 
> > In fact libusb always uses 8k fragments.
> 
> Hm? Worst-case libusb-1.0 submits 16k urbs. libusb-0.1 I'm unsure
> about, but could check.
...
> Where's the 8k coming from?

My memory, I meant 16k :-(

	David



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
