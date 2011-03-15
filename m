From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Tue, 15 Mar 2011 11:29:18 +0100 (CET)
Message-ID: <alpine.LFD.2.00.1103151128070.2787@localhost6.localdomain6>
References: <20110314170546.af552b4e.sfr@canb.auug.org.au> <alpine.LFD.2.00.1103141053020.2787@localhost6.localdomain6> <20110315113049.a6112494.sfr@canb.auug.org.au> <20110314.210712.226761233.davem@davemloft.net>
 <20110315172558.a11642e7.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, hpa@zytor.com,
	peterz@infradead.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110315172558.a11642e7.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Mar 2011, Stephen Rothwell wrote:

> Hi Dave,
> 
> On Mon, 14 Mar 2011 21:07:12 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> >
> > From: Stephen Rothwell <sfr@canb.auug.org.au>
> > Date: Tue, 15 Mar 2011 11:30:49 +1100
> > 
> > > So, if you merge the commit 1fb0ef31f428 ("genirq: Fix affinity notifier
> > > fallout") from the tip tree, you will get exactly one new commit and will
> > > fix your tree properly with no adverse effect on anyone else.
> > 
> > Thomas, how would you like me to do this?  Do you want to put that
> > commit on a branch for me to pull from or should I apply it
> > directly?
> 
> That commit is already the head of the irq/numa branch in the tip tree
> (it is also on the irq/core branch).
> 
> Please merge that rather than cherry-picking the commit as that will
> minimise the possibility of conflicts.  Pulling the irq/numa branch will
> get you just that one fixup commit (as you have already merged up to the
> immediately preceding commit).
> 
> I assume this makes sense, Thomas?  I just did a merge of the actual
> fixup commit after merging the net tree.

Yes. irq/numa should do the trick.

Thanks,

	tglx
