From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.21-rc1: known regressions (v2) (part 2)
Date: Mon, 26 Feb 2007 23:05:21 +0100
Message-ID: <20070226220521.GB29575@stusta.de>
References: <Pine.LNX.4.64.0702202043280.4043@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David P. Reed" <dpreed@reed.com>,
	Ayaz Abdulla <aabdulla@nvidia.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org,
	Albert Hopkins <kernel@marduk.letterboxes.org>,
	Bob Tracy <rct@gherkin.frus.com>,
	Mark Brown <broonie@sirena.org.uk>,
	"Michael S. Tsirkin" <mst@mellanox.co.il>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Daniel Walker <dwalker@mvista.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:45079 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1161255AbXBZWFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 17:05:22 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0702202043280.4043@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This email lists some known regressions in 2.6.21-rc1 compared to 2.6.20
that are not yet fixed in Linus' tree.

If you find your name in the Cc header, you are either submitter of one
of the bugs, maintainer of an affectected subsystem or driver, a patch
of you caused a breakage or I'm considering you in any other way possibly
involved with one or more of these issues.

Due to the huge amount of recipients, please trim the Cc when answering.


Subject    : forcedeth no longer works
References : http://bugzilla.kernel.org/show_bug.cgi?id=8090
Submitter  : David P. Reed <dpreed@reed.com>
Caused-By  : Ayaz Abdulla <aabdulla@nvidia.com>
Status     : unknown


Subject    : forcedeth: skb_over_panic
References : http://bugzilla.kernel.org/show_bug.cgi?id=8058
Submitter  : Albert Hopkins <kernel@marduk.letterboxes.org>
Status     : unknown


Subject    : natsemi ethernet card not detected correctly
References : http://lkml.org/lkml/2007/2/23/4
             http://lkml.org/lkml/2007/2/23/7
Submitter  : Bob Tracy <rct@gherkin.frus.com>
Caused-By  : Mark Brown <broonie@sirena.org.uk>
Handled-By : Mark Brown <broonie@sirena.org.uk>
Patch      : http://lkml.org/lkml/2007/2/23/142
Status     : patch available


Subject    : ThinkPad T60: system doesn't come out of suspend to RAM
             (CONFIG_NO_HZ)
References : http://lkml.org/lkml/2007/2/22/391
Submitter  : Michael S. Tsirkin <mst@mellanox.co.il>
Handled-By : Thomas Gleixner <tglx@linutronix.de>
             Ingo Molnar <mingo@elte.hu>
Status     : unknown


Subject    : kernel BUG at kernel/time/tick-sched.c:168  (CONFIG_NO_HZ)
References : http://lkml.org/lkml/2007/2/16/346
Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Handled-By : Thomas Gleixner <tglx@linutronix.de>
Status     : problem is being debugged


Subject    : BUG: soft lockup detected on CPU#0
             NOHZ: local_softirq_pending 20  (SMT scheduler)
References : http://lkml.org/lkml/2007/2/20/257
Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Handled-By : Thomas Gleixner <tglx@linutronix.de>
             Ingo Molnar <mingo@elte.hu>
Status     : problem is being debugged


Subject    : i386: no boot with nmi_watchdog=1  (clockevents)
References : http://lkml.org/lkml/2007/2/21/208
Submitter  : Daniel Walker <dwalker@mvista.com>
Caused-By  : Thomas Gleixner <tglx@linutronix.de>
             commit e9e2cdb412412326c4827fc78ba27f410d837e6e
Handled-By : Thomas Gleixner <tglx@linutronix.de>
Status     : problem is being debugged

