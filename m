From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.31-rc5: Reported regressions from 2.6.30
Date: Sun, 2 Aug 2009 15:22:01 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0908021456430.3352@localhost.localdomain>
References: <Su1q3S6JjyO.A.jeB.hcgdKB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>, DRI <dri-devel@lists.sourceforge.net>,
        Linux SCSI List <linux-scsi@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Natalie Protasevich <protasnb@gmail.com>,
        Linux ACPI <linux-acpi@vger.kernel.org>,
        Mikael Pettersson <mikpe@it.uu.se>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kernel Testers List <kernel-testers@vger.kernel.org>,
        Linux PM List <linux-pm@lists.linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
In-Reply-To: <Su1q3S6JjyO.A.jeB.hcgdKB@chimera>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org



On Sun, 2 Aug 2009, Rafael J. Wysocki wrote:
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13896
> Subject		: 2.6.31-rc4 broke expect and gcc's testsuite
> Submitter	: Mikael Pettersson <mikpe@it.uu.se>
> Date		: 2009-07-29 11:00 (5 days old)
> References	: http://marc.info/?l=linux-kernel&m=124885806406520&w=4

I bet this is the same tty bug that got fixed by Ogawa in commit 
e043e42bdb. -rc5 has that fix. Mikael?

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13842
> Subject		: Oops when writing to /sys/block/ram0/queue/max_sectors_kb
> Submitter	: Jens Rosenboom <jens@mcbone.net>
> Date		: 2009-07-23 15:30 (11 days old)
> References	: http://marc.info/?l=linux-kernel&m=124836574403032&w=4

Commit a4e7d46407d73f35d217013b363b79a8f8eafcaa fixed this one.

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13826
> Subject		: thinkpad boots with backlight low
> Submitter	: Pavel Machek <pavel@ucw.cz>
> Date		: 2009-07-15 15:13 (19 days old)
> References	: http://marc.info/?l=linux-kernel&m=124756359126830&w=4
> Handled-By	: Henrique de Moraes Holschuh <hmh@hmh.eng.br>

This should be commit 59fe4fe34d7afdf63208124f313be9056feaa2f4.

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13815
> Subject		: emacs -nw compilation doesn't show the error message
> Submitter	: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Date		: 2009-07-23 06:22 (11 days old)
> First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=d945cb9cce20ac7143c2de8d88b187f62db99bdc

Same old pty bug, same fix: commit e043e42bdb.

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13813
> Subject		: Hangups in n_tty_read()
> Submitter	: Johannes Weiner <hannes@cmpxchg.org>
> Date		: 2009-07-16 18:48 (18 days old)
> References	: http://marc.info/?l=linux-kernel&m=124777019920579&w=4

Hmm. Worth testing that same fix, although the symptoms here are not 
exactly the same.

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13812
> Subject		: Ooops on uplug
> Submitter	: Daniel Mack <daniel@caiaq.de>
> Date		: 2009-07-20 17:51 (14 days old)
> References	: http://marc.info/?l=linux-kernel&m=124811234302786&w=4
> Handled-By	: Alan Stern <stern@rowland.harvard.edu>
> 		  Alan Cox <alan@linux.intel.com>

Commit c56d3000861 should fix this.

> Regressions with patches
> ------------------------
> 
> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13891
> Subject		: PCI resources allocation problem on HP nx6325
> Submitter	: Rafael J. Wysocki <rjw@sisk.pl>
> Date		: 2009-08-02 13:37 (1 days old)
> Handled-By	: Linus Torvalds <torvalds@linux-foundation.org>
> Patch		: http://patchwork.kernel.org/patch/38774/

Ok, this is committed as 79896cf42f6a96d7e14f2dc3473443d68d74031d.

> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=13825
> Subject		: eeepc-laptop: fix hot-unplug on resume
> Submitter	: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
> Date		: 2009-06-29 13:12 (35 days old)
> References	: http://lkml.org/lkml/2009/6/29/150
> Handled-By	: Alan Jenkins <alan-jenkins@tuffmail.co.uk>
> Patch		: http://patchwork.kernel.org/patch/32926/

commit 7334546a52c6764df120459509b1f803a073eacc

		Linus
