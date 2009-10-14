From: Greg KH <gregkh@suse.de>
Subject: Re: Moving drivers into staging (was Re: [GIT PULL] SCSI fixes for
	2.6.32-rc3)
Date: Tue, 13 Oct 2009 21:45:19 -0700
Message-ID: <20091014044519.GA19199@suse.de>
References: <alpine.LFD.2.01.0910081410400.3432@localhost.localdomain> <20091009091538.GA4154@elte.hu> <1255097287.2934.21.camel@localhost.localdomain> <20091012130652.GB25464@elte.hu> <1255357148.2850.91.camel@localhost.localdomain> <20091012145453.GD4565@elte.hu> <20091012150911.GB1656@suse.de> <20091012154244.GA13323@elte.hu> <20091012232429.GA24254@suse.de> <43e72e890910131108m789110b4hc35e25601ad67bb7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>,
	James Bottomley <James.Bottomley@suse.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Theodore Tso <tytso@mit.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Jing Huang <huangj@brocade.com>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752280AbZJNEqG@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <43e72e890910131108m789110b4hc35e25601ad67bb7@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 13, 2009 at 11:08:15AM -0700, Luis R. Rodriguez wrote:
> On Mon, Oct 12, 2009 at 4:24 PM, Greg KH <gregkh@suse.de> wrote:
> > On Mon, Oct 12, 2009 at 05:42:44PM +0200, Ingo Molnar wrote:
> >> Hm, i think i even gave drivers/staging/ its name?
> >
> > Yes you did, and I appreciate it :)
> >
> >> > [...] It seems that I'm the only one that has the ability to drop
> >> > drivers out of the kernel tree, which is a funny situation :)
> >>
> >> You are the only one who has the ability to send a warning shot towards
> >> drivers _without hurting users_, and by moving it into the focus of a
> >> team of cleanup oriented developers.
> >>
> >> I think that's an important distinction ;-)
> >
> > Good point.
> >
> >> > In thinking about this a lot more, I don't really mind it. ??If people
> >> > want to push stuff out of "real" places in the kernel, into
> >> > drivers/staging/ and give the original authors and maintainers notice
> >> > about what is going on, _and_ provide a TODO file for what needs to
> >> > happen to get the code back into the main portion of the kernel tree,
> >> > then I'll be happy to help out with this and manage it.
> >> >
> >> > I think a 6-9 month window (basically 3 kernel releases) should be
> >> > sufficient time to have a driver that has been in drivers/staging/ be
> >> > cleaned up enough to move back into the main kernel tree. ??If not, it
> >> > could be easily dropped.
> >> >
> >> > Any objections to this?
> >>
> >> Sounds excellent to me!
> >
> > Great, I'll await the patches to move stuff to drivers/staging/ now.
> >
> > Wireless developers, warm up your editors :)
> 
> OK -- prism54 seems like a good candidate, instead of removing it
> completely as I originally outlined on the feature removal schedule.
> Do we have a file to give notices to move drivers to staging because
> they are old as with the feature removal schedule? The more visible
> these things become the better it is for users.

We've found that the feature removal file is also ignored :)

How about when it was scheduled to be removed, we put it in staging and
I'll add it to my announcements about the staging tree every release?

Unless you can think of a better way?

thanks,

greg k-h
