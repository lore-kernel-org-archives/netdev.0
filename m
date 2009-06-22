From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Subject: Re: [PATCH] Documentation: add documentation summary for rc-series
	and merge window
Date: Mon, 22 Jun 2009 23:15:40 +0200
Message-ID: <20090622211540.GD24236@elf.ucw.cz>
References: <20090622180438.GG23972@bombadil.infradead.org> <20090622204500.GB24236@elf.ucw.cz> <43e72e890906221411od16be51k2fc811dbf223ed9f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>,
	"corbet-T1hC0tSOHrs@public.gmane.org" <corbet-T1hC0tSOHrs@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org" <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org" <tshibata-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org>
To: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <43e72e890906221411od16be51k2fc811dbf223ed9f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon 2009-06-22 14:11:45, Luis R. Rodriguez wrote:
> On Mon, Jun 22, 2009 at 1:45 PM, Pavel Machek<pavel-+ZI9xUNit7I@public.gmane.org> wrote:
> > On Mon 2009-06-22 14:04:38, Luis R. Rodriguez wrote:
> >> This is losely based on previous discussions on linux-kernel [1][2][3].
> >> Lets also refer people reading the stable rules to
> >> Documentation/development-process/.
> >>
> >> Also add the number of days it has taken between releases,
> >> and provide the average for the last 10 releases: 86.0 days.
> >>
> >> [1] http://marc.info/?l=linux-kernel&m=122048427801324&w=2
> >> [2] http://marc.info/?l=linux-netdev&m=122048757705315&w=2
> >> [3] http://marc.info/?l=linux-kernel&m=124515657407679&w=2
> >>
> >> Signed-off-by: Luis R. Rodriguez <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
> > NAK.
> >
> >> +2.0.2: RC-SERIES RULES
> >> +
> >> +This section summarizes what kind of patches are accepted before the merge
> >> +window closes and after it closes. These patches are targeted for the kernel
> >> +prior to its final release.
> >> +
> >> +The rc-series focus should really be to address regressions.
> >> +
> >> +2.0.2.0: RC-SERIES RULES PRIOR TO THE RC1 RELEASE
> >> +
> >> +These are the types of patches that will get accepted prior to a kernel rc1 release,
> >> +during the merge window:
> >> +
> >> + - it must fix a regression
> >> + - it must fix a security hole
> >> + - it must fix a oops/kernel hang
> >> +
> >> +Non-intrusive bug fixes or small fixes will not be accepted. If the
> >> patch in
> >
> > What? Prior to rc1, new features are accepted.
> 
> For maintainers yes, for developers sending to the subsystem
> maintainer no, at least not for that kernel release being worked on. I
> can try to make this a little clearer.

Yes, it would be good if it was clearer.

If maintainer accepts non-intrusive bugfixes during merge window is
pretty much his decision, I'd say. I'd expect him to take them if he
has bandwidth available.
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
