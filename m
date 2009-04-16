From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.29-git13: Reported regressions from 2.6.28
Date: Thu, 16 Apr 2009 14:35:45 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904161432000.4042@localhost.localdomain>
References: <n4io5wq70ZO.A.gzG.rFn2JB@chimera> <alpine.LFD.2.00.0904061443000.7443@localhost.localdomain> <200904070035.00784.rjw@sisk.pl> <49E79E58.9000606@nortel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Trenton Adams <trenton.d.adams@gmail.com>
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <49E79E58.9000606@nortel.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 16 Apr 2009, Chris Friesen wrote:
> 
> I'm okay with that.  The problem causes some backwards compatibility problems
> with existing apps that get confused by the large "offset" number.  The fix is
> going to cause problems too, but in a different way.
> 
> We'll work around it.

If you have actual apps that care, that's a different issue.

We do try to bend over backwards on ABI issues if it really is noticeable 
for applications. Now, in this case, if you can just fix your app to not 
care (because it really was badly written in the first place to even 
notice), then that is the _much_ superior solution.

But if you actually have binary-only commercial apps that break, we'll do 
a compatibility thing rather than the 0 that already got merged.

Although I don't really even see what we can sanely do except for the 0 
case. We could put the virtual address in there instead of zero (I forget 
what old kernels used to do - whatever magic value the anonymous mappings 
got, it wasn't really designed as an important value in its own right, it 
was designed to trigger the "we can merge these vma's" logic.

			Linus
