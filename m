From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: 3.2-rc2+: Reported regressions from 3.0 and 3.1
Date: Tue, 22 Nov 2011 13:22:06 +0100
Message-ID: <20111122122206.GD8397@redhat.com>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera>
 <201111212249.31196.rjw@sisk.pl>
 <4ECB37E4.6020204@linux.vnet.ibm.com>
 <20111121215918.febd9fd4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Florian Mickler <florian@mickler.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.freedesktop.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111121215918.febd9fd4.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 21, 2011 at 09:59:18PM -0800, Andrew Morton wrote:
> grr, nothing in that patch's changelog indicates that it fixed a
> regression nor that it fixed an infinite blockage of suspend.

Well it's not a recent thing so I didn't flag it as a regression. It
doesn't infinite block it, suspend works fine almost all the time (or
it would have been noticed before), and if you've bad luck and it
doesn't suspend the first time around like someone experienced, if you
try again a bit later it'll work.

> I moved it to my 3.2 queue, thanks.

Thanks!
