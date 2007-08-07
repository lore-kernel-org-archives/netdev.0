From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Tue, 7 Aug 2007 11:44:01 +0200
Message-ID: <20070807094401.GA3223@ff.dom.local>
References: <JMECN8$607C5E77E84D2F80DCAAB4CFEB5A6346@xandmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cebbert <cebbert@redhat.com>, mingo <mingo@elte.hu>,
	"marcin\.slusarz" <marcin.slusarz@gmail.com>,
	tglx <tglx@linutronix.de>,
	torvalds <torvalds@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	akpm <akpm@linux-foundation.org>, alan <alan@lxorguk.ukuu.org.uk>
To: Jean-Baptiste Vignaud <vignaud@xandmail.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:41748 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757319AbXHGJnc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 05:43:32 -0400
Content-Disposition: inline
In-Reply-To: <JMECN8$607C5E77E84D2F80DCAAB4CFEB5A6346@xandmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 07, 2007 at 11:21:07AM +0200, Jean-Baptiste Vignaud wrote:
> 
> > > * interrupts (i use irqbalance, but problem was the same without)
> >
> > I wonder if you tried without SMP too?
> 
> No i did not. Do you think that this can be a problem ?
> To test with no SMP, do i need to recompile kernel or is there a kernel parameter ?

It's always better to exclude any complications if it's possible.
Yes, there is the kernel parameter for this: nosmp. So, if you
have some time to spare I think 2.6.23-rc2 with this nosmp
could be an interesting option.

> ....
> 
> > BTW, Jean-Baptiste and Chuck - it seems, unless you have too much
> > time, there is no use for testing my "genirq: fix simple and fasteoi
> > irq handlers" patch.
> 
> Well i just  tested 2.6.23-rc1 with your patch and copied (using smbclient) big files :
> 
> Aug  7 11:11:53 loki kernel: NETDEV WATCHDOG: eth2: transmit timed out
> Aug  7 11:11:53 loki kernel: eth2: transmit timed out, tx_status 00 status e601.
> Aug  7 11:11:53 loki kernel:   diagnostics: net 0ccc media 8880 dma 0000003a fifo 0000
> Aug  7 11:11:53 loki kernel: eth2: Interrupt posted but not delivered -- IRQ blocked by another device?
> Aug  7 11:11:53 loki kernel:   Flags; bus-master 1, dirty 93481(9) current 93481(9)
> Aug  7 11:11:53 loki kernel:   Transmit list 00000000 vs. ffff81007be977a0.
> Aug  7 11:11:53 loki kernel:   0: @ffff81007be97200  length 8000005f status 0001005f
...

Thanks,
Jarek P.
