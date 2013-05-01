From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Wed, 01 May 2013 08:29:55 -0700
Message-ID: <1367422195.11020.46.camel@edumazet-glaptop>
References: <1367290378-29224-1-git-send-email-horms@verge.net.au>
	 <1367290378-29224-2-git-send-email-horms@verge.net.au>
	 <alpine.LFD.2.00.1304301011310.1700@ja.ssi.bg>
	 <20130430072944.GA13959@verge.net.au>
	 <alpine.LFD.2.00.1304301051260.1700@ja.ssi.bg>
	 <20130501091012.GB28253@dyad.programming.kicks-ass.net>
	 <20130501124637.GO3780@linux.vnet.ibm.com>
	 <20130501151752.GA7521@dyad.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Julian Anastasov <ja@ssi.bg>,
	Simon Horman <horms@verge.net.au>,
	Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Dipankar Sarma <dipankar@in.ibm.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20130501151752.GA7521@dyad.programming.kicks-ass.net>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-05-01 at 17:17 +0200, Peter Zijlstra wrote:
> On Wed, May 01, 2013 at 05:46:37AM -0700, Paul E. McKenney wrote:
> 
> > If the only goal is to allow preemption, and if long grace periods are
> > not a concern, then this alternate approach would work fine as well.
> 
> Hmm.. if that were the goal I'd like it to have a different name;
> cond_resched*() has always been about preemption.

BTW, I do not remember why cond_resched() is not an empty macro
when CONFIG_PREEMPT=y ?


