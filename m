From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 01/10] smc91x: remove unused code enclosed by #ifdef
 CONFIG_ISA .. #endif
Date: Fri, 27 Jun 2008 09:48:34 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0806270941460.2979@xanadu.home>
References: <1214300867-15495-2-git-send-email-eric.y.miao@gmail.com>
 <486480E6.8070804@garzik.org> <48648467.1080308@gmail.com>
 <4864894C.8040508@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Eric Miao <eric.y.miao@gmail.com>,
	linux-arm-kernel <linux-arm-kernel@lists.arm.linux.org.uk>,
	linux-netdev <netdev@vger.kernel.org>,
	Magnus Damm <magnus.damm@gmail.com>,
	Eric Miao <eric.miao@marvell.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:43343 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbYF0Nsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 09:48:42 -0400
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR004.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0K3400ADIJOY1G70@VL-MO-MR004.ip.videotron.ca> for
 netdev@vger.kernel.org; Fri, 27 Jun 2008 09:48:35 -0400 (EDT)
In-reply-to: <4864894C.8040508@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Jun 2008, Jeff Garzik wrote:

> Eric Miao wrote:
> > Jeff Garzik wrote:
> > > Eric Miao wrote:
> > > > Apparently, the code enclosed by #ifdef CONFIG_ISA .. #endif are no
> > > > longer
> > > > used
> > > What does this mean?
> > > 
> > > CONFIG_ISA platforms still exist, and one presumes that the ISA hardware
> > > still exists.
> > > 
> > > Is this hardware covered by another driver?
> > > 
> > 
> > Well, I assume the original code tends to support ISA with module
> > parameters to setup the IO address base and IRQ etc. But obviously,
> > those part of the code is now totally invalid and confusing only.
> > 
> > Should there be requirement of supporting ISA hardware with this
> > chip, the driver is actually unable to, and I prefer to re-write
> > that part of the code if necessary.
> > 
> > BTW: I don't know any ISA NIC with a SMC91X chip by far, and I
> > cannot infer by the driver code itself what type of ISA NIC it
> > is supporting.
> 
> These are questions that must be researched...
> 
> Where did the ISA support come from?

>From the original driver before I started maintaining it years ago.

> Was it copied from another driver, or did it actually work on real hardware at
> some point in the past?

It did work on real hardware since, originally, the SMC91C9x chips were 
found on ISA cards only.

> If the latter, when did ISA support stop working?  i.e. a regression occurred

Long long ago I'm afraid.  I even sent a call for help from someone with 
an actual ISA card a couple years ago with no response.  I suspect ISA 
support has been broken for quite a while now and no one ever 
complained.

> Certainly if the driver has -never- worked on ISA hardware, then the code
> should be removed.  Who knows the definitive answer?  What does the driver
> look like in older (pre-2.6.12) kernels?

I started hacking on that driver in the 2.4.x days, and I suspect I 
could have broken ISA at that time.


Nicolas
