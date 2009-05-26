From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH] netdev: enc28j60: use IRQF_TRIGGER_FALLING for IRQ by default
Date: Tue, 26 May 2009 12:53:05 -0400
Message-ID: <200905261253.07364.vapier@gentoo.org>
References: <1243333007-25645-1-git-send-email-vapier@gentoo.org> <20090526110614.GA1987@jasper.tkos.co.il> <200905260424.17654.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Baruch Siach <baruch@tkos.co.il>,
	Michael Hennerich <michael.hennerich@analog.com>,
	netdev@vger.kernel.org, Bryan Wu <cooloney@kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:45514 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753417AbZEZQxG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2009 12:53:06 -0400
In-Reply-To: <200905260424.17654.david-b@pacbell.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 26 May 2009 07:24:17 David Brownell wrote:
> On Tuesday 26 May 2009, Baruch Siach wrote:
> > On Tue, May 26, 2009 at 06:16:47AM -0400, Mike Frysinger wrote:
> > > From: Michael Hennerich <michael.hennerich@analog.com>
> > >
> > > Rather than have the default IRQ flags not be usable, use the logical
> > > settings which match the hardware.  Since the part is /INT, it makes
> > > sense to have it default to a falling trigger.  If a board truly needs
> > > something different, it still can tweak the defaults in its own board
> > > file.
> >
> > You revert David Brownell's commit here
> > (c7b7b042068cd12b8b155722d24686f70b88ced1). Added to CC.
>
> Right ... the appended patch will *undo* the setting
> established in the board init code via set_irq_type().
>
> Moreover, it completely prevents working on systems which
> only support "both edges" triggering.

how can it provide breakage when people are forced to use set_irq_type() ?

> So I'd NAK this, on the grounds that it causes severe
> breakage.

i see no consumers of this driver at all in mainline, so i dont think it 
causes any in tree breakage at all
-mike
