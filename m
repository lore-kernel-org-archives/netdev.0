From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.35-rc3: Reported regressions from 2.6.34
Date: Mon, 21 Jun 2010 20:54:45 +0200
Message-ID: <201006212054.46055.rjw@sisk.pl>
References: <lc60d4toGTL.A.QzD._LpHMB@chimera> <1277074706.21312.8.camel@maxim-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1277074706.21312.8.camel@maxim-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, June 21, 2010, Maxim Levitsky wrote:
> On Mon, 2010-06-21 at 00:11 +0200, Rafael J. Wysocki wrote: 
> > This message contains a list of some regressions from 2.6.34,
> > for which there are no fixes in the mainline known to the tracking team.
> > If any of them have been fixed already, please let us know.
> > 
> > If you know of any other unresolved regressions from 2.6.34, please let us
> > know either and we'll add them to the list.  Also, please let us know
> > if any of the entries below are invalid.
> > 
> > Each entry from the list will be sent additionally in an automatic reply
> > to this message with CCs to the people involved in reporting and handling
> > the issue.
> > 
> > 
> > Listed regressions statistics:
> > 
> >   Date          Total  Pending  Unresolved
> >   ----------------------------------------
> >   2010-06-21       46       37          26
> >   2010-06-09       15       13          10
> > 
> > 
> > Unresolved regressions
> > ----------------------
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16255
> > Subject		: 2.6.35-rc3 deadlocks on semaphore operations
> > Submitter	: Christoph Lameter <cl@linux-foundation.org>
> > Date		: 2010-06-18 14:49 (3 days old)
> > Message-ID	: <alpine.DEB.2.00.1006180940140.11575@router.home>
> > References	: http://marc.info/?l=linux-kernel&m=127687262727707&w=2
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16248
> > Subject		: inconsistent lock state
> > Submitter	: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Date		: 2010-06-15 11:24 (6 days old)
> > Message-ID	: <20100615112434.GA3967@swordfish.minsk.epam.com>
> > References	: http://marc.info/?l=linux-kernel&m=127660087625903&w=2
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16247
> > Subject		: drm/i915 BUG with 2.6.35-rc
> > Submitter	: Benny Halevy <bhalevy@panasas.com>
> > Date		: 2010-06-14 22:38 (7 days old)
> > Message-ID	: <4C16AF56.1040002@panasas.com>
> > References	: http://marc.info/?l=linux-kernel&m=127655510531367&w=2
> 
> 
> Don't have time to test, but I confirm that running compiz without
> mode-setting (ubuntu 8.10) hangs the system. (device is i945)
> It might be related to few intel regressions on this list.
> 
> 
> 
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16235
> > Subject		: [REGRESSION] [IWL3945] Broadcast is broken?
> > Submitter	: Maciej Rutecki <maciej.rutecki@gmail.com>
> > Date		: 2010-06-14 17:24 (7 days old)
> > Message-ID	: <201006141924.24061.maciej.rutecki@gmail.com>
> > References	: http://marc.info/?l=linux-kernel&m=127653628301300&w=2
> I was hit by this bug. Fix is now present in iwlwifi tree.
> http://git.kernel.org/?p=linux/kernel/git/iwlwifi/iwlwifi-2.6.git;a=commit;h=4d23e4e5eb50431426facf192354ad2506e2dd40
> 
> 
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16234
> > Subject		: [2.6.35-rc3] reboot mutex 'bug'...
> > Submitter	: Daniel J Blueman <daniel.blueman@gmail.com>
> > Date		: 2010-06-14 15:16 (7 days old)
> > Message-ID	: <AANLkTimDcTnyEPmt2ZcCM1UWtn4AYKotiqyjobJApkO7@mail.gmail.com>
> > References	: http://marc.info/?l=linux-kernel&m=127652861118933&w=2
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16232
> > Subject		: 2.6.35-rc3 - WARNING:iwl_set_dynamic_key
> > Submitter	: Mario Guenterberg <mario.guenterberg@googlemail.com>
> > Date		: 2010-06-14 11:55 (7 days old)
> > Message-ID	: <20100614115510.GA7904@guenti-laptop>
> > References	: http://marc.info/?l=linux-kernel&m=127651695627147&w=2
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16230
> > Subject		: inconsistent IN-HARDIRQ-W -> HARDIRQ-ON-W usage: fasync, 2.6.35-rc3
> > Submitter	: Dominik Brodowski <linux@dominikbrodowski.net>
> > Date		: 2010-06-13 9:53 (8 days old)
> > Message-ID	: <20100613095305.GA13231@comet.dominikbrodowski.net>
> > References	: http://marc.info/?l=linux-kernel&m=127642282208277&w=2
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16228
> > Subject		: BUG/boot failure on Dell Precision T3500 (pci/ahci_stop_engine)
> > Submitter	: Brian Bloniarz <phunge0@hotmail.com>
> > Date		: 2010-06-16 17:57 (5 days old)
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16222
> > Subject		: 2.6.35-rc{12} regression: inactive console corrupted
> > Submitter	: Pavel Machek <pavel@ucw.cz>
> > Date		: 2010-06-12 10:33 (9 days old)
> > Message-ID	: <20100612103321.GA1458@ucw.cz>
> > References	: http://marc.info/?l=linux-kernel&m=127633882614501&w=2
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16221
> > Subject		: 2.6.35-rc2-git5 -- [drm:drm_mode_getfb] *ERROR* invalid framebuffer id
> > Submitter	: Miles Lane <miles.lane@gmail.com>
> > Date		: 2010-06-11 20:31 (10 days old)
> > Message-ID	: <AANLkTim0jVRyqkwlGOcrg_XTvUQwcBYfWJX-aRzkkrLG@mail.gmail.com>
> > References	: http://marc.info/?l=linux-kernel&m=127628828119623&w=2
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16205
> > Subject		: acpi: freeing invalid memtype bf799000-bf79a000
> > Submitter	: Marcin Slusarz <marcin.slusarz@gmail.com>
> > Date		: 2010-06-09 20:09 (12 days old)
> > Message-ID	: <20100609200910.GA2876@joi.lan>
> > References	: http://marc.info/?l=linux-kernel&m=127611427029914&w=2
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16201
> > Subject		: SIOCGIWFREQ ioctl fails to get frequency info
> > Submitter	: nuh <nuh@mailinator.net>
> > Date		: 2010-06-14 10:45 (7 days old)
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16199
> > Subject		: 2.6.35-rc2-git1 - include/linux/cgroup.h:534 invoked rcu_dereference_check() without protection!
> > Submitter	: Miles Lane <miles.lane@gmail.com>
> > Date		: 2010-06-07 18:14 (14 days old)
> > Message-ID	: <AANLkTin2pPqOUx--9fIX3BH3e-cU6oCRufijcx_4ozx5@mail.gmail.com>
> > References	: http://marc.info/?l=linux-kernel&m=127593447812015&w=2
> > 
> > 
> > Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16198
> > Subject		: Running make install over sshfs is painful now
> > Submitter	: Dmitry Torokhov <dmitry.torokhov@gmail.com>
> > Date		: 2010-06-07 6:53 (14 days old)
> > Message-ID	: <20100607065324.GA25590@core.coreip.homeip.net>
> > References	: http://marc.info/?l=linux-kernel&m=127589362011138&w=2
> I confirm this.
> Its direct result of adding '+' to kernel version.
> This just causes only troubles.
> I suggest to have a config option for it.

Thanks for the updates.

Rafael
