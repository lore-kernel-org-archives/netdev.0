From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [usb regression] Re: [PATCH 2.6.24-rc3] Fix /proc/net breakage
Date: Wed, 2 Jan 2008 10:56:43 -0500 (EST)
Message-ID: <Pine.LNX.4.44L0.0801021052470.4861-100000@iolanthe.rowland.org>
References: <20080102060006.GA27693@kroah.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andreas Mohr <andi-5+Cda9B46AM@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>,
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
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080102060006.GA27693-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Jan 2008, Greg KH wrote:

> On Mon, Dec 31, 2007 at 11:26:43AM -0800, Greg KH wrote:
> > On Mon, Dec 31, 2007 at 12:49:52PM -0500, Alan Stern wrote:
> > > On Sun, 30 Dec 2007, Greg KH wrote:
> > > 
> > > > > It looks like Greg misused the debugfs API -- which is ironic, because
> > > > > he wrote debugfs in the first place!  :-)

> Ok, no, I didn't write that patch, I'm getting very confused here.
> 
> In 2.6.24-rc6 there is no usage of debugfs in the ohci driver.
> 
> In the -mm tree there is a patch, from Tony Jones, that moves some debug
> code out of sysfs and into debugfs where it belongs.  It does it for
> both the ehci and ohci USB host controller drivers, and this is the code
> that is incorrect if CONFIG_DEBUGFS is not enabled.

My mistake; I got the impression you had written that new code rather
than Tony.  BTW, I don't recall ever seeing Tony's patch announced on
linux-usb or linux-usb-devel.  Did I simply miss it?

> So, for the 2.6.24 release, nothing needs to be changed, all is good,
> and there is no regression.
> 
> Right?  Or am I still confused about this whole thing?

Correct.  The problem exists only in -mm and your development tree.

> I will go fix up Tony's patches in the -mm tree that do not handle the
> error return values from debugfs properly, but that is not such a rush,
> as Tony is on vacation for a few weeks, and those patches are going to
> be going in only after 2.6.24 is out.

The fix I posted earlier in this thread should simply be merged into 
Tony's patches.

Alan Stern

-
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
