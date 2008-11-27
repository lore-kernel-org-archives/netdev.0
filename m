From: Alex Chiang <achiang@hp.com>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Thu, 27 Nov 2008 12:42:10 -0700
Message-ID: <20081127194210.GB28870@ldl.fc.hp.com>
References: <492DD792.6080302@linux.intel.com> <200811261605.43099.jbarnes@virtuousgeek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>, x86@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Theodore Ts'o <tytso@mit.edu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:14529 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523AbYK0TmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 14:42:16 -0500
Content-Disposition: inline
In-Reply-To: <200811261605.43099.jbarnes@virtuousgeek.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Jesse Barnes <jbarnes@virtuousgeek.org>:
> On Wednesday, November 26, 2008 3:11 pm Arjan van de Ven wrote:
> > Rank 2: pci_create_slot (warning)
> > 	Reported 603 times (639 total reports)
> > 	BIOS provided duplicated slot names, the PCI layer blindly passes to sysfs
> > 	This warning was last seen in version 2.6.27.5, and first seen in
> > 2.6.27-rc7-git1. More info:
> > http://www.kerneloops.org/searchweek.php?search=pci_create_slot
> 
> IIRC we fixed this one post-2.6.27.  I didn't send the patches back to -stable 
> because they were a bit big, but if someone were sufficiently motiviated I'm 
> sure the backport wouldn't be that hard...

I can do this backport. A few questions though...

We're seeing a proliferation of this one presumably because
Fedora10 uses 2.6.27.5 as a starting point? If I just backport
the fixes against Greg's latest tree, do I have to do anything
special to make sure they get into the Fedora kernel?

Also, does kerneloops capture any of the machine information,
like DMI output, etc. or does it just get the oops? It would be
nice to see which machines out there have the broken BIOS that
causes this oops.

Thanks.

/ac

