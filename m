From: David Miller <davem@davemloft.net>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Mon, 27 Aug 2007 13:37:21 -0700 (PDT)
Message-ID: <20070827.133721.59473971.davem@davemloft.net>
References: <46D1D634.7060007@katalix.com>
	<20070826.185815.93042514.davem@davemloft.net>
	<200708271147.01890.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, shemminger@linux-foundation.org,
	akepner@sgi.com, netdev@vger.kernel.org, raisch@de.ibm.com,
	themann@de.ibm.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, meder@de.ibm.com, tklein@de.ibm.com,
	stefan.roscher@de.ibm.com
To: ossthema@de.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763416AbXH0Uhw@vger.kernel.org>
In-Reply-To: <200708271147.01890.ossthema@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan-Bernd Themann <ossthema@de.ibm.com>
Date: Mon, 27 Aug 2007 11:47:01 +0200

> So the question is simply: Do we want drivers that need (benefit
> from) a timer based polling support to implement their own timers
> each, or should there be a generic support?

I'm trying to figure out how an hrtimer implementation would
even work.

Would you start the timer from the chip interrupt handler?  If so,
that's taking two steps backwards as you've already taken all of the
overhead of running the interrupt handler.
