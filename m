From: renevant@internode.on.net
Subject: Re: ax88179 regression
Date: Sun, 09 Feb 2014 18:51:27 +1100
Message-ID: <1613065.q9aFchjqPg@athas>
References: <1890496.0JLCYTPnkG@athas> <1519315.vRJdGOYKiP@athas>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: renevant@internode.on.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:50668 "EHLO
	ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751696AbaBIHwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 02:52:39 -0500
In-Reply-To: <1519315.vRJdGOYKiP@athas>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Absolute last post from me. 

I migrated to a Intel Sandy Bridge based system to test. Definitely something 
going on with the AMD based system, could be power supply/motherboard bios 
related.

On the Intel system the ax88179 still locked up one time.  I rebuilt with for-
usb-linus tree merged and I reverted:

2a100047481a5c7430c72883b586eb6f2df34812 

xhci: remove conversion from generic to pci device in xhci_mem.c

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=2a100047481a5c7430c72883b586eb6f2df34812


I can't say for sure if this commit is a problem but this kernel build has 
been up now for several hours without an issue and i've put it through paces 
that usually lock up the nic.


Regards,

Will Trives


On Saturday 08 February 2014 14:56:17 renevant@internode.on.net wrote:
> Everything is still working at commit
> 63a67a72d63dd077c2313cf19eb29d8e4bfa6963
> 
> At this point i'm beginning to think all the issues i've been having are
> motherboard bios and compiler flag issues.
> 
> Regards,
> 
> Will Trives
> 
> On Saturday 08 February 2014 12:56:10 renevant@internode.on.net wrote:
> > Hello,
> > 
> > I have finally nailed down my other issues and i'm at a point where I can
> > bisect from a point that is 100% stable and working.
> > 
> > 
> > I am currently running a kernel checked out at commit
> > d194c031994d3fc1038fa09e9e92d9be24a21921
> > 
> > A point in 3.12rc4
> > 
> > At this point the ax88179 works without issue even with scatter gather
> > turned on. So somewhere from this point something goes wrong and there is
> > some condition that exists that can lock up the nic.
> > 
> > 
> > I will keep bisecting at report my findings.
> > 
> > 
> > Regards,
> > 
> > Will Trives
