From: Andres Freund <andres@anarazel.de>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 ( possibly?caused by netem)
Date: Tue, 7 Jul 2009 15:34:07 +0200
Message-ID: <200907071534.07619.andres@anarazel.de>
References: <200907031326.21822.andres@anarazel.de> <200907071522.06812.andres@anarazel.de> <20090707132937.GA6798@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Joao Correia <joaomiguelcorreia@gmail.com>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.anarazel.de ([217.115.131.40]:32822 "EHLO smtp.anarazel.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754791AbZGGNeM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jul 2009 09:34:12 -0400
In-Reply-To: <20090707132937.GA6798@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 07 July 2009 15:29:37 Jarek Poplawski wrote:
> On Tue, Jul 07, 2009 at 03:22:06PM +0200, Andres Freund wrote:
> > On Tuesday 07 July 2009 15:18:03 Jarek Poplawski wrote:
> > > On Tue, Jul 07, 2009 at 11:40:16AM +0100, Joao Correia wrote:
> > > > I am now running 2.6.31-rc2 for a couple of hours, no freeze.
> > > > Let me know what/if i can help with tracking down the original source
> > > > of the problem.
> > >
> > > OK, so we know it's only about timers. Here is another tiny patch
> > > (the previous one should be removed), which could tell (with oops) if
> > > there's something while migrating. Anyway, the bug should be back :-(
> > PS: You forgot the patch ;-)
> Yes, I hope you got it already ;-)
Yes. Can't reboot that machine right now, will test later.

Testing wether its triggerable inside a vm might be interesting...

Andres
