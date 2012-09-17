From: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: Re: [RFC PATCH 3/3] usbnet: support runtime PM triggered by link
 change
Date: Mon, 17 Sep 2012 04:15:09 -0700
Message-ID: <20120917111509.GA28340@kroah.com>
References: <1347731299-29898-1-git-send-email-ming.lei@canonical.com>
 <1347731299-29898-4-git-send-email-ming.lei@canonical.com>
 <3287943.Bzm0t1oGWG@linux-lqwf.site>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6FF0@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Fink Dmitry <finik-l0cyMroinI0@public.gmane.org>, Rafael Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FF0-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 17, 2012 at 10:02:27AM +0100, David Laight wrote:
> > > +void usbnet_link_updated(struct usbnet *dev)
> > > +{
> > > +	complete(&dev->link_update_completion);
> > > +}
> > > +EXPORT_SYMBOL_GPL(usbnet_link_updated);
> > 
> > Isn't that a bit too trivial to get the _GPL version?
> 
> Particularly if the usb infrastructure (that I presume this
> is part of) might be reasonably usable by non-gpl drivers.

It can not be, and has not been able to, for quite a number of years now
(since the 2.6.15 kernel release or so I think.)  So this should not be
an issue.

greg k-h
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
