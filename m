From: Adrian Bunk <bunk@stusta.de>
Subject: [3/4] 2.6.21-rc5: known regressions (v2)
Date: Fri, 30 Mar 2007 23:32:20 +0200
Message-ID: <20070330213220.GO14134@stusta.de>
References: <Pine.LNX.4.64.0703251559560.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Len Brown <len.brown@intel.com>, Jeremy Fitzhardinge <jeremy@goop.org>,
   tigran@aivazian.fsnet.co.uk,
   Michal Piotrowski <michal.k.k.piotrowski@gmail.com>, adaplas@gmail.com,
   Soeren Sonnenburg <kernel@nn7.de>, Marcus Better <marcus@better.se>,
   linux-ide@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>,
   Thomas Gleixner <tglx@linutronix.de>,
   Stephen Hemminger <shemminger@linux-foundation.org>,
   Maxim Levitsky <maximlevitsky@gmail.com>,
   Mike Harris <atarimike@wavecable.com>,
   Jeff Chua <jeff.chua.linux@gmail.com>, netdev@vger.kernel.org,
   gregkh@suse.de, linux-pm@lists.osdl.org,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   linux-acpi@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>,
   linux-pci@atrey.karlin.mff.cuni.cz, jgarzik@pobox.com,
   Tobias Doerffel <tobias.doerffel@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
   Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703251559560.6730@woody.linux-foundation.org>
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

This email lists some known regressions in Linus' tree compared to 2.6.20.

If you find your name in the Cc header, you are either submitter of one
of the bugs, maintainer of an affectected subsystem or driver, a patch
of you caused a breakage or I'm considering you in any other way
possibly involved with one or more of these issues.

Due to the huge amount of recipients, please trim the Cc when answering.


Subject    : ThinkPad X60: resume no longer works  (PCI related?)
References : http://lkml.org/lkml/2007/3/13/3
Submitter  : Dave Jones <davej@redhat.com>
             Jeremy Fitzhardinge <jeremy@goop.org>
Caused-By  : PCI merge
             commit 78149df6d565c36675463352d0bfe0000b02b7a7
Handled-By : Eric W. Biederman <ebiederm@xmission.com>
             Rafael J. Wysocki <rjw@sisk.pl>
Status     : problem is being debugged


Subject    : Suspend to RAM doesn't work anymore  (ACPI?)
References : http://lkml.org/lkml/2007/3/19/128
             http://bugzilla.kernel.org/show_bug.cgi?id=3D8247
Submitter  : Tobias Doerffel <tobias.doerffel@gmail.com>
Handled-By : Rafael J. Wysocki <rjw@sisk.pl>
             Len Brown <len.brown@intel.com>
Status     : problem is being debugged


Subject    : SATA breakage on resume
References : http://lkml.org/lkml/2007/3/7/233
Submitter  : Thomas Gleixner <tglx@linutronix.de>
             Soeren Sonnenburg <kernel@nn7.de>
Status     : unknown


Subject    : resume from RAM corrupts vesafb console
References : http://lkml.org/lkml/2007/3/26/76
Submitter  : Marcus Better <marcus@better.se>
Handled-By : Pavel Machek <pavel@ucw.cz>
Status     : problem is being debugged


Subject    : ThinkPad doesn't resume from suspend to RAM
References : http://lkml.org/lkml/2007/2/27/80
             http://lkml.org/lkml/2007/2/28/348
Submitter  : Jens Axboe <jens.axboe@oracle.com>
             Jeff Chua <jeff.chua.linux@gmail.com>
Status     : unknown


Subject    : MacBook Core Duo: suspend to memory wakeup hang
References : http://bugzilla.kernel.org/show_bug.cgi?id=3D8272
Submitter  : Mike Harris <atarimike@wavecable.com>
Status     : unknown


Subject    : suspend to disk hangs  (skge)
References : http://lkml.org/lkml/2007/3/27/212
Submitter  : Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Caused-By  : Stephen Hemminger <shemminger@linux-foundation.org>
             commit a504e64ab42bcc27074ea37405d06833ed6e0820
Status     : unknown


Subject    : suspend to disk hangs  (microcode driver)
References : http://lkml.org/lkml/2007/3/16/126
Submitter  : Maxim Levitsky <maximlevitsky@gmail.com>
Caused-By  : Rafael J. Wysocki <rjw@sisk.pl>
             commit e3c7db621bed4afb8e231cb005057f2feb5db557
             commit ed746e3b18f4df18afa3763155972c5835f284c5
             commit 259130526c267550bc365d3015917d90667732f1
Handled-By : Rafael J. Wysocki <rjw@sisk.pl>
Patch      : http://lkml.org/lkml/2007/3/25/71
Status     : patch available
