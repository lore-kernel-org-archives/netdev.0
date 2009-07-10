From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: 2.6.31-rc2: Reported regressions from 2.6.30
Date: Thu, 09 Jul 2009 20:46:57 -0500
Message-ID: <1247190417.7306.2.camel@merlyn>
References: <35kKlbXMqWN.A.RXD.D0oUKB@chimera>
	 <200907070325.51439.andres@anarazel.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Sesterhenn <eric.sesterhenn@lsexperts.de>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
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
To: Andres Freund <andres@anarazel.de>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <200907070325.51439.andres@anarazel.de>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-07-07 at 03:25 +0200, Andres Freund wrote:
> There is also http://lkml.org/lkml/2009/6/30/398 : Soft-Lockup/Race
> in 
> networking in 2.6.31-rc1+195 (possibly caused by netem)

There is some similarity between this soft lockup and the one reported
in http://www.spinics.net/lists/netdev/msg100957.html.  In both, the
process is doing both sends and receives on raw sockets.

  --  John

