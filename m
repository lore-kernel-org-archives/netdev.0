From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [patch 00/12] can: c_can: Fix a series of serious bugs and
 improve the performance
Date: Tue, 1 Apr 2014 11:07:14 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1404011106020.14882@ionos.tec.linutronix.de>
References: <20140318171007.528610837@linutronix.de> <alpine.DEB.2.02.1403312355280.14882@ionos.tec.linutronix.de> <533A742F.4090703@pengutronix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: LKML <linux-kernel@vger.kernel.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <533A742F.4090703@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Apr 2014, Marc Kleine-Budde wrote:
> On 04/01/2014 12:35 AM, Thomas Gleixner wrote:
> > Dear Maintainers,
> > 
> > On Tue, 18 Mar 2014, Thomas Gleixner wrote:
> >> The driver is full of serious bugs:
> >>
> >>     - Two HW init routines are not spec compliant.
> >>
> >>     - Completely defective message buffer handling in several ways
> >>       That leads to interrupt storms and complete lockups.
> >>
> >>     - Complete lack of SMP awareness
> >>
> >> What's amazing is that people "optimize" and "fix" the driver over and
> >> over, but nobody bothered to understand the manual and repair the code
> >> for real.
> >>
> >> The series fixes _ALL_ bugs which I found so far, but I'm sure there
> >> are more issues burried in that unreadable mess. I'm just not able to
> >> trigger them.
> > 
> > What's the state of this series?
> 
> I'll apply your patches today.

Thanks! Please drop the last one which was not part of the series:

	Subject: can: c_can: Reduce interrupt load by 50%

While it works like a charm, we've seen an odd case were TX started to
stall. Had not yet time to dig into that.

Thanks,

	tglx
