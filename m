From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter
 irqbalance hints
Date: Tue, 24 Nov 2009 10:15:38 +0100
Message-ID: <1259054138.4531.1109.camel@laptop>
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
Received: from bombadil.infradead.org ([18.85.46.34]:60398 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932402AbZKXJPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 04:15:35 -0500
In-Reply-To: <1259053156.2631.21.camel@ppwaskie-mobl2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-11-24 at 00:59 -0800, Peter P Waskiewicz Jr wrote:
> 
> > All the while not CC'ing the IRQ folks,.. brilliant approach.
> 
> If I knew who I should CC, I'd be happy to add them.  Can you provide
> email addresses please? 

Since most people can't seen to read a simple MAINTAINERS file, some
other people wrote a script to read it for you:

# scripts/get_maintainer.pl -f kernel/irq/manage.c
Ingo Molnar <mingo@elte.hu>
Thomas Gleixner <tglx@linutronix.de>
linux-kernel@vger.kernel.org


Another option is to do something like:

# git log kernel/irq/manage.c | grep Author | head -30 | awk
'{ t[$0]++; } END { for (i in t) { print t[i] " " i; }}' | sort -rn

10 Author: Thomas Gleixner <tglx@linutronix.de>
9 Author: Ingo Molnar <mingo@elte.hu>
3 Author: Magnus Damm <damm@igel.co.jp>
2 Author: Linus Torvalds <torvalds@linux-foundation.org>
...

