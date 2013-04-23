From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from
 spin_lock_mutex
Date: Tue, 23 Apr 2013 13:50:16 -0400
Message-ID: <20130423175016.GC5564@hmsreliant.think-freely.org>
References: <20130423132345.GA5564@hmsreliant.think-freely.org>
 <CAO+b5-rQPyO9QE9v+oQTeo+G-ftcsehSB5=63AZ13QW4EJ1X0Q@mail.gmail.com>
 <20130423134443.GB5564@hmsreliant.think-freely.org>
 <20130423.133315.1278191592594257624.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bart.vanassche@gmail.com, netdev@vger.kernel.org, mingo@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55370 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756419Ab3DWRu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 13:50:27 -0400
Content-Disposition: inline
In-Reply-To: <20130423.133315.1278191592594257624.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 23, 2013 at 01:33:15PM -0400, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Tue, 23 Apr 2013 09:44:43 -0400
> 
> > Dave, how do you feel about it?  I'm comfortable with the wait queue change I've
> > proposed, but I've not received any reports of actual netpoll deadlocks (i.e.
> > the mutex solution is reporting a warning, but no actual problems).  So I think
> > its safe to wait a bit longer, unless you just want this squared away now.
> 
> If it's just a warning and people aren't actually hitting the
> potential deadlock, it can wait.
> 
Copy that. Bart, I'll wait till you get back then.
Neil
