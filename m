From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [git patches] net driver fixes
Date: Tue, 16 Sep 2008 15:15:28 +0300
Message-ID: <20080916121528.GD7397@cs181140183.pp.htv.fi>
References: <20080916104811.GC7397@cs181140183.pp.htv.fi> <20080916114305.GB10965@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>,
	David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754557AbYIPMP7@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080916114305.GB10965@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 16, 2008 at 11:43:05AM +0000, Jarek Poplawski wrote:
> On 16-09-2008 12:48, Adrian Bunk wrote:
> > On Tue, Sep 16, 2008 at 12:40:14PM +0300, Adrian Bunk wrote:
> >> On Tue, Sep 16, 2008 at 11:18:08AM +0200, Thomas Bogendoerfer wrote:
> >>> On Tue, Sep 16, 2008 at 11:39:34AM +0300, Adrian Bunk wrote:
> >>>> On Mon, Sep 15, 2008 at 03:11:25PM -0700, David Miller wrote:
> >>>>> From: tsbogend@alpha.franken.de (Thomas Bogendoerfer)
> >>>>> Date: Mon, 15 Sep 2008 23:53:08 +0200
> >>>>>
> >>>>>> On Mon, Sep 15, 2008 at 02:14:42PM -0700, David Miller wrote:
> >>>>>>> Most of those changes were complete and utter CRAP.
> >>>>>> thank you, but the fix I've sent (de2104x) isn't crap. The bug breaks the 
> >>>>>> current debian-installer for Cobalt Qube1, when it tries to get an
> >>>>>> IP address via dhcp. 
> >>>>> And why is this bug that has been there for YEARS is appropriate
> >>>>> to fix outside of the merge window?
> >>>>> ...
> >>>> Such a fix is even suitable for -stable.
> >>> that was my feeling as well, but if David wants to see it in the next
> >>> merge window, it's his decision. It's not a important fix as the user
> >>> base is obviuosly pretty small. And I didn't know about that bug, when
> >>> the merge windows was open, so I couldn't fix it "in time".
> >> And if it goes in during the next merge window it can immediately go 
> >> into 2.6.27.1 (and even 2.6.26.y if it's still maintained), since the 
> >> fix fulfills Documentation/stable_kernel_rules.txt .
> >>
> >> That doesn't make sense.
> > 
> > Note that my emails are not meant against David personally - he just 
> > seems to have gotten from pushing too much to pushing too few, with
> > such illogical results.
> > 
> > cu
> > Adrian
> 
> Probably he can read.


I'm eagerly awaiting to slap this at Linus the next time he dares to 
directly apply a patch that only fixes a sparse warning outside of a 
merge window...  ;-)


More seriously, there's a difference between Linus' "another random 
improvement" and an "is even suitable for -stable".

I'm not reading Linus' (Cc'ed) statement the way that a patch that is 
appropriate for 2.6.27.1 is not appropriate for -rc now.

If I'm misreading Linus on this it might make sense if they'd discuss 
it at their current cabal meeting.


> Jarek P.
> 
> PS:
> 
> On 04-09-2008 01:24, Linus Torvalds wrote:
> > 
> > On Wed, 3 Sep 2008, Linus Torvalds wrote:
> >> What's so hard to understand about this?
> > 
> > Here's a simple rule of thumb:
> >  - if it's not on the regression list
> >  - if it's not a reported security hole
> >  - if it's not on the reported oopses list
> > then why are people sending it to me?
> > 
> > IOW, if it's just another random improvement, and you send it to me 
> > outside of the merge window, then what is the point of the merge window? 
> > 
> > 		Linus

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
