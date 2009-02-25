From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.29-rc6: Reported regressions from 2.6.28
Date: Thu, 26 Feb 2009 00:12:17 +0100
Message-ID: <200902260012.19083.rjw@sisk.pl>
References: <GVhknozYwrL.A.hiC.rozoJB@chimera> <20090224071550.GA10436@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Adam J. Richter" <adam@yggdrasil.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:58730 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762979AbZBYXMk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2009 18:12:40 -0500
In-Reply-To: <20090224071550.GA10436@elte.hu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 24 February 2009, Ingo Molnar wrote:
> 
> (note, the standalone mail of this bug entry did not make it out 
> for some reason.)

Hm, strange.  I certainly received it from one of the lists.

> * Rafael J. Wysocki <rjw@sisk.pl> wrote:
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12760
> > Subject		: 2.6.29-rc5 hanging at boot when CONFIG_LOCK_STAT=y
> > Submitter	: Adam J. Richter <adam@yggdrasil.com>
> > Date		: 2009-02-16 6:50 (8 days old)
> > References	: http://marc.info/?l=linux-kernel&m=123476768023893&w=4
> > Handled-By	: Ingo Molnar <mingo@elte.hu>
> 
> Here we came to the conclusion that this is some LILO bug with a 
> too large BSS section - that's one thing that CONFIG_LOCK_STAT 
> causes. Under Grub the same kernel image boots fine. So unless 
> Adam has new data that contradicts this i think we can close 
> this bug.

Thanks, closed.

Rafael
