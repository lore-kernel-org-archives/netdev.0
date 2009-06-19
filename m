From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [RFC] Documentation: add documentation for rc-series and merge
	window
Date: Sat, 20 Jun 2009 00:19:09 +0200
Message-ID: <20090619221909.GC2229@elf.ucw.cz>
References: <20090615214735.GE23972@bombadil.infradead.org> <20090615223206.GA4966@kroah.com> <20090616004122.GC5492@tesla> <20090616021011.GF23972@bombadil.infradead.org> <20090616032034.GA17932@kroah.com> <20090616042113.GA5680@tesla> <20090616093401.GA11602@jm.kir.nu> <20090616181705.GB31506@tesla> <20090619150015.GC1389@ucw.cz> <43e72e890906191010v4b2e79a5x2c7b722b8209933c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <j@w1.fi>,
	Luis Rodriguez <Luis.Rodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>,
	Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, "corbet-T1hC0tSOHrs@public.gmane.org" <corbet-T1hC0tSOHrs@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org" <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org" <tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org>
To: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <43e72e890906191010v4b2e79a5x2c7b722b8209933c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> >> +2.0.2: RC-SERIES RULES
> >> +
> >> +Rules on what kind of patches are accepted after the merge window closes.
> >> +These are patches targeted for the kernel rc-series of a kernel prior
> >> +to its release.
> >> +
> >> + - it must fix a reported regression
> >> + - it must fix a reported security hole
> >> + - it must fix a reported oops/kernel hang
> >
> > - it must fix a bug.
> 
> Well that's for certain, but there is a difference between a general
> notion of a bug and the type of bug fixes that should go in during the
> rc-series. This documentation patch highlights the difference.

Yes, and I'm trying to tell you that this documentation patch is
wrong.

Non-intrusive bugfixes _are_ welcome after -rc1.

> > I do not think the 'reported' requirement is there in -rc,
> 
> Well if its not reported how else would you find out about it during
> the rc-series? And if its something easily triggerable that should
> have been fixed earlier, not late in the rc-series.

'reported' means 'someone is hitting that bug' in that context. If you
do code inspection on drivers/foo/bar.c and find that it will hang on
may 13, 2017; then that's a bug but not "reported" one -- users are
not hitting it. Such bug may be uninteresting for -stable, but would
probably be ok for -rc.

> > and yes,
> > compile-fixes etc are welcome.
> 
> Sure, but what are these doing so late in the rc-series?

Bugs happen :-).

> > Non-intrusive bugfixes too, afaict.
> 
> It really depends on what you mean but generally no, and this is why I
> think this clarification is important.

I believe you are wrong.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
