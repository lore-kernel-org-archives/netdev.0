From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.21-rc4: known regressions with patches (v2)
Date: Sat, 24 Mar 2007 12:25:44 +0100
Message-ID: <20070324112544.GB752@stusta.de>
References: <Pine.LNX.4.64.0703160925270.26106@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maxim Levitsky <maximlevitsky@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, tigran@aivazian.fsnet.co.uk,
	David L <idht4n@hotmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Bob Tracy <rct@gherkin.frus.com>,
	John Stultz <johnstul@us.ibm.com>, bzolnier@gmail.com,
	linux-ide@vger.kernel.org,
	Albert Hopkins <kernel@marduk.letterboxes.org>,
	Ayaz Abdulla <aabdulla@nvidia.com>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:33280 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751012AbXCXLZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2007 07:25:42 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703160925270.26106@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This email lists some known regressions in Linus' tree compared to 2.6.20
with patches available.

If you find your name in the Cc header, you are either submitter of one
of the bugs, maintainer of an affectected subsystem or driver, a patch
of you caused a breakage or I'm considering you in any other way
possibly involved with one or more of these issues.

Due to the huge amount of recipients, please trim the Cc when answering.


Subject    : suspend to disk hangs  (microcode driver)
References : http://lkml.org/lkml/2007/3/16/126
Submitter  : Maxim Levitsky <maximlevitsky@gmail.com>
Caused-By  : Rafael J. Wysocki <rjw@sisk.pl>
             commit e3c7db621bed4afb8e231cb005057f2feb5db557
             commit ed746e3b18f4df18afa3763155972c5835f284c5
             commit 259130526c267550bc365d3015917d90667732f1
Handled-By : Rafael J. Wysocki <rjw@sisk.pl>
Patch      : http://lkml.org/lkml/2007/3/23/179
Status     : patch available


Subject    : gettimeofday increments too slowly
References : http://bugzilla.kernel.org/show_bug.cgi?id=8027
             http://lkml.org/lkml/2007/3/23/329
Submitter  : David L <idht4n@hotmail.com>
Caused-By  : Thomas Gleixner <tglx@linutronix.de>
             commit 92c7e00254b2d0efc1e36ac3e45474ce1871b6b2
Handled-By : Thomas Gleixner <tglx@linutronix.de>
Patch      : http://lkml.org/lkml/2007/3/23/329
Status     : patch available


Subject    : boot hangs during IDE detection  (clocksource)
References : http://lkml.org/lkml/2007/3/19/465
Submitter  : Bob Tracy <rct@gherkin.frus.com>
Caused-By  : John Stultz <johnstul@us.ibm.com>
             commit 6bb74df481223731af6c7e0ff3adb31f6442cfcd
Handled-By : John Stultz <johnstul@us.ibm.com>
Patch      : http://lkml.org/lkml/2007/3/22/287
Status     : workaround-patch available


Subject    : forcedeth: skb_over_panic
References : http://bugzilla.kernel.org/show_bug.cgi?id=8058
Submitter  : Albert Hopkins <kernel@marduk.letterboxes.org>
Handled-By : Ayaz Abdulla <aabdulla@nvidia.com>
Patch      : http://bugzilla.kernel.org/show_bug.cgi?id=8058
Status     : patch available

