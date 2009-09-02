From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 2 Sep 2009 01:28:30 -0400
Message-ID: <20090902012830.54255912.billfink@mindspring.com>
References: <20090807205442.32918186.billfink@mindspring.com>
	<20090808015612.GA17710@localhost.localdomain>
	<20090814164412.be5daa74.billfink@mindspring.com>
	<20090814232543.GA28599@hmsreliant.think-freely.org>
	<20090820035044.9b70fca6.billfink@mindspring.com>
	<20090820201919.GA20750@localhost.localdomain>
	<20090821001421.214a560b.billfink@mindspring.com>
	<20090821152341.GA2998@localhost.localdomain>
	<20090826031057.375303c9.billfink@mindspring.com>
	<20090826110013.GA10816@hmsreliant.think-freely.org>
	<20090826180811.GB10816@hmsreliant.think-freely.org>
	<20090827133242.d02acece.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Linux Network Developers <netdev@vger.kernel.org>,
	brice@myri.com, gallatin@myri.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:55971 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752113AbZIBF22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 01:28:28 -0400
In-Reply-To: <20090827133242.d02acece.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 27 Aug 2009, Bill Fink wrote:

> On Wed, 26 Aug 2009, Neil Horman wrote:
> 
> > On Wed, Aug 26, 2009 at 03:10:57AM -0400, Bill Fink wrote:
> > > 
> > > Fortunately, in this specific case, the SuperMicro X8DAH+-F system
> > > does have a serial console, and after a fair amount of effort I was
> > > able to get it to work as desired, and was able to finally capture
> > > a backtrace of the kernel oops.  BTW I believe the reason the
> > > kexec/kdump didn't work was probably because it couldn't find
> > > a /proc/vmcore file, although I don't know why that would be,
> > > and the Fedora 10 /etc/init.d/kdump script will then just boot
> > > up normally if it fails to find the /proc/vmcore file (or it's
> > > zero size).
> > > 
> > I take care of kdump for fedora and RHEL.  If you file a bug on this, I'd be
> > happy to look into it further.
> 
> It's odd.  kexec/kdump works fine with the 2.6.29.6-217.2.3.fc11.x86_64
> kernel from Fedora 11 (running on the Fedora 10 system).  I will try
> again with the kernel-2.6.31-0.174.rc7.git2.fc12.src.rpm from Fedora 12,
> in case it has some secret sauce in one of the Fedora patches to make
> the Fedora /etc/init.d/kdump script happy.  kexec/kdump is my preferred
> method of dealing with kernel oopses if I can get it to work.

The Fedora 12 kernel-2.6.31-0.174.rc7.git2 kernel didn't help with
the kexec/kdump issue, so I may file a bug if I can't figure anything
out.

Also that kernel had a huge performance hit on my tests.  Where I
usually get ~100 Gbps of aggregate transmit performance, I was instead
getting a mere 3 Gbps, with individual streams only getting about
200 to 400 Mbps.  If I get a chance, I'll have to try the vanilla
version to see if it has the same issue (a vanilla 2.6.31-rc6 is
fine).

						-Thanks

						-Bill
