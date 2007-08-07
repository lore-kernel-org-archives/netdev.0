From: "Jean-Baptiste Vignaud" <vignaud@xandmail.fr>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue,  7 Aug 2007 11:21:07 +0200
Message-ID: <JMECN8$607C5E77E84D2F80DCAAB4CFEB5A6346@xandmail.com>
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


> > * interrupts (i use irqbalance, but problem was the same without)
> 
> I wonder if you tried without SMP too?

No i did not. Do you think that this can be a problem ?
To test with no SMP, do i need to recompile kernel or is there a kernel parameter ?

....

> BTW, Jean-Baptiste and Chuck - it seems, unless you have too much
> time, there is no use for testing my "genirq: fix simple and fasteoi
> irq handlers" patch.

Well i just  tested 2.6.23-rc1 with your patch and copied (using smbclient) big files :

Aug  7 11:11:53 loki kernel: NETDEV WATCHDOG: eth2: transmit timed out
Aug  7 11:11:53 loki kernel: eth2: transmit timed out, tx_status 00 status e601.
Aug  7 11:11:53 loki kernel:   diagnostics: net 0ccc media 8880 dma 0000003a fifo 0000
Aug  7 11:11:53 loki kernel: eth2: Interrupt posted but not delivered -- IRQ blocked by another device?
Aug  7 11:11:53 loki kernel:   Flags; bus-master 1, dirty 93481(9) current 93481(9)
Aug  7 11:11:53 loki kernel:   Transmit list 00000000 vs. ffff81007be977a0.
Aug  7 11:11:53 loki kernel:   0: @ffff81007be97200  length 8000005f status 0001005f
Aug  7 11:11:53 loki kernel:   1: @ffff81007be972a0  length 8000005f status 0001005f
Aug  7 11:11:53 loki kernel:   2: @ffff81007be97340  length 8000005f status 0001005f
Aug  7 11:11:53 loki kernel:   3: @ffff81007be973e0  length 8000005f status 0001005f
Aug  7 11:11:53 loki kernel:   4: @ffff81007be97480  length 8000003c status 0001003c
Aug  7 11:11:53 loki kernel:   5: @ffff81007be97520  length 8000003c status 0001003c
Aug  7 11:11:53 loki kernel:   6: @ffff81007be975c0  length 8000003c status 0001003c
Aug  7 11:11:53 loki kernel:   7: @ffff81007be97660  length 8000003c status 8001003c
Aug  7 11:11:53 loki kernel:   8: @ffff81007be97700  length 8000003c status 8001003c
Aug  7 11:11:53 loki kernel:   9: @ffff81007be977a0  length 8000002a status 0001002a
Aug  7 11:11:53 loki kernel:   10: @ffff81007be97840  length 8000003a status 0001003a
Aug  7 11:11:53 loki kernel:   11: @ffff81007be978e0  length 8000005f status 0001005f
Aug  7 11:11:53 loki kernel:   12: @ffff81007be97980  length 800000be status 0c0100be
Aug  7 11:11:53 loki kernel:   13: @ffff81007be97a20  length 800000be status 0c0100be
Aug  7 11:11:53 loki kernel:   14: @ffff81007be97ac0  length 8000005f status 0001005f
Aug  7 11:11:53 loki kernel:   15: @ffff81007be97b60  length 8000005f status 0001005f

Thanks;

Jb

