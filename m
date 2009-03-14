From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: 2.6.29-rc8: Reported regressions 2.6.27 -> 2.6.28
Date: Sat, 14 Mar 2009 20:11:53 +0100 (CET)
Message-ID: <9nR7rAsBwYG.A.iEG.fOCvJB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux SCSI List <linux-scsi@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Natalie Protasevich <protasnb@gmail.com>,
        Stable Kernel Team <stable@kernel.org>,
        Linux ACPI <linux-acpi@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Kernel Testers List <kernel-testers@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Linux PM List <linux-pm@lists.linux-foundation.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

This message contains a list of some regressions introduced between 2.6.27 and
2.6.28, for which there are no fixes in the mainline I know of.  If any of them
have been fixed already, please let me know.

If you know of any other unresolved regressions introduced between 2.6.27
and 2.6.28, please let me know either and I'll add them to the list.
Also, please let me know if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply to
this message with CCs to the people involved in reporting and handling the
issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2009-03-14      156       19          16
  2009-03-03      153       21          16
  2009-02-24      154       27          23
  2009-02-15      152       30          26
  2009-02-04      149       33          30
  2009-01-20      144       30          27
  2009-01-11      139       33          30
  2008-12-21      120       19          17
  2008-12-13      111       14          13
  2008-12-07      106       20          17
  2008-12-04      106       29          21
  2008-11-22       93       25          15
  2008-11-16       89       32          18
  2008-11-09       73       40          27
  2008-11-02       55       41          29
  2008-10-25       26       25          20


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12868
Subject		: iproute2 and regressing "ipv6: convert tunnels to net_device_ops"
Submitter	: Jan Engelhardt <jengelh@medozas.de>
Date		: 2009-03-09 14:46 (6 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1326c3d5a4b792a2b15877feb7fb691f8945d203
References	: http://marc.info/?l=linux-netdev&m=123660999632730&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12818
Subject		: iwlagn broken after suspend to RAM (iwlagn: MAC is in deep sleep!)
Submitter	: Stefan Seyfried <seife@suse.de>
Date		: 2009-03-04 08:32 (11 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12690
Subject		: DPMS (LCD powersave, poweroff) don't work
Submitter	: Antonin Kolisek <akolisek@linuxx.hyperlinx.cz>
Date		: 2009-02-11 09:40 (32 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12645
Subject		: DMI low-memory-protect quirk causes resume hang on Samsung NC10
Submitter	: Patrick Walton <pcwalton@cs.ucla.edu>
Date		: 2009-02-06 18:35 (37 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=0af40a4b1050c050e62eb1dc30b82d5ab22bf221


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12634
Subject		: video distortion and lockup with i830 video chip and 2.6.28.3
Submitter	: Bob Raitz <pappy_mcfae@yahoo.com>
Date		: 2009-02-04 21:10 (39 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12619
Subject		: Regression 2.6.28 and last - boot failed
Submitter	: jan sonnek <ha2nny@gmail.com>
Date		: 2009-02-01 19:59 (42 days old)
References	: http://marc.info/?l=linux-kernel&m=123351836213969&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12500
Subject		: r8169: NETDEV WATCHDOG: eth0 (r8169): transmit timed out
Submitter	: Justin Piszcz <jpiszcz@lucidpixels.com>
Date		: 2009-01-13 21:19 (61 days old)
References	: http://marc.info/?l=linux-kernel&m=123188160811322&w=4
Handled-By	: Francois Romieu <romieu@fr.zoreil.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12465
Subject		: KVM guests stalling on 2.6.28 (bisected)
Submitter	: Kevin Shanahan <kmshanah@ucwb.org.au>
Date		: 2009-01-17 03:37 (57 days old)
Handled-By	: Avi Kivity <avi@redhat.com>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12426
Subject		: TMDC Joystick no longer works in kernel 2.6.28
Submitter	: Andrew S. Johnson <andy@asjohnson.com>
Date		: 2009-01-10 21:53 (64 days old)
First-Bad-Commit: http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=6902c0bead4ce266226fc0c5b3828b850bdc884a
References	: http://marc.info/?l=linux-kernel&m=123162486415366&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12421
Subject		: GPF on 2.6.28 and 2.6.28-rc9-git3, e1000e and e1000 issues
Submitter	: Doug Bazarnic <doug@bazarnic.net>
Date		: 2009-01-09 21:26 (65 days old)
References	: http://marc.info/?l=linux-kernel&m=123153653120204&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12411
Subject		: 2.6.28: BUG in r8169
Submitter	: Andrey Vul <andrey.vul@gmail.com>
Date		: 2008-12-31 18:37 (74 days old)
References	: http://marc.info/?l=linux-kernel&m=123074869611409&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12404
Subject		: Oops in 2.6.28-rc9 and -rc8 -- mtrr issues / e1000e
Submitter	: Kernel <kernel@bazarnic.net>
Date		: 2008-12-22 9:37 (83 days old)
References	: http://marc.info/?l=linux-kernel&m=122993873320150&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12337
Subject		: ~100 extra wakeups reported by powertop
Submitter	: Alberto Gonzalez <luis6674@yahoo.com>
Date		: 2008-12-31 12:25 (74 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12209
Subject		: oldish top core dumps (in its meminfo() function)
Submitter	: Andreas Mohr <andi@lisas.de>
Date		: 2008-12-12 18:49 (93 days old)
References	: http://marc.info/?l=linux-kernel&m=122910784006472&w=4
		  http://marc.info/?l=linux-kernel&m=122907511319288&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12208
Subject		: uml is very slow on 2.6.28 host
Submitter	: Miklos Szeredi <miklos@szeredi.hu>
Date		: 2008-12-12 9:35 (93 days old)
References	: http://marc.info/?l=linux-kernel&m=122907463518593&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12061
Subject		: snd_hda_intel: power_save: sound cracks on powerdown
Submitter	: Jens Weibler <bugzilla-kernel@jensthebrain.de>
Date		: 2008-11-18 12:07 (117 days old)
Handled-By	: Takashi Iwai <tiwai@suse.de>


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12835
Subject		: Regression in backlight detection
Submitter	: Michael Spang <mspang@csclub.uwaterloo.ca>
Date		: 2009-02-24 5:41 (19 days old)
References	: http://marc.info/?l=linux-kernel&m=123545411502396&w=4
Handled-By	: Michael Spang <mspang@csclub.uwaterloo.ca>
Patch		: http://marc.info/?l=linux-kernel&m=123545411502396&w=4


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12798
Subject		: No wake up after suspend.
Submitter	: Michal Graczyk <zazulas@gmail.com>
Date		: 2009-03-01 15:30 (14 days old)
Handled-By	: Zhang Rui <rui.zhang@intel.com>
Patch		: http://bugzilla.kernel.org/attachment.cgi?id=20402&action=view


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=12612
Subject		: hard lockup when interrupting cdda2wav
Submitter	: Matthias Reichl <hias@horus.com>
Date		: 2009-01-28 16:41 (46 days old)
References	: http://marc.info/?l=linux-kernel&m=123316111415677&w=4
Handled-By	: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Patch		: http://marc.info/?l=linux-scsi&m=123371501613019&w=2


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions introduced
between 2.6.27 and 2.6.28, unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=11808

Please let me know if there are any Bugzilla entries that should be added to
the list in there.

Thanks,
Rafael
