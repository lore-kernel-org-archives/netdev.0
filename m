From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Thu, 27 Nov 2008 11:49:38 -0800
Message-ID: <20081127114938.573b7acf@linux.intel.com>
References: <492DD792.6080302@linux.intel.com>
	<200811261605.43099.jbarnes@virtuousgeek.org>
	<20081127194210.GB28870@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, x86@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Theodore Ts'o <tytso@mit.edu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Alex Chiang <achiang@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57717 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376AbYK0Tsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 14:48:41 -0500
In-Reply-To: <20081127194210.GB28870@ldl.fc.hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Nov 2008 12:42:10 -0700
Alex Chiang <achiang@hp.com> wrote:

> * Jesse Barnes <jbarnes@virtuousgeek.org>:
> > On Wednesday, November 26, 2008 3:11 pm Arjan van de Ven wrote:
> > > Rank 2: pci_create_slot (warning)
> > > 	Reported 603 times (639 total reports)
> > > 	BIOS provided duplicated slot names, the PCI layer
> > > blindly passes to sysfs This warning was last seen in version
> > > 2.6.27.5, and first seen in 2.6.27-rc7-git1. More info:
> > > http://www.kerneloops.org/searchweek.php?search=pci_create_slot
> > 
> > IIRC we fixed this one post-2.6.27.  I didn't send the patches back
> > to -stable because they were a bit big, but if someone were
> > sufficiently motiviated I'm sure the backport wouldn't be that
> > hard...
> 
> I can do this backport. A few questions though...
> 
> We're seeing a proliferation of this one presumably because
> Fedora10 uses 2.6.27.5 as a starting point? If I just backport
> the fixes against Greg's latest tree, do I have to do anything
> special to make sure they get into the Fedora kernel?

Fedora tends to follow -stable quite closely so that ought to be enough

> 
> Also, does kerneloops capture any of the machine information,
> like DMI output, etc. or does it just get the oops? It would be
> nice to see which machines out there have the broken BIOS that
> causes this oops.

right now we do this for oopses, but not for warnings ;(
I'll make a patch to add this; it's generally useful.


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
