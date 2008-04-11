From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch] e1000=y && e1000e=m regression fix
Date: Fri, 11 Apr 2008 07:36:44 -0400
Message-ID: <20080411113644.GA7767@infradead.org>
References: <20080408200652.GC28148@elte.hu> <47FBD34A.6080508@garzik.org> <20080408203314.GA28952@elte.hu> <47FBDBE9.9040700@garzik.org> <20080409193850.GA11763@elte.hu> <47FD2325.2030705@intel.com> <47FE5C89.5060209@intel.com> <20080410192714.GA14055@elte.hu> <47FE8566.5040809@intel.com> <20080411112653.GC9205@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>, Matthew Wilcox <matthew@wil.cx>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	Greg KH <greg@kroah.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760312AbYDKLha@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080411112653.GC9205@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 11, 2008 at 01:26:53PM +0200, Ingo Molnar wrote:
> really, just because you do exceedingly good things to Linux does not 
> give you a free card to do something bad to Linux in exchange. The two 
> do not cancel out each other - because the bad things _add up_ and drive 
> away users, irreversibly. To you e1000 is the center of the universe so 
> you feel the price is worth paying. For others it is not. We want the 
> good things from you and we'll say no thanks to the bad ideas. Kernel 
> developers, especially old-timers, regularly forget about that.

Hey, hey calm down.  The device moving over to e1000e shouldn never
have been added to e1000.  They're totally differnet and the only reason
they got added in thefirst time was because soemone talked intel into
it.

We discussed this a long time and came to a wide agreement it should
move out.  Now the actual transition could and should have been handled
better, but with all the pci-e hardware in a separate driver we're all
off better in the long term.

And this is not really comparable to the libata transition at all,
there's no user-visible changed.  For every distro kernel that just
builds both driver it's a completely seamless transition, and for
people who build their own kernel we should find some Kconfig trickery
to make the transition easier.  For example we could just built e1000e
when CONFIG_E1000 is set and spill a warning that starting from 1.1.2009
you will have to have CONFIG_E1000E set aswell.

> 
> 	Ingo
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
---end quoted text---
