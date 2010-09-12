From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: 2.6.36-rc3-git5: Reported regressions from 2.6.35
Date: Sun, 12 Sep 2010 20:11:34 +0200 (CEST)
Message-ID: <EP3NUDNWMO.A.O0.rrRjMB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>
To: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[NOTE:
 Florian Mickler has joined the regression tracking team.  He is going to
 browse the list periodically to close fixed regressions, add patches etc.
 So, when the listed regressions you care about are fixed, please report
 that to Florian.  If there's a working patch for a regression you care
 about, please report that to him too.]

This message contains a list of some regressions from 2.6.35,
for which there are no fixes in the mainline known to the tracking team.
If any of them have been fixed already, please let us know.

If you know of any other unresolved regressions from 2.6.35, please let us
know either and we'll add them to the list.  Also, please let us know
if any of the entries below are invalid.

Each entry from the list will be sent additionally in an automatic reply
to this message with CCs to the people involved in reporting and handling
the issue.


Listed regressions statistics:

  Date          Total  Pending  Unresolved
  ----------------------------------------
  2010-09-12       28       14          13
  2010-08-30       21       16          15


Unresolved regressions
----------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17952
Subject		: bdi-default hung waiting for kthread_stop to finish
Submitter	: Jeff Layton <jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2010-09-02 18:55 (11 days old)
Message-ID	: <20100902145509.28e4f998-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128345371904504&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17752
Subject		: 2.6.36-rc3: inconsistent lock state (iprune_sem, shrink_icache_memory)
Submitter	: Stefan Richter <stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
Date		: 2010-09-01 6:37 (12 days old)
Message-ID	: <tkrat.ed8eda6bc8ffe64e-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128332308528119&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17722
Subject		: 2.6.36-rc3: WARNING: at net/mac80211/scan.c:269 ieee80211_scan_completed
Submitter	: Thomas Meyer <thomas-VsYtu1Qij5c@public.gmane.org>
Date		: 2010-08-31 20:14 (13 days old)
Message-ID	: <201008312214.52473.thomas-VsYtu1Qij5c@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128328580504227&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17361
Subject		: Watchdog detected hard LOCKUP in jbd2_journal_get_write_access
Submitter	: Christian Casteyde <casteyde.christian-GANU6spQydw@public.gmane.org>
Date		: 2010-08-29 19:59 (15 days old)


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17341
Subject		: kdump regression compared to v2.6.35
Submitter	: CAI Qian <caiqian-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2010-08-27 12:35 (17 days old)
Message-ID	: <2136707099.1405541282912500148.JavaMail.root-k5qu2F3t005+R5eDjrG6zsCp5Q1pQRjfhaY/URYTgi6ny3qCrzbmXA@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128291252612135&w=2
Handled-By	: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17331
Subject		: BUG: scheduling while atomic
Submitter	: Sergey Senozhatsky <sergey.senozhatsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-08-27 7:59 (17 days old)
Message-ID	: <20100827075911.GA5966-dY8u8AhHFaWtd10JCjopabkcH5ONE+aC@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128289602925505&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17321
Subject		: i386 WARNING: at kernel/softirq.c:143 _local_bh_enable_ip+0x2f/0x7e
Submitter	: Arno Schuring <aelschuring-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
Date		: 2010-08-27 20:04 (17 days old)
Message-ID	: <4C781A3A.4010707-PkbjNfxxIARBDgjK7y7TUQ@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128294076822387&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17311
Subject		: 2.6.36-rc2-git4 - INFO: possible circular locking dependency detected
Submitter	: Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-08-27 1:56 (17 days old)
First-Bad-Commit: http://git.kernel.org/linus/5a652052fedbd7869572c757dd2ffc2ed420c69d
Message-ID	: <AANLkTinHbEW36D5R9NSrGgfbOC0Hri3Tg-fA0iR92Udi-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128287422106267&w=2
Handled-By	: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17131
Subject		: WARN with 3c905 boomerang NIC
Submitter	: Doug Nazar <nazard.lkml-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-08-22 6:35 (22 days old)
Message-ID	: <4C70C516.5020404-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128245894300623&w=2
Handled-By	: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17061
Subject		: 2.6.36-rc1 on zaurus: bluetooth regression
Submitter	: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date		: 2010-08-21 15:24 (23 days old)
Message-ID	: <20100821152445.GA1536-+ZI9xUNit7I@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128240433828087&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16971
Subject		: qla4xxx compile failure on 32-bit PowerPC: missing readq and writeq
Submitter	: Meelis Roos <mroos-Y27EyoLml9s@public.gmane.org>
Date		: 2010-08-19 21:03 (25 days old)
Message-ID	: <alpine.SOC.1.00.1008192359310.19654-ptEonEWSGqKptlylMvRsHA@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128225184900892&w=2


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16961
Subject		: kernel BUG at arch/x86/kvm/../../../virt/kvm/kvm_main.c:1978
Submitter	: Sergey Senozhatsky <sergey.senozhatsky-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date		: 2010-08-19 9:54 (25 days old)
Message-ID	: <<20100819095429.GA5201-dY8u8AhHFaWtd10JCjopabkcH5ONE+aC@public.gmane.org>>
References	: http://marc.info/?l=linux-kernel&m=128221169606214&w=2
Handled-By	: Avi Kivity <avi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>


Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16951
Subject		: hackbench regression with 2.6.36-rc1
Submitter	: Zhang, Yanmin <yanmin_zhang-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date		: 2010-08-18 6:18 (26 days old)
Message-ID	: <1282112318.21202.8.camel-sz7BYL/Y5Hu/P+R7jlPCFVaTQe2KTcn/@public.gmane.org>
References	: http://marc.info/?l=linux-kernel&m=128211235904910&w=2


Regressions with patches
------------------------

Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=17742
Subject		: 2.6.36-rc2-git5: Oops in snd_pcm_substream_proc_status_read()
Submitter	: Chuck Ebbert <cebbert-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date		: 2010-09-01 8:19 (12 days old)
Message-ID	: <20100901041924.23a8a865@katamari>
References	: http://marc.info/?l=linux-kernel&m=128332930703451&w=2
		  https://bugzilla.redhat.com/show_bug.cgi?id=628404
		  https://bugzilla.redhat.com/show_bug.cgi?id=628404#c5
Handled-By	: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
Patch		: http://mailman.alsa-project.org/pipermail/alsa-devel/2010-September/031275.html


For details, please visit the bug entries and follow the links given in
references.

As you can see, there is a Bugzilla entry for each of the listed regressions.
There also is a Bugzilla entry used for tracking the regressions from 2.6.35,
unresolved as well as resolved, at:

http://bugzilla.kernel.org/show_bug.cgi?id=16444

Please let the tracking team know if there are any Bugzilla entries that
should be added to the list in there.

Thanks!

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
