From: Andres Freund <andres@anarazel.de>
Subject: Re: 2.6.31-rc2: Reported regressions from 2.6.30
Date: Fri, 10 Jul 2009 04:10:37 +0200
Message-ID: <200907100410.37506.andres@anarazel.de>
References: <35kKlbXMqWN.A.RXD.D0oUKB@chimera> <200907070325.51439.andres@anarazel.de> <1247190417.7306.2.camel@merlyn>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Eric Sesterhenn <eric.sesterhenn@lsexperts.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: John Dykstra <john.dykstra1@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1247190417.7306.2.camel@merlyn>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John, Hi Rafael,

On Friday 10 July 2009 03:46:57 John Dykstra wrote:
> On Tue, 2009-07-07 at 03:25 +0200, Andres Freund wrote:
> > There is also http://lkml.org/lkml/2009/6/30/398 : Soft-Lockup/Race
> > in
> > networking in 2.6.31-rc1+195 (possibly caused by netem)
>
> There is some similarity between this soft lockup and the one reported
> in http://www.spinics.net/lists/netdev/msg100957.html.  In both, the
> process is doing both sends and receives on raw sockets.
The issue turned out to be a hrtimer bug - i dont see anything like it in your 
trace. If you still want to test the fix, its 
de907e8432b08f2d5966c36e0747e97c0e596810 in -tip (or 
http://lkml.org/lkml/2009/7/9/150)

Rafael: In case youre reading this, I guess you can mark that bug as resolved.

Andres
