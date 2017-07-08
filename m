From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2 0/9] Remove spin_unlock_wait()
Date: Sat, 8 Jul 2017 10:43:24 +0200
Message-ID: <20170708084323.iuyb4smp2a4ca4fh@gmail.com>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
 <20170705232955.GA15992@linux.vnet.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DD0033F01@AcuExch.aculab.com>
 <20170706160555.xc63yydk77gmttae@hirez.programming.kicks-ass.net>
 <20170706162024.GD2393@linux.vnet.ibm.com>
 <20170706165036.v4u5rbz56si4emw5@hirez.programming.kicks-ass.net>
 <20170707083128.wqk6msuuhtyykhpu@gmail.com>
 <20170707144107.GA27202@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
        David Laight <David.Laight@ACULAB.COM>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "oleg@redhat.com" <oleg@redhat.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "mingo@redhat.com" <mingo@redhat.com>,
        "dave@stgolabs.net" <dave@stgolabs.net>,
        "manfred@colorfullife.com" <manfred@colorfullife.com>,
        "tj@kernel.org" <tj@kernel.org>, "arnd@arndb.de" <arnd@arndb.de>,
        "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
        "will.deacon@arm.com" <will.deacon@arm.com>,
        "stern@rowland.harvard.edu" <stern@rowland.harvard.edu>,
        "parri.andrea@gmail.com" <parri.andrea@gmail.com>,
        "torval
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170707144107.GA27202@linux.vnet.ibm.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> On Fri, Jul 07, 2017 at 10:31:28AM +0200, Ingo Molnar wrote:
> 
> [ . . . ]
> 
> > In fact I'd argue that any future high performance spin_unlock_wait() user is 
> > probably better off open coding the unlock-wait poll loop (and possibly thinking 
> > hard about eliminating it altogether). If such patterns pop up in the kernel we 
> > can think about consolidating them into a single read-only primitive again.
> 
> I would like any reintroduction to include a header comment saying exactly
> what the consolidated primitive actually does and does not do.  ;-)
> 
> > I.e. I think the proposed changes are doing no harm, and the unavailability of a 
> > generic primitive does not hinder future optimizations either in any significant 
> > fashion.
> 
> I will have a v3 with updated comments from Manfred.  Thoughts on when/where
> to push this?

Once everyone agrees I can apply it to the locking tree. I think PeterZ's was the 
only objection?

> The reason I ask is if this does not go in during this merge window, I need
> to fix the header comment on spin_unlock_wait().

Can try it next week after some testing - let's see how busy things get for Linus 
in the merge window?

Thanks,

	Ingo
