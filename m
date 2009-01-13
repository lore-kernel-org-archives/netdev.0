From: Willy Tarreau <w@1wt.eu>
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading (-git7 is ok)
Date: Tue, 13 Jan 2009 07:13:23 +0100
Message-ID: <20090113061322.GJ5038@1wt.eu>
References: <1231676698.25018.147.camel@macbook.infradead.org> <20090111.133929.57600645.davem@davemloft.net> <1231711347.25018.658.camel@macbook.infradead.org> <20090111.140559.126980927.davem@davemloft.net> <1231713698.25018.700.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Valdis.Kletnieks@vt.edu,
	alessandro.suardi@gmail.com, jaswinderlinux@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1438 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759652AbZAMGOJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2009 01:14:09 -0500
Content-Disposition: inline
In-Reply-To: <1231713698.25018.700.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 11, 2009 at 10:41:38PM +0000, David Woodhouse wrote:
> On Sun, 2009-01-11 at 14:05 -0800, David Miller wrote:
> > So what used to work out of the box by typing make now
> > will have all kinds of strange depencies, right?
> > 
> > This is a regression, no matter how you spin it, in my
> > book.
> 
> I know you think that, but I disagree. Yes, it's slightly less
> convenient for a small handful of older drivers,

We're speaking about the driver for the on-board NIC which is present on
almost 100% of the servers built since the last 5 years. There are an
awful lot of users of this driver playing with PXE, nfsroot and other
non-legacy boot methods. So "small handful" or not, we must ensure not
to annoy a lot of users with strange bugs and awkward configurations.

> but in the general case
> it's a massive improvement -- because now we can have a single canonical
> location to collect _all_ the firmware that is redistributable, for use
> with the kernel. And we've already started adding a whole bunch of new
> firmwares to that repository.

In the past, the firmware distributed with the driver was always the
one known to work with that version of the driver. Now you'll have to
know what version of the firmware to use with what kernel version,
this is adding a new dimension to troubleshooting complexity.

I still think that these firmware hacks are a solution looking for
a problem to solve. We had something which has worked well for 15
years and now it's easy to see a machine hang at boot time for 60
seconds because a firmware file is missing or invalid.

Regression IMO, I agree with Davem.

Willy

