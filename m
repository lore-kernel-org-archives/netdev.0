From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: 2.6.30-rc2-git2: Reported regressions from 2.6.29
Date: Sat, 25 Apr 2009 23:57:53 +0200
Message-ID: <200904252357.55023.rjw@sisk.pl>
References: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera> <87ljpqqi89.fsf@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kalle Valo <kalle.valo-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87ljpqqi89.fsf-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 24 April 2009, Kalle Valo wrote:
> "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org> writes:
> 
> > This message contains a list of some regressions from 2.6.29, for
> > which there are no fixes in the mainline I know of. If any of them
> > have been fixed already, please let me know.
> >
> > If you know of any other unresolved regressions from 2.6.29, please
> > let me know either and I'll add them to the list. Also, please let
> > me know if any of the entries below are invalid.
> >
> > Each entry from the list will be sent additionally in an automatic reply to
> > this message with CCs to the people involved in reporting and handling the
> > issue.
> >
> 
> [...]
> 
> > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=13067
> > Subject         : iwl3945: wlan0: beacon loss from AP - sending probe request
> > Submitter       : Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date            : 2009-04-05 9:11 (12 days old)
> > References      : http://marc.info/?l=linux-kernel&m=123892272218266&w=4
> 
> The regression here is that I added a printk() to inform about beacon
> loss. The issue has been there a long time, the printk() just exposed
> it.
> 
> Michael wrote a patch which silences the printk:
> 
> http://git.kernel.org/?p=linux/kernel/git/linville/wireless-testing.git;a=commit;h=16eaea5faa37d552b14e246ca56a436e55ca67b3
> 
> I fixed the beacon loss detection here:
> 
> http://git.kernel.org/?p=linux/kernel/git/linville/wireless-testing.git;a=commit;h=3b6dc5a431e4fef35717cba53544a95209f49b68
> 
> John, I think Michael's patch should be sent to 2.6.30. Any chances
> for that?
> 
> Rafael, is it possible to send your regression mails to
> linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org as well? Very few wireless developers
> have time to follow netdev or lkml.

Sure, the next reports will go there too.

Best,
Rafael
