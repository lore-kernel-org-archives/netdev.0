From: kuznet@ms2.inr.ac.ru
Subject: Re: route cache DoS testing and softirqs
Date: Thu, 1 Apr 2004 10:00:36 +0400 (MSD)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200404010600.KAA08004@yakov.inr.ac.ru>
References: <20040330202820.GA3956@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrea@suse.de (Andrea Arcangeli), linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
	paulmck@us.ibm.com (Paul E. McKenney),
	davem@redhat.com (Dave Miller), akpm@osdl.org (Andrew Morton)
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: dipankar@in.ibm.com
In-Reply-To: <20040330202820.GA3956@in.ibm.com> from "Dipankar Sarma" at Mar 31, 2004 01:58:21 AM
List-Id: netdev.vger.kernel.org

Hello!

> > We had one full solution for this issue not changing anything
> > in scheduler/softirq relationship: to run rcu task for the things
> > sort of dst cache not from process context, but essentially as part
> > of do_softirq(). Simple, stupid and apparently solves new problems
> > which rcu created.
> 
> Can you be a little bit more specific about this solution ?

It is about that your suggestion, which you outlined below :-)

> as indicated by my earlier experiments. We have potential fixes
> for RCU through a call_rcu_bh() interface where completion of a
> softirq handler is a quiescent state. I am working on forward porting
> that old patch from our discussion last year and testing in my
> environment. That should increase the number of quiescent state
> points significantly and hopefully reduce the grace period significantly.
> But this does nothing to help userland starvation.

Alexey
