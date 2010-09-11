From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH v2] usbnet: do not count empty skbs as errors in rx_process()
Date: Sat, 11 Sep 2010 14:15:29 -0700 (PDT)
Message-ID: <749423.9282.qm@web180313.mail.gq1.yahoo.com>
References: <201009112222.06149.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201009112222.06149.linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



--- On Sat, 9/11/10, Ondrej Zary wrote:

> Date: Saturday, September 11, 2010, 1:22 PM
> On Saturday 11 September 2010
> 21:07:59 David Brownell wrote:
> 
> > NAK to this backwards-incompatible change.
> >
> > >
> > > This is needed for cx82310_eth.

Backwards-incompatible changes are NOT "needed"
> >
> > I'd far rather see that driver fixed, than see
> > the core usbnet framework broken to avoid such
> > fixes to a very new driver ...
> 
> I already tried to explain that the driver is not broken

Yet you keep saying it doesn't work right, which
is the classic definition of "broken, needs fix".


> and so it cannot be 
> fixed. It's the way the hardware works and usbnet
> is not > ready for it.

And when we went over this before, I said how
to resolve this:   a *BACKWARD-COMPATIBLE change
that adds a new return state to rx_fixup(), used
in the cx82310 code.  Why didn't you try that?

This proposed patch doesn't do it, since it punts
on backwards compatibility ... which is a HUGE issue
when we can't easily test all the permutations.
Best to not risk breaking things; and in this case
there's not even any need to take such risks.

- Dave
