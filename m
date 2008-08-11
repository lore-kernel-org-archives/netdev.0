From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH diagnostic] Re: HPET regression in 2.6.26 versus 2.6.25
	-- RCU problem
Date: Mon, 11 Aug 2008 09:29:57 -0700
Message-ID: <20080811162956.GH6762@linux.vnet.ibm.com>
References: <777191.9258.qm@web82105.mail.mud.yahoo.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
	linux-kernel@vger.kernel.org, Yinghai Lu <yhlu.kernel@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: David Witbrodt <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:40837 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbYHKQaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 12:30:06 -0400
Content-Disposition: inline
In-Reply-To: <777191.9258.qm@web82105.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 09:22:01AM -0700, David Witbrodt wrote:
> 
> > And attached is the kernel module I used to test the patch, for whatever
> > that might be worth.
> 
> Thank you for that, too.  I have some questions and a comment:
> 
> 1.  This module can only be loaded from a working system, right?  You
> mean that _you_ tested the kernel code on _your_ system to see if it
> was working correctly, and did not mean that I should use this with
> the problematic kernels on my system?  I could easily run this with
> something like 'modprobe stall' on my working machine, or on the
> problem machine if I boot with the "hpet=disabled" parameter, but
> doing so would not help us find the problem, right?

Yep.  This module was intended strictly to allow me to debug the
diagnostic code.

> 2.  Coincidentally, I had started reading Understanding the Linux Kernel
> (first edition, 2000) about a week before I got socked with the kernel
> freeze issue.  I was reading it at work -- I work as a tutor, and there
> are sometimes slow times without students to help -- but haven't had a
> chance to do so in the best 10 days while I've been struggling with my
> own kernel problem.  It is also quite out-of-date -- published in 2000,
> and discussing the 2.2 kernel line.  I know that there have been a
> couple of new editions since then, but I just happened to have this first
> edition on my shelf... so I took it into work for a little light reading.
> 
> Anyway, I have a lot on my personal TODO list for the fall, but maybe
> early next year I will have a chance to play with the kernel for fun.
> When I do so, I will have your new, experimental module to look at...
> among tons of other things.

Well, the stall module derives pretty directly from some example code
in Corbet, Rubini, and Kroah-Hartman's "Linux Device Drivers" book.  ;-)

							Thanx, Paul
