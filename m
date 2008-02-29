From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] fix boot-time hangs from PREEMPT_RCU and NO_HZ
Date: Fri, 29 Feb 2008 08:55:57 -0800
Message-ID: <20080229165557.GC13330@linux.vnet.ibm.com>
References: <Pine.LNX.4.58.0801291113350.20371@gandalf.stny.rr.com> <20080229044329.GA20207@linux.vnet.ibm.com> <20080228210140.37abe9cd.akpm@linux-foundation.org> <20080229154835.GB27248@elte.hu>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	john stultz <johnstul@us.ibm.com>, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:57014 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933425AbYB2Q4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 11:56:18 -0500
Content-Disposition: inline
In-Reply-To: <20080229154835.GB27248@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 29, 2008 at 04:48:35PM +0100, Ingo Molnar wrote:
> 
> * Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > > Note: This patch came directly from the -rt patch where it has been 
> > > tested for several months.
> > > 
> > > Andrew, could you please apply this?
> > 
> > I already have it, via git-sched.  Presumably Ingo has it lined up for 
> > the next sched-related merge.
> 
> yes.

Ah, thank you both and sorry for the noise!

						Thanx, Paul
