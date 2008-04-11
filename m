From: Willy Tarreau <w@1wt.eu>
Subject: Re: [regression] e1000e broke e1000
Date: Fri, 11 Apr 2008 21:29:30 +0200
Message-ID: <20080411192930.GB8474@1wt.eu>
References: <20080408183921.GA20803@elte.hu> <20080408193245.GG11962@parisc-linux.org> <20080408195123.GA28148@elte.hu> <47FBCE00.2020309@garzik.org> <20080408200652.GC28148@elte.hu> <47FBD620.1080508@intel.com> <20080409191256.GB9276@elte.hu> <47FD19F5.9020509@garzik.org> <20080411113018.GD9205@elte.hu> <47FF8667.7090202@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Jeff Garzik <jeff@garzik.org>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Matthew Wilcox <matthew@wil.cx>,
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
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2328 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757903AbYDKTe3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 15:34:29 -0400
Content-Disposition: inline
In-Reply-To: <47FF8667.7090202@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 11, 2008 at 09:40:23AM -0600, Chris Friesen wrote:
> Ingo Molnar wrote:
> 
> >well, your 2.6.26 plans, if i understand them correctly, is to move 
> >currently working PCI IDs from e1000 to e1000e, like you attempted to d 
> >it in v2.6.24, which Linus reverted - correct? I.e. e1000 simply wont 
> >support eth0 on my T60 from 2.6.26 on? That is still an incredibly 
> >stupid plan, and no amount of announcement on lkml will make it any less 
> >stupid.
> 
> It seems like you're saying that once hardware is supported by a 
> particular config option, it can never ever be split out to another 
> config option, even if it makes both drivers cleaner.
> 
> A similar situation happened when the sk98lin driver was split into skge 
> and sky2...I don't remember a big fuss back then.  Is it just that no 
> major developers were using the hardware so they didn't notice?

The difference is that :
  1) either could be used for a long time
  2) the old worked so bad that the word has spread among people in forums
     to try the new driver instead.

I think that splitting drivers should be something accepted in the kernel's
lifetime, but users must not be left confused. It's clearly easier to insert
ourselves in their common process to wave hands indicating that their setup
will soon not work anymore (eg: by having e1000 indicate what driver must be
loaded for unsupported devices).

Willy
