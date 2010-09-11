From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [PATCH v2] usbnet: do not count empty skbs as errors in rx_process()
Date: Sat, 11 Sep 2010 23:21:07 +0200
Message-ID: <201009112321.10002.linux@rainbow-software.org>
References: <749423.9282.qm@web180313.mail.gq1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1-out1.atlantis.sk ([80.94.52.55]:45437 "EHLO
	mail.atlantis.sk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752503Ab0IKVVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Sep 2010 17:21:17 -0400
In-Reply-To: <749423.9282.qm@web180313.mail.gq1.yahoo.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 11 September 2010 23:15:29 David Brownell wrote:
> --- On Sat, 9/11/10, Ondrej Zary wrote:
> > Date: Saturday, September 11, 2010, 1:22 PM
> > On Saturday 11 September 2010
> >
> > 21:07:59 David Brownell wrote:
> > > NAK to this backwards-incompatible change.
> > >
> > > > This is needed for cx82310_eth.
>
> Backwards-incompatible changes are NOT "needed"
>
> > > I'd far rather see that driver fixed, than see
> > > the core usbnet framework broken to avoid such
> > > fixes to a very new driver ...
> >
> > I already tried to explain that the driver is not broken
>
> Yet you keep saying it doesn't work right, which
> is the classic definition of "broken, needs fix".
>
> > and so it cannot be
> > fixed. It's the way the hardware works and usbnet
> > is not > ready for it.
>
> And when we went over this before, I said how
> to resolve this:   a *BACKWARD-COMPATIBLE change
> that adds a new return state to rx_fixup(), used
> in the cx82310 code.  Why didn't you try that?

Something like the first patch that started this thread?

-- 
Ondrej Zary
