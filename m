From: Satyam Sharma <satyam@infradead.org>
Subject: Re: 2.6.23-rc4-mm1 OOPS in forcedeth?
Date: Sun, 2 Sep 2007 06:24:29 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0709020610590.20781@enigma.security.iitk.ac.in>
References: <20070831215822.26e1432b.akpm@linux-foundation.org>
 <20070901181352.GA4156@amd64.of.nowhere> <46D9B7EF.2050109@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: thunder7@xs4all.nl, Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:51139 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932623AbXIBAli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 20:41:38 -0400
In-Reply-To: <46D9B7EF.2050109@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jurriaan,


> thunder7@xs4all.nl wrote:
> > From: Andrew Morton <akpm@linux-foundation.org>
> > Date: Fri, Aug 31, 2007 at 09:58:22PM -0700
> > > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc4/2.6.23-rc4-mm1/
> > > 
> > On this machine (Athlon 64 X2 4600, 4 GiB memory, lots of disks),
> > 2.6.23-rc1-mm2 runs fine. 2.6.23-rc4-mm1 reproducably dies within seconds of
> > starting
> > a rsync session on another PC against this machine.
> > 
> > NULL pointer dereference
> > code:	nv_napi_poll+0x108
> > trace:	net_rx_action+0xab
> > 	__do_softirq+0x74
> > 	call_softirq+0x1c
> > 	do_softirq+0x3d
> > 	irq_exit+0x85
> > 	do_IRQ+0x85
> > 	ret_from_intr+0x0

The dmesg you posted below doesn't cover the messages from this oops
itself. As you mentioned you can reproduce this oops easily, please do so,
and post the *full* oops log (if it doesn't get logged to disk, you can
try taking digicam photo, or write down *all* the messages and post here).
I built an x86_64 kernel as per your .config, but don't see any memory
dereference at nv_napi_poll+0x108 -- could be toolchain differences.

Else, can you run:
$ gdb ./vmlinux

and then:
(gdb) l *nv_napi_poll+0x108

and send us the output?


Satyam
