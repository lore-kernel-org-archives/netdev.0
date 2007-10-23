From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 5/7] pci: Export the pci_restore_msi_state() function
Date: Tue, 23 Oct 2007 10:29:24 +1000
Message-ID: <1193099364.6745.168.camel@pasglop>
References: <1192829817.22064.559.camel@teletran1>
	 <20071021.162131.43417026.davem@davemloft.net>
	 <1193017764.10318.17.camel@concordia>
	 <20071022181336.GC4280@austin.ibm.com> <1193088267.6745.108.camel@pasglop>
	 <20071023001307.GF4280@austin.ibm.com>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	mcarlson@broadcom.com, linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	mchan@broadcom.com, linux-pci@atrey.karlin.mff.cuni.cz,
	David Miller <davem@davemloft.net>
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57872 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750798AbXJWAcL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 20:32:11 -0400
In-Reply-To: <20071023001307.GF4280@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> > I don't know why you keep talking about powerpc laptops here ... 
> 
> Well, there are Apple laptops, right?  Aren't those the "powermac" 
> platform?  Now, I don't know if they support MSI, but if they do,
> I get the impression that they might not restore msi state correctly,
> after being put into hardware suspend.  But perhaps I'm mistaken;
> I was simply grepping for various msi-related functions in various
> arch subdirectories, comparing x86 to other arches, and noticed 
> that code that would restore msi state seems to be missing for
> most arches and most powerpc platforms.

Ah ok, i see. Well, platforms that use write_msi_msg() shouldn't need
anything special right ? So only pSeries is an issue here....

PowerBooks don't indeed have MSI support, though G5's do and some people
have been toying around with suspend/resume on them (hibernation only at
that stage) but it doesn't matter at this stage. We are specifically
talking about pSeries which is the "special" case here.

Ben.


