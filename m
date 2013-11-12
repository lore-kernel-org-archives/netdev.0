From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH] usb: xhci: Link TRB must not occur with a USB payload burst.
Date: Tue, 12 Nov 2013 17:28:42 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7409@saturn3.aculab.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B73EF@saturn3.aculab.com> <AE90C24D6B3A694183C094C60CF0A2F6026B73F1@saturn3.aculab.com> <20131112171549.GB4925@xanatos>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Sarah Sharp" <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <20131112171549.GB4925@xanatos>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> On Fri, Nov 08, 2013 at 11:07:41AM -0000, David Laight wrote:
> > > While this change improves things a lot (it runs for 20 minutes rather than
> > > a few seconds), there is still something else wrong.
> >
> > Almost certainly caused by an unrelated local change.
> 
> Ok, good, I was concerned there was another issue we were missing.

My modified code wasn't setting the td_size properly.
That is fixed and verified in the later patch I sent.

	David



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
