From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] genirq: fix simple and fasteoi irq handlers
Date: Fri, 3 Aug 2007 10:04:08 +0200
Message-ID: <20070803080408.GA12222@elte.hu>
References: <20070726081326.GA3197@ff.dom.local> <1185437431.3227.21.camel@chaos> <20070726083120.GA26910@elte.hu> <20070726085523.GA3423@ff.dom.local> <20070726091254.GA8063@elte.hu> <4bacf17f0707300029g5116e70bq4808059dc8b069f1@mail.gmail.com> <20070731155843.GA7033@elte.hu> <46B20E47.6020403@googlemail.com> <20070802201126.GA27000@elte.hu> <20070803060733.GA1582@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gabriel C <nix.or.die@googlemail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, marcin.slusarz@gmail.com
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070803060733.GA1582@ff.dom.local>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Jarek Poplawski <jarkao2@o2.pl> wrote:

> I can't guarantee this is all needed to fix this bug, but I think this 
> patch is necessary here.

hmmm ... very interesting! Now _this_ is something we'd like to see 
tested. Could you send a patch to Marcin that also undoes the workaround 
we have in place now, so that he could check whether ne2k-pci works fine 
with your fix alone?

	Ingo
