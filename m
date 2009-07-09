From: Andres Freund <andres@anarazel.de>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 ( possibly?caused by netem)
Date: Thu, 9 Jul 2009 18:46:37 +0200
Message-ID: <200907091846.37926.andres@anarazel.de>
References: <200907031326.21822.andres@anarazel.de> <200907091728.23367.andres@anarazel.de> <alpine.LFD.2.00.0907091801130.24704@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Joao Correia <joaomiguelcorreia@gmail.com>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Peter Zijlstra <peterz@infradead.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.anarazel.de ([217.115.131.40]:43829 "EHLO smtp.anarazel.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759419AbZGIQqm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 12:46:42 -0400
In-Reply-To: <alpine.LFD.2.00.0907091801130.24704@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 09 July 2009 18:01:56 Thomas Gleixner wrote:
> Andres,
>
> On Thu, 9 Jul 2009, Andres Freund wrote:
> > On Thursday 09 July 2009 16:28:05 Thomas Gleixner wrote:
> > > Please test them separate from each other. The one I sent in this
> > > thread was just for narrowing down the issue, but I'm now quite sure
> > > that they really hit the issue which is addressed by the hrtimer
> > > patch.
> >
> > No crash yet. 15min running (seconds to a minute before).
> >
> > Will let it run for some hours to be sure.
>
> Which one of the patches are you testing ?
Your "real" one, i.e. de907e8432b08f2d5966c36e0747e97c0e596810

1h30m now...


Andres
