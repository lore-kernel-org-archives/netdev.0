From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [BUG] powerpc does not save msi state [was Re: [PATCH 5/7]
	pci: Export the pci_restore_msi_state() function
Date: Sat, 20 Oct 2007 11:29:40 +1000
Message-ID: <1192843780.17235.17.camel@pasglop>
References: <20071019232926.GL29903@austin.ibm.com>
	 <1192840577.5369.9.camel@dell> <20071020000421.GO29903@austin.ibm.com>
	 <20071019.172706.57467960.davem@davemloft.net>
	 <20071020004610.GR29903@austin.ibm.com>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, linux-pci@atrey.karlin.mff.cuni.cz,
	mcarlson@broadcom.com, mchan@broadcom.com,
	Michael Ellerman <ellerman@au1.ibm.com>
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:43235 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753393AbXJTBaM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 21:30:12 -0400
In-Reply-To: <20071020004610.GR29903@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I'm cc'ing the powerpc mailing list to point this out: 
> it looks like only cell/axon_msi.c and mpic_u3msi.c 
> bother do do anything.  I guess that there aren't any old 
> macintosh laptops that have msi on them? Because without
> this, suspend and resume breaks.

The only macs that can do any form of MSIs are the G5s using
mpic_u3msi.c

> Paul,
> On the off chance your reading this, I'll send a pseries
> patch on Monday, with luck (and some other patches too).
> I'm not touching any of the other plaforms, you and benh 
> would know those better.

Or rather Michael as he wrote the ppc MSI support. I'll check with him

Ben.


