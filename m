From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Sat, 12 Apr 2008 09:07:33 -0400
Message-ID: <20080412130733.GA21572@infradead.org>
References: <47FE8566.5040809@intel.com> <20080411112653.GC9205@elte.hu> <20080411113644.GA7767@infradead.org> <20080411121606.GA25661@elte.hu> <47FF9060.5040202@intel.com> <20080411164542.GA4066@infradead.org> <alpine.LFD.1.00.0804111028540.3143@woody.linux-foundation.org> <alpine.LNX.1.00.0804111700550.19665@iabervon.org> <alpine.LFD.1.00.0804111556200.3143@woody.linux-foundation.org> <47FFF7B5.3000609@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Daniel Barkalow <barkalow@iabervon.org>,
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
Received: from bombadil.infradead.org ([18.85.46.34]:43143 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbYDLNIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2008 09:08:07 -0400
Content-Disposition: inline
In-Reply-To: <47FFF7B5.3000609@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2008 at 07:43:49PM -0400, Jeff Garzik wrote:
> However, due to a mistake now released to the public -- a tiny few PCI-E 
> chips are supported by e1000 -- you have a widely disparate feature set:
>
> 	e1000, old chips:		full support
>
> 	e1000, a few PCI-E chips:	basic support
>
> 	e1000e, all PCI-E chips:	full support
>
> Since e1000e is all new and fancy AND CLEAN, the code for the same chips is 
> different -- thus Intel must make every PCI-E fix _twice_.
>
> It also means WE HAVE TO KEEP TOUCHING E1000, while supporting PCI-E chips. 
>  After this PCI-E issue is resolved, I want to let e1000 sit and be stable 
> and not be touched.
>
> For a temporary situation, this is fine.  Give me transition suggestions, 
> please!

PCI-E support should be removed from the e1000 driver ASAP, that is .26.
What we need is a way to have CONFIG_E1000 pull in the e1000e driver
automatically to not confuse kernel developers that don't know what
hardware they actually have..
