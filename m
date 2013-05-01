From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/2] sched: Add cond_resched_rcu_lock() helper
Date: Wed, 1 May 2013 10:30:35 -0700
Message-ID: <20130501173035.GT3780@linux.vnet.ibm.com>
References: <1367290378-29224-2-git-send-email-horms@verge.net.au>
 <alpine.LFD.2.00.1304301011310.1700@ja.ssi.bg>
 <20130430072944.GA13959@verge.net.au>
 <alpine.LFD.2.00.1304301051260.1700@ja.ssi.bg>
 <20130501091012.GB28253@dyad.programming.kicks-ass.net>
 <20130501124637.GO3780@linux.vnet.ibm.com>
 <20130501151752.GA7521@dyad.programming.kicks-ass.net>
 <1367422195.11020.46.camel@edumazet-glaptop>
 <20130501160218.GQ3780@linux.vnet.ibm.com>
 <20130501165748.GD7521@dyad.programming.kicks-ass.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Julian Anastasov <ja@ssi.bg>,
	Simon Horman <horms@verge.net.au>,
	Ingo Molnar <mingo@redhat.com>, lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Dipankar Sarma <dipankar@in.ibm.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:51569 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330Ab3EARbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 13:31:32 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 1 May 2013 11:31:28 -0600
Content-Disposition: inline
In-Reply-To: <20130501165748.GD7521@dyad.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 01, 2013 at 06:57:49PM +0200, Peter Zijlstra wrote:
> On Wed, May 01, 2013 at 09:02:18AM -0700, Paul E. McKenney wrote:
> > My guess would be for the case where sched_preempt_enable_no_resched()
> > is followed some time later by cond_resched().
> 
> I might hope not.. preempt_enable_no_resched() is nasty and you're likely to be
> hit with a frozen fish of sorts by tglx if you try to use it ;-)

I will stick with my guess, though I agree that if I am correct,
this situation almost certainly predates tglx's Linux-related use of
frozen fish as projectile weapons.  ;-)

							Thanx, Paul
