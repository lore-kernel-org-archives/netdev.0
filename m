From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Tue, 17 Mar 2009 12:05:27 -0400
Message-ID: <20090317160527.GB6737@tuxdriver.com>
References: <1237140665.24621.2.camel@johannes.local> <alpine.LFD.2.00.0903151136310.3131@localhost.localdomain> <1237143683.24621.7.camel@johannes.local> <20090315202603.GA9077@elte.hu> <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com> <alpine.LFD.2.00.0903161250080.3082@localhost.localdomain> <b6a2187b0903161655q15437156qc926c8db37d8ba4b@mail.gmail.com> <20090317144802.GF3549@tuxdriver.com> <20090317152801.GA6737@tuxdriver.com> <20090317153924.GA21061@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090317153924.GA21061-X9Un+BFzKDI@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 17, 2009 at 04:39:24PM +0100, Ingo Molnar wrote:
> 
> * John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
> 
> > On Tue, Mar 17, 2009 at 10:48:02AM -0400, John W. Linville wrote:
> > > On Tue, Mar 17, 2009 at 07:55:49AM +0800, Jeff Chua wrote:
> > > > On Tue, Mar 17, 2009 at 3:57 AM, Linus Torvalds
> > > > <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> > > > 
> > > > > IOW, if you've pinpointed 71c11fb57b924c160297ccd9e1761db598d00ac2 as
> > > > > being bad, then you should go back and double-check that its parent
> > > > > (in this case 4607816f608b42a5379aca97ceed08378804c99f) is good.
> > > > > Because if it's parent is also bad, then that just means that you made
> > > > > some mistake in "git bisect".
> > > > > In this case, it really sounds like maybe you marked the parent good, even
> > > > > though you should have marked it bad.
> > > > 
> > > > I should have been more careful, just got thrown off during the last
> > > > few steps of the bisect. But with the bad association to the AP after
> > > > a57a59f247b651e8ed6d3eeb7e2f9d83b83134c9 (iwlwifi: remove implicit
> > > > direct scan), can someone suggest where to go from here?
> > > 
> > > The obvious question for me is did you try this?
> > > 
> > > 	git revert a57a59f247b651e8ed6d3eeb7e2f9d83b83134c9
> > 
> > Hmmm...more like this:
> > 
> > git revert 41bb73eeac5ff5fb217257ba33b654747b3abf11
> > git revert b23f99bcfa12c7b452f7ad201ea5921534d4e9ff
> > git revert 71c11fb57b924c160297ccd9e1761db598d00ac2
> > git revert 4607816f608b42a5379aca97ceed08378804c99f
> > git revert a57a59f247b651e8ed6d3eeb7e2f9d83b83134c9
> >  
> > This first one has a conflict -- just take the hunk.
> 
> Since you apparently have done this sequence and have
> resolved the conflict (which is hard to do for testers
> even in trivial cases) - would you mind to post the
> resulting combo patch for Jeff to test?

Since Jeff has been using git for bisect, I presumed he could handle
the reverts.  But if you think it is helpful:

	http://bugzilla.kernel.org/attachment.cgi?id=20567&action=view

Hth!

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
