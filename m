From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: 2.6.30-rc6: Reported regressions from 2.6.29
Date: Sat, 23 May 2009 02:10:33 +0200
Message-ID: <200905230210.34531.rjw@sisk.pl>
References: <_AjETDMbIoL.A.DcH.RYzDKB@chimera> <alpine.LFD.2.01.0905220926150.3555@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LFD.2.01.0905220926150.3555-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 22 May 2009, Linus Torvalds wrote:
> 
> On Sat, 16 May 2009, Rafael J. Wysocki wrote:
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13329
> > Subject		: cifs_close: NULL pointer dereference
> > Submitter	: Luca Tettamanti <kronos.it-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date		: 2009-05-16 16:28 (1 days old)
> > References	: http://marc.info/?l=linux-kernel&m=124249133701702&w=4
> 
> Fixed by 703a3b8e5c01cf6fb33c6d8dc99905f889a4e992.
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13298
> > Subject		: modprobe ipmi_si hangs under 2.6.30-rc5
> > Submitter	: Ferenc Wagner <wferi-eEbw3PyuezQ@public.gmane.org>
> > Date		: 2009-05-12 21:28 (5 days old)
> > References	: http://marc.info/?l=linux-kernel&m=124216379407177&w=4
> 
> Fixed by 9a2845c453d170e4e9b1437fa671dbf39b0e7bd8.
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13297
> > Subject		: kernel panic -  not syncing : fatel exception in interupt
> > Submitter	: rob <rob1-z2Ut7v/pTR/vt0rt8C/ehw@public.gmane.org>
> > Date		: 2009-05-12 19:34 (5 days old)
> > References	: http://marc.info/?l=linux-kernel&m=124216126903309&w=4
> 
> This should be fixed by e3b29f05124b07303088795396ff858811d2acb8.
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13177
> > Subject		: 2.6.30-rc2-git7 build problem
> > Submitter	: Martin Knoblauch <spamtrap-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
> > Date		: 2009-04-21 13:39 (26 days old)
> > References	: http://marc.info/?l=linux-kernel&m=124032163602132&w=4
> > 		  http://lkml.org/lkml/2009/4/27/56
> 
> This one really looks like a compiler bug (the undefined symbol is an 
> internal gcc one: ".L192"). And the driver that gets it (kl5kusb105) has 
> not actually had any changes since 2.6.29 - although header files that it 
> includes obviously do have some, so it's entirely possible that some 
> infrastructure change causes it to trigger.
> 
> Martin hit another bug with his compiler (an ICE in gcc, fixed by commit 
> 26a9a418237c0b06528941bca693c49c8d97edbe), which is why I'm so willing to 
> blame that.
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13107
> > Subject		: LTP 20080131 causes defunct processes w/2.6.30-rc1
> > Submitter	: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
> > Date		: 2009-04-09 15:43 (38 days old)
> > First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=b3bfa0cba867f23365b81658b47efd906830879b
> > References	: http://marc.info/?l=linux-kernel&m=123929187208953&w=4
> > 		  http://lkml.org/lkml/2009/4/10/193
> > Handled-By	: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> 
> This one seems to have become "not-a-bug". Yes, LTP used to check that you 
> cannot send SIGSTP to init, but people do want to send signals to init 
> (especially when they are inside pid-namespace containers), and as long as 
> it's only a LTP test that already got modified (and not some actual 
> real-life usage), I'm considering this a "test failed because it was 
> testing for behavior that we want to change" at least for now.

Thanks a lot, this really helps! :-)

I've closed all of the bugs above.

Best,
Rafael
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
