From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.35-rc2-git2: Reported regressions from 2.6.34
Date: Wed, 9 Jun 2010 11:06:11 +0200
Message-ID: <201006091106.11232.rjw@sisk.pl>
References: <Rlf_Qjov7bG.A.a8F.I8rDMB@chimera>
	<alpine.LFD.2.00.1006081814240.4506@i5.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Venkatesh Pallipadi <venki@google.com>,
	DRI <dri-devel@lists.sourceforge.net>,
	Mauro Carvalho Chehab <mchehab@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux ACPI <linux-acpi@vger.kernel.org>, Jens Axboe <jaxboe@fusionio.com>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>, David,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Carl Worth <cworth@cworth.org>,
	=?iso-8859-15?q?H=E4rdeman?= <david@hardeman.nu>,
	Network Development <netdev@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <dri-devel-bounces@lists.sourceforge.net>
In-Reply-To: <alpine.LFD.2.00.1006081814240.4506@i5.linux-foundation.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=dri-devel>
List-Post: <mailto:dri-devel@lists.sourceforge.net>
List-Help: <mailto:dri-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: dri-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wednesday 09 June 2010, Linus Torvalds wrote:
> 
> [ Added lots of cc's to direct specific people to look at the regressions 
>   that may or may not be theirs... ]
> 
> On Wed, 9 Jun 2010, Rafael J. Wysocki wrote:
> >
> >  * Quite a few of the already reported regressions may be related to the bug
> >    fixed by 386f40c86d6c8d5b717ef20620af1a750d0dacb4 (Revert "tty: fix a little
> >    bug in scrup, vt.c"), so reporters please retest with this commit applied.]
> 
> From a quick look, most of them look unrelated to that unfortunate bug. 
> It's hard to tell for sure, of course (memory corruption can do pretty 
> much anything), but I'm not seeing the 07200720.. pattern at least.
> 
> And some of them do seem to be bisected to likely culprits and/or have 
> patches that are claimed to have fixed them.
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16163
> > Subject	: [2.6.35-rc1 Regression] i915: Commit cfecde causes VGA to stay off
> > Submitter	: David John <davidjon@xenontk.org>
> > Date		: 2010-06-02 12:52 (7 days old)
> > Message-ID	: <4C065423.3000202@xenontk.org>
> > References	: http://marc.info/?l=linux-kernel&m=127548313828613&w=2
> 
> That has a "reverting the commit fixes it", and a confirmation from Nick 
> Bowler.
> 
> Eric, Carl: should I just revert that commit? Or do you have a fix?

This one is reported to have been fixed already.  Closed now.

...
> 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16104
> > Subject	: Radeon KMS does not start after merge of the new PM-Code
> > Submitter	: Jan Kreuzer <kontrollator@gmx.de>
> > Date		: 2010-06-02 07:47 (7 days old)
> 
> This one also has a patch in Bugzilla, I think Airlie is just waiting to 
> calm down his queue and already removed the dependency on the temperature 
> code. DaveA?

This should be fixed by commit f8ed8b4c5d30b5214f185997131b06e35f6f7113, so
closing now.

Rafael

------------------------------------------------------------------------------
ThinkGeek and WIRED's GeekDad team up for the Ultimate 
GeekDad Father's Day Giveaway. ONE MASSIVE PRIZE to the 
lucky parental unit.  See the prize list and enter to win: 
http://p.sf.net/sfu/thinkgeek-promo
--
