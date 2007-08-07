From: "Jean-Baptiste Vignaud" <vignaud@xandmail.fr>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue,  7 Aug 2007 19:16:33 +0200
Message-ID: <JMEYNL$38C71F6F1D25A7CE82B12729A59CF244@xandmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: "cebbert" <cebbert@redhat.com>, "mingo" <mingo@elte.hu>,
	"marcin\.slusarz" <marcin.slusarz@gmail.com>,
	"tglx" <tglx@linutronix.de>,
	"torvalds" <torvalds@linux-foundation.org>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"shemminger" <shemminger@linux-foundation.org>,
	"linux-net" <linux-net@vger.kernel.org>,
	"netdev" <netdev@vger.kernel.org>,
	"akpm" <akpm@linux-foundation.org>,
	"alan" <alan@lxorguk.ukuu.org.uk>
To: "jarkao2" <jarkao2@o2.pl>
Return-path: <linux-net-owner@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Tue, Aug 07, 2007 at 11:21:07AM +0200, Jean-Baptiste Vignaud wrote:
> > 
> > > > * interrupts (i use irqbalance, but problem was the same without)
> > >
> > > I wonder if you tried without SMP too?
> > 
> > No i did not. Do you think that this can be a problem ?
> > To test with no SMP, do i need to recompile kernel or is there a kernel parameter ?
> 
> It's always better to exclude any complications if it's possible.
> Yes, there is the kernel parameter for this: nosmp. So, if you
> have some time to spare I think 2.6.23-rc2 with this nosmp
> could be an interesting option.

So this afternoon i compiled 2.6.23-rc2 with same options as 2.6.23-rc1 and edited grub.conf to add nosmp but after reboot the box did not responded. Back home, i saw that the kernel failed because it was unable to find the partitions (mdadm failed, then LVM). After a few tests, removing nosmp let the kernel boot correctly. It seems that even the fedora provided kernels have the same behavior (well at least 2.6.22.1-41.fc7).

Jb

