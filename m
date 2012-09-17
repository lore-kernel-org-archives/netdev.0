From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [RFC PATCH 3/3] usbnet: support runtime PM triggered by link change
Date: Mon, 17 Sep 2012 10:02:27 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6FF0@saturn3.aculab.com>
References: <1347731299-29898-1-git-send-email-ming.lei@canonical.com> <1347731299-29898-4-git-send-email-ming.lei@canonical.com> <3287943.Bzm0t1oGWG@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Greg Kroah-Hartman" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	"Fink Dmitry" <finik-l0cyMroinI0@public.gmane.org>, "Rafael Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	"Alan Stern" <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Oliver Neukum" <oneukum-l3A5Bk7waGM@public.gmane.org>,
	"Ming Lei" <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <3287943.Bzm0t1oGWG-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > +void usbnet_link_updated(struct usbnet *dev)
> > +{
> > +	complete(&dev->link_update_completion);
> > +}
> > +EXPORT_SYMBOL_GPL(usbnet_link_updated);
> 
> Isn't that a bit too trivial to get the _GPL version?

Particularly if the usb infrastructure (that I presume this
is part of) might be reasonably usable by non-gpl drivers.

A few years back the function to release a reference on
the kernel 'pid' structure was added as GPL - making
it impossible for non-GPL to hold the reference.

	David
 


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
