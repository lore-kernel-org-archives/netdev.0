From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter
 irqbalance hints
Date: Tue, 24 Nov 2009 10:08:56 +0100
Message-ID: <1259053736.4531.1097.camel@laptop>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>
	 <2674af740911222332i65c0d066h79bf2c1ca1d5e4f0@mail.gmail.com>
	 <1258968980.2697.9.camel@ppwaskie-mobl2> <1258995923.4531.715.camel@laptop>
	 <Pine.WNT.4.64.0911231529240.10056@ppwaskie-MOBL2.amr.corp.intel.com>
	 <1259051902.4531.1053.camel@laptop>
	 <1259053156.2631.21.camel@ppwaskie-mobl2>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yong Zhang <yong.zhang0@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:47069 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932285AbZKXJIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 04:08:54 -0500
In-Reply-To: <1259053156.2631.21.camel@ppwaskie-mobl2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-11-24 at 00:59 -0800, Peter P Waskiewicz Jr wrote:
> > This all sounds backwards.. we've got a perfectly functional interface
> > for affinity -- which people object to being used for some reason. So
> > you add another interface on top, and that is ok?
> > 
> 
> But it's not functional.  If I set the affinity in smp_affinity, then
> irqbalance will override it 10 seconds later. 

And here I was thinking the kernel round-robins IRQ delivery on the mask
specified there. Are you talking about some daft userspace thing that
writes into the irq smp_affinity to effect irq balancing?

