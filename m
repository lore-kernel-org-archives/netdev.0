From: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [usb regression] Re: [PATCH 2.6.24-rc3] Fix /proc/net breakage
Date: Tue, 1 Jan 2008 23:14:31 -0800
Message-ID: <20080102071431.GA32357@kroah.com>
References: <20071231052500.GB4187@kroah.com> <Pine.LNX.4.44L0.0712311237150.7182-100000@iolanthe.rowland.org> <20071231192643.GA25341@kroah.com> <20080102060006.GA27693@kroah.com> <20080102061308.GB30929@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
	Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
	kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	"Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andreas Mohr <andi-5+Cda9B46AM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080102061308.GB30929-p/qQFhXj4MHA4IYVXhSI5GHfThorsUsI@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 02, 2008 at 07:13:08AM +0100, Andreas Mohr wrote:
> Hi,
> 
> On Tue, Jan 01, 2008 at 10:00:06PM -0800, Greg KH wrote:
> > Ok, no, I didn't write that patch, I'm getting very confused here.
> > 
> > In 2.6.24-rc6 there is no usage of debugfs in the ohci driver.
> > 
> > In the -mm tree there is a patch, from Tony Jones, that moves some debug
> > code out of sysfs and into debugfs where it belongs.  It does it for
> > both the ehci and ohci USB host controller drivers, and this is the code
> > that is incorrect if CONFIG_DEBUGFS is not enabled.
> > 
> > So, for the 2.6.24 release, nothing needs to be changed, all is good,
> > and there is no regression.
> > 
> > Right?  Or am I still confused about this whole thing?
> 
> Probably, since I also wasn't sure about this getting added to the
> post-2.6.23 regressions. I'd expect this problem to be -mm only myself,
> but then I didn't actively verify it in code (and I haven't tried -rc6
> proper on that machine yet either, build takes ages ;).
> OK, since I cannot really offer anything other than positive feelings about
> this being non-rc6 breakage, should I try -rc6 proper, too?

Please do, that would be very helpful.

As the code being discussed isn't even in Linus's tree, it's hard to see
how this could be a proposed fix for the regression :)

thanks,

greg k-h
-
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
