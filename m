From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Fore 200 firmware
Date: Tue, 1 Jun 2010 18:12:04 +0100
Message-ID: <20100601171203.GJ5306@decadent.org.uk>
References: <201006011549.o51FnZFk028507@thirdoffive.cmf.nrl.navy.mil> <alpine.SOC.1.00.1006011902490.22519@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas3@users.sourceforge.net, netdev@vger.kernel.org
To: Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38886 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757023Ab0FARMI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 13:12:08 -0400
Content-Disposition: inline
In-Reply-To: <alpine.SOC.1.00.1006011902490.22519@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 01, 2010 at 06:03:31PM +0100, Meelis Roos wrote:
> > >does not have to redo the detective work I am doing. Packaging it along 
> > >with linux-atm packages (atm-tools in Debian) does not seem correct, so 
> > >do we need to make a special firmware package out of it or just add to 
> > >some other firmware repo that is packaged already?
> > 
> > i dont care which happens really.  i would to think it is part of
> > atm-tools since the fore200e driver really isnt useful with the
> > atm tools.
> 
> OK, so we should push the distro maintainers of it to create a suggested 
> firmware package or just include the fore firmware unconditionally - 
> once it is in released linux-atm.
> 
> > >What's the licence of the firmware anyway - unknown likely?
> > 
> > it says the firmware is gpl.  look at fore200e_firmware_copyright
> > in one of the old kernel distros.
> 
> Well, there is no source to fulfill the GPL... but there also should be 
> no problem redistributing it.
[...]
 
The GPL says (approximately) that people are allowed to redistribute binaries
only if they also redistribute source.  If the source is not available to the
public then anyone redistributing it is relying on the assumption that the
copyright holder didn't really mean this condition and will not enforce it.
At any time the copyright holder could sue them for copyright infringement,
and they would have to rely on a defence such as laches.

This is a common problem with firmware images that were added to the kernel
long ago.  To reduce legal risk, Debian has been removing these images and
will not include them in any future releases, even in the non-free archive
section, unless this is fixed.  Please do not try to add this firmware to
Debian without getting an appropriate licence.
 
Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
