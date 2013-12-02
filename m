From: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: net/usb/ax88179_178a driver broken in linux-3.12
Date: Mon, 2 Dec 2013 11:08:36 -0800
Message-ID: <20131202190836.GC3898@xanatos>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B742F@saturn3.aculab.com>
 <528A9A36.50903@pobox.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7431@saturn3.aculab.com>
 <20131119.161313.743887333007019981.davem@davemloft.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7439@saturn3.aculab.com>
 <20131120165420.GD9611@xanatos>
 <5299546B.2020800@pobox.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B744E@saturn3.aculab.com>
 <529CA1D2.2070806@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mark Lord <mlord-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <529CA1D2.2070806-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 02, 2013 at 10:05:54AM -0500, Mark Lord wrote:
> On 13-12-02 04:30 AM, David Laight wrote:
> >> From: Mark Lord
> >> Sent: 30 November 2013 02:59
> >> To: Sarah Sharp; David Laight
> >> Cc: David Miller; eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
> >> usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> >> Subject: Re: net/usb/ax88179_178a driver broken in linux-3.12
> >>
> >> On 13-11-19 08:44 AM, Mark Lord wrote:
> >>> On 13-11-19 05:04 AM, David Laight wrote:
> >>>>
> >>>> Which changes did you revert?
> >>>
> >>> Just the bits that changed how the headroom/tailroom sizes
> >>> were checked and adjusted.  See attachment for the revert patch
> >>> I am using here.  My mailer unfortunately likes to mangle inline patches.
> >>>
> > ...
> >>
> >> Two kernels later, and this regression has still not been fixed.
> >>
> >> A simple revert, folks.
> > 
> > Reverting the ax88179_178a driver doesn't fix the problem.
> > I'm seen tx/rx issues with it on much older kernels that don't
> > appear with a current kernel and the fixed xhci code.
> > 
> > Sarah needs to feed the xhci_ring.c fix through into stable.
> 
> Oh, I agree.  But Linus makes a MASSIVE distinction between things
> that have always been broken, and REGRESSIONS from the immediately
> prior kernel that can be tracked to a single update.
> 
> Let's see some action, here folks!

I'm working on it.  You will probably have to wait for -rc3, depending
on when Greg sends his next pull request.  I will Cc you on the pull
request and patch, which should be sent out today.

Sarah Sharp
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
