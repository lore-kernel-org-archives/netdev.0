From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 00/21] ARCNET: Defibrillation
Date: Tue, 05 May 2015 10:02:30 -0700
Message-ID: <1430845350.7191.36.camel@perches.com>
References: <1429896055-31680-1-git-send-email-m.grzeschik@pengutronix.de>
	 <1429901273.23327.5.camel@perches.com> <553AB241.3080004@pengutronix.de>
	 <20150424.235853.1997287895150693202.davem@davemloft.net>
	 <20150427145715.GC23151@pengutronix.de>
	 <1430365765.2575.5.camel@perches.com>
	 <20150505164310.GA26406@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mkl@pengutronix.de,
	David Miller <davem@davemloft.net>, kernel@pengutronix.de,
	linux-kernel@vger.kernel.org
To: Michael Grzeschik <mgr@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150505164310.GA26406@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-05-05 at 18:43 +0200, Michael Grzeschik wrote:
> On Wed, Apr 29, 2015 at 08:49:25PM -0700, Joe Perches wrote:
> > I was away for a few days and while out I did another
> > restructuring of all the inb/outb/readb/writeb code
> > removing all the A<FOO> macros.  It removes all the
> > dependencies on ioaddr and names all the offsets with
> > new defines.
> > 
> > I could post if you like.
> 
> Sure, you should do that! I will rework my patches on top of them.

As it's ~400KB and very few are likely interested,
I'll send them to you privately.

> I would like to know what David things about the whole work.

I think he already said what he thinks.

As arcnet has neither a maintainer nor an active
user base, arcnet is in "bugfix only mode".

Testing coverage is the biggest issue.

If you want to become the maintainer for arcnet
and have sufficient time and hardware to verify
that changes don't break things, great!

Responsibility then shifts to you.

Enjoy! (and thanks)
