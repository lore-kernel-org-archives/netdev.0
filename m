From: Thomas Gleixner <tglx@linutronix.de>
Subject: RE: [E1000-devel] i217-LM boot wreckage
Date: Fri, 21 Mar 2014 15:51:56 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1403211551030.18573@ionos.tec.linutronix.de>
References: <alpine.DEB.2.02.1403201332400.18573@ionos.tec.linutronix.de> <alpine.DEB.2.02.1403201431580.18573@ionos.tec.linutronix.de> <2B0E3F215D1AB84DA946C8BEE234CCC9370CEFE3@ORSMSX101.amr.corp.intel.com> <alpine.DEB.2.02.1403201724500.18573@ionos.tec.linutronix.de>
 <alpine.DEB.2.02.1403211534040.18573@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Ertman, DavidX M" <davidx.m.ertman@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:50990 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965421AbaCUOvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 10:51:48 -0400
In-Reply-To: <alpine.DEB.2.02.1403211534040.18573@ionos.tec.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Mar 2014, Thomas Gleixner wrote:
> On Thu, 20 Mar 2014, Thomas Gleixner wrote:
> > On Thu, 20 Mar 2014, Ertman, DavidX M wrote:
> > > Hello Thomas,
> > > 
> > > Could you provide the exact kernel version and kernel config you are using?
> > 
> > 3.14-rc7. config attached
> > 
> > > Do you have Runtime Power Management enabled?
> > 
> > According to .config yes
> > 
> > > Have you tried the latest driver from sourceforge.net (3.0.4.1)?
> > 
> > Nope, why should I?
> 
> Now I got desperate enough to do. Doesnt work either.
>   
> > > From your lspci output it looks like you have a Management Engine
> > > enabled platform.  Do you know what version of ME is loaded?  Have
> > 
> > 9.0.2.1345
> > 
> > Disabling ME in the BIOS does not help.
> > 
> > > you checked to see that you are on the latest BIOS/NVM image (looks
> > > like a new one was released on March 11th for the M93z)?
> > 
> > Yep. Latest BIOS does not help either.
> 
> Just for extended fun: The Thinkpad L440 has the same issue.

Some more data. 3.12 does not work at all, 3.13 has the same behaviour
as 3.14.-rc7

Thanks,

	tglx
