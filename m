From: Daniel Barkalow <barkalow@iabervon.org>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Fri, 11 Apr 2008 19:05:35 -0400 (EDT)
Message-ID: <alpine.LNX.1.00.0804111852070.19665@iabervon.org>
References: <47FBDBE9.9040700@garzik.org> <20080409193850.GA11763@elte.hu> <47FD2325.2030705@intel.com> <47FE5C89.5060209@intel.com> <20080410192714.GA14055@elte.hu> <47FE8566.5040809@intel.com> <20080411112653.GC9205@elte.hu> <20080411113644.GA7767@infradead.org>
 <20080411121606.GA25661@elte.hu> <47FF9060.5040202@intel.com> <20080411164542.GA4066@infradead.org> <alpine.LFD.1.00.0804111028540.3143@woody.linux-foundation.org> <alpine.LNX.1.00.0804111700550.19665@iabervon.org> <47FFE44F.90706@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Ingo Molnar <mingo@elte.hu>, Matthew Wilcox <matthew@wil.cx>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	Greg KH <greg@kroah.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iabervon.org ([66.92.72.58]:40388 "EHLO iabervon.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756905AbYDKXFi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 19:05:38 -0400
In-Reply-To: <47FFE44F.90706@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Apr 2008, Jeff Garzik wrote:

> Daniel Barkalow wrote:
> > Right now, E1000 means "support both PCI and PCI-E E1000" and E1000E means
> > "support PCI-E E1000".
> 
> It's even more confusing than that :)
> 
> E1000 means "support PCI and a few PCI-E"
> 
> E1000E means "all PCI-E"
> 
> There is a goodly number of PCI-E not supported by e1000 (some ich8, all ich9
> and thereafter).

Okay, so with my change E1000 will incidentally give you ich9 support. But 
it doesn't fail to "support PCI and a few PCI-E", it just does some more 
that it has to give you for coverage of the traditional things.

	-Daniel
*This .sig left intentionally blank*
