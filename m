From: "Chris Friesen" <cfriesen-ZIRUuHA3oDzQT0dZR+AlfA@public.gmane.org>
Subject: Re: 2.6.29-git13: Reported regressions from 2.6.28
Date: Thu, 16 Apr 2009 15:08:40 -0600
Message-ID: <49E79E58.9000606@nortel.com>
References: <n4io5wq70ZO.A.gzG.rFn2JB@chimera> <alpine.LFD.2.00.0904061443000.7443@localhost.localdomain> <200904070035.00784.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Natalie Protasevich <protasnb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Trenton Adams <trenton.d.adams-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200904070035.00784.rjw-KKrjLPT3xs0@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Rafael J. Wysocki wrote:
> On Monday 06 April 2009, Linus Torvalds wrote:
>> On Mon, 6 Apr 2009, Rafael J. Wysocki wrote:
>>> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13019
>>> Subject		: /proc/<pid>/maps offset output broken in 2.6.29
>>> Submitter	: "Chris Friesen" <cfriesen-ZIRUuHA3oDzQT0dZR+AlfA@public.gmane.org>
>>> Date		: 2009-04-01 23:18 (6 days old)
>>> References	: http://marc.info/?l=linuxppc-embedded&m=123862902916059&w=4
>>> Handled-By	: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
>> I don't think that's a regression, nor really a bug. It looks cosmetic, 
>> and likely to be fixed, but not really worth worrying about.
> 
> OK, I've dropped it from the list.

I'm okay with that.  The problem causes some backwards compatibility 
problems with existing apps that get confused by the large "offset" 
number.  The fix is going to cause problems too, but in a different way.

We'll work around it.

Chris
