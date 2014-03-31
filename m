From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch 00/12] can: c_can: Fix a series of serious bugs and
 improve the performance
Date: Tue, 1 Apr 2014 00:35:24 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1403312355280.14882@ionos.tec.linutronix.de>
References: <20140318171007.528610837@linutronix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20140318171007.528610837@linutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Maintainers,

On Tue, 18 Mar 2014, Thomas Gleixner wrote:
> The driver is full of serious bugs:
> 
>     - Two HW init routines are not spec compliant.
> 
>     - Completely defective message buffer handling in several ways
>       That leads to interrupt storms and complete lockups.
> 
>     - Complete lack of SMP awareness
> 
> What's amazing is that people "optimize" and "fix" the driver over and
> over, but nobody bothered to understand the manual and repair the code
> for real.
> 
> The series fixes _ALL_ bugs which I found so far, but I'm sure there
> are more issues burried in that unreadable mess. I'm just not able to
> trigger them.

What's the state of this series?

The only reaction so far was a hasty commit of cosmetic add ons to my
findings at [1] accompanied with the following mail which was not a
direct reply to my patches but merily a new mail to the can mailing
list:

  " Subject: [PATCH 1/2] can: c_can: improve error checking

    as mentioned in the other mail, a patch that adds return value
    checking to all users of c_can_set_bittiming(). Another patch adds
    the missing netif_napi_del(). Feel free to include the patches in
    your series or use the testing-c_can branch [1] as your git base.
  "

I'm really grateful, that you allowed me to include these patches to
my series. But that does not help anything at all:

 - The driver is still broken as it has been for years

 - You as the maintainer reacted by submitting a pointless patch to
   base my series on instead of applying the obvious and well
   documented bug fixes right away.

 - Just for the record, the series fixes the fatal issues of that
   driver with and without the extra cosmetic fixes which are just a
   supplement for the real issues.
  
What's going on here?  Are we going to have another few kernel
releases with a completely defunct driver in place?

Thanks,

	tglx
---
[1] git://gitorious.org/linux-can/linux-can-next.git testing-c_can

