From: Mikael Pettersson <mikpe@it.uu.se>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.2 - Ethernet and HSS
Date: Tue, 8 May 2007 10:26:49 +0200 (MEST)
Message-ID: <200705080826.l488Qnrb006666@harpo.it.uu.se>
Cc: jeff@garzik.org, linux-arm-kernel@lists.arm.linux.org.uk,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rmk@arm.linux.org.uk
To: khc@pm.waw.pl, mlj28@cam.ac.uk
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934672AbXEHI3L@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 8 May 2007 08:22:17 +0100, Michael-Luke Jones wrote:
> On 8 May 2007, at 02:19, Krzysztof Halasa wrote:
> 
> > Adds a driver for built-in IXP4xx Ethernet MAC and HSS ports
...
> > +#ifndef __ARMEB__
> > +#warning Little endian mode not supported
> > +#endif
> 
> This has gone from error to warning - fair play but if are planning  
> to put this upstream this cycle (anything's possible :) ) you'll want  
> to declare this driver broken on ARMEB in Kconfig please.
> 
> Personally I'd like LE ethernet tested and working before we push.

AFAIK, it's a HW limitation of the IXP4xx NPEs, or
possibly Intel's microcode for them.

I run my IXP42x boxes big-endian and don't mind doing so.

/Mikael
