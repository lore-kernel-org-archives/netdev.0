From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from
 spin_lock_mutex
Date: Tue, 23 Apr 2013 09:44:43 -0400
Message-ID: <20130423134443.GB5564@hmsreliant.think-freely.org>
References: <20130412184542.GB19966@hmsreliant.think-freely.org>
 <51690AAB.1030102@acm.org>
 <20130415141610.GA3505@hmsreliant.think-freely.org>
 <CAO+b5-oBfH3M0dnrQSs-p1BF_5hKy2tsU-dD=EP9+S=iqPs5ew@mail.gmail.com>
 <20130416172454.GC9241@hmsreliant.think-freely.org>
 <20130418192912.GB29130@hmsreliant.think-freely.org>
 <20130422201246.GA20687@hmsreliant.think-freely.org>
 <CAO+b5-r5jVJNZWuREUH5MQ3baeSPR8fVV1p9pMnukmiZd9nRhg@mail.gmail.com>
 <20130423132345.GA5564@hmsreliant.think-freely.org>
 <CAO+b5-rQPyO9QE9v+oQTeo+G-ftcsehSB5=63AZ13QW4EJ1X0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>
To: Bart Van Assche <bart.vanassche@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50431 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312Ab3DWNou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 09:44:50 -0400
Content-Disposition: inline
In-Reply-To: <CAO+b5-rQPyO9QE9v+oQTeo+G-ftcsehSB5=63AZ13QW4EJ1X0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 23, 2013 at 06:38:19AM -0700, Bart Van Assche wrote:
> On Tue, Apr 23, 2013 at 6:23 AM, Neil Horman <nhorman@tuxdriver.com> wrote:
> 
> > Copy that.  I can propose this change based on my own testing, or wait for
> > you
> > to get back.  Do you have a preference?
> >
> 
> It will take until next week before I can run more tests. It depends on
> whether a fix can wait that long ?
> 
> Bart.
Dave, how do you feel about it?  I'm comfortable with the wait queue change I've
proposed, but I've not received any reports of actual netpoll deadlocks (i.e.
the mutex solution is reporting a warning, but no actual problems).  So I think
its safe to wait a bit longer, unless you just want this squared away now.

FWIw, I think theres still some discussion to be had about the possibility of
converting mutexes to use spin_lock_irqsave internally, thereby making
mutex_trylock irq safe, but I think we can deal with that independently of this
issue.

Regards
Neil
