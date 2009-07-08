From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Wed, 8 Jul 2009 10:08:52 +0200
Message-ID: <20090708080852.GC3148@ami.dom.local>
References: <200907031326.21822.andres@anarazel.de> <200907071534.07619.andres@anarazel.de> <20090707135742.GB6798@ami.dom.local> <200907071811.27570.andres@anarazel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joao Correia <joaomiguelcorreia@gmail.com>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andres Freund <andres@anarazel.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759591AbZGHIJf@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200907071811.27570.andres@anarazel.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 07, 2009 at 06:11:27PM +0200, Andres Freund wrote:
> On Tuesday 07 July 2009 15:57:42 Jarek Poplawski wrote:
> > On Tue, Jul 07, 2009 at 03:34:07PM +0200, Andres Freund wrote:
> > ...
> > > Testing wether its triggerable inside a vm might be interesting...
> > Probably similarly to testing without this patch or even less. Maybe
> > I should've warned you but this type of bugs in -rc with possible
> > memory or stack overwrites might be fatal for your data (at least).
> Fortunately all the data on that machine should either be replaceable or 
> regularly backuped.
> 
> Will test later today if that patch bugs.

If you didn't start yet, it would be nice to use this, btw:

CONFIG_HOTPLUG_CPU = N
CONFIG_DEBUG_OBJECTS = Y
CONFIG_DEBUG_OBJECTS_TIMERS = Y

Thanks,
Jarek P.
