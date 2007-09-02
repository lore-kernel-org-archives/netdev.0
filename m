From: thunder7@xs4all.nl
Subject: Re: 2.6.23-rc4-mm1 OOPS in forcedeth?
Date: Sun, 2 Sep 2007 08:19:00 +0200
Message-ID: <20070902061900.GA5595@amd64.of.nowhere>
References: <20070831215822.26e1432b.akpm@linux-foundation.org> <20070901181352.GA4156@amd64.of.nowhere> <46D9B7EF.2050109@garzik.org> <alpine.LFD.0.999.0709020610590.20781@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, thunder7@xs4all.nl,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Satyam Sharma <satyam@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933602AbXIBGT3@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0709020610590.20781@enigma.security.iitk.ac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <satyam@infradead.org>
Date: Sun, Sep 02, 2007 at 06:24:29AM +0530
> Hi Jurriaan,
> 
> 
> > thunder7@xs4all.nl wrote:
> > > From: Andrew Morton <akpm@linux-foundation.org>
> > > Date: Fri, Aug 31, 2007 at 09:58:22PM -0700
> > > > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc4/2.6.23-rc4-mm1/
> > > > 
> > > On this machine (Athlon 64 X2 4600, 4 GiB memory, lots of disks),
> > > 2.6.23-rc1-mm2 runs fine. 2.6.23-rc4-mm1 reproducably dies within seconds of
> > > starting
> > > a rsync session on another PC against this machine.
> > > 
> > > NULL pointer dereference
> > > code:	nv_napi_poll+0x108
> > > trace:	net_rx_action+0xab
> > > 	__do_softirq+0x74
> > > 	call_softirq+0x1c
> > > 	do_softirq+0x3d
> > > 	irq_exit+0x85
> > > 	do_IRQ+0x85
> > > 	ret_from_intr+0x0
> 
> The dmesg you posted below doesn't cover the messages from this oops
> itself. As you mentioned you can reproduce this oops easily, please do so,
> and post the *full* oops log (if it doesn't get logged to disk, you can
> try taking digicam photo, or write down *all* the messages and post here).
> I built an x86_64 kernel as per your .config, but don't see any memory
> dereference at nv_napi_poll+0x108 -- could be toolchain differences.
> 
There are 4 pictures of oopses here:

http://www.xs4all.nl/~thunder7/oops_2623rc4mm1_1.jpg
http://www.xs4all.nl/~thunder7/oops_2623rc4mm1_2.jpg
http://www.xs4all.nl/~thunder7/oops_2623rc4mm1_3.jpg
http://www.xs4all.nl/~thunder7/oops_2623rc4mm1_4.jpg

image quality, well, they're readable.

Good luck,
Jurriaan
-- 
management n.
1. Corporate power elites distinguished primarily by their distance from
actual productive work and their chronic failure to manage (see also suit).
Spoken derisively, as in "Management decided that ...". 2. Mythically, a
vast bureaucracy responsible for all the world's minor irritations.
Hackers' satirical public notices are often signed `The Mgt'; this derives
from the "Illuminatus" novels (see the Bibliography in Appendix C).
Debian (Unstable) GNU/Linux 2.6.23-rc1-mm2 2x2010 bogomips load 0.43
the Jack Vance Integral Edition: http://www.integralarchive.org
