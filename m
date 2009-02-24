From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.29-rc6: Reported regressions from 2.6.28
Date: Tue, 24 Feb 2009 08:15:50 +0100
Message-ID: <20090224071550.GA10436@elte.hu>
References: <GVhknozYwrL.A.hiC.rozoJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Adam J. Richter" <adam@yggdrasil.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <GVhknozYwrL.A.hiC.rozoJB@chimera>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(note, the standalone mail of this bug entry did not make it out 
for some reason.)

* Rafael J. Wysocki <rjw@sisk.pl> wrote:

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12760
> Subject		: 2.6.29-rc5 hanging at boot when CONFIG_LOCK_STAT=y
> Submitter	: Adam J. Richter <adam@yggdrasil.com>
> Date		: 2009-02-16 6:50 (8 days old)
> References	: http://marc.info/?l=linux-kernel&m=123476768023893&w=4
> Handled-By	: Ingo Molnar <mingo@elte.hu>

Here we came to the conclusion that this is some LILO bug with a 
too large BSS section - that's one thing that CONFIG_LOCK_STAT 
causes. Under Grub the same kernel image boots fine. So unless 
Adam has new data that contradicts this i think we can close 
this bug.

	Ingo
