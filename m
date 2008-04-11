From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: [regression] e1000e broke e1000
Date: Fri, 11 Apr 2008 09:40:23 -0600
Message-ID: <47FF8667.7090202@nortel.com>
References: <20080408083606.GA20863@elte.hu> <47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu> <20080408193245.GG11962@parisc-linux.org> <20080408195123.GA28148@elte.hu> <47FBCE00.2020309@garzik.org> <20080408200652.GC28148@elte.hu> <47FBD620.1080508@intel.com> <20080409191256.GB9276@elte.hu> <47FD19F5.9020509@garzik.org> <20080411113018.GD9205@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
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
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760968AbYDKPlc@vger.kernel.org>
In-Reply-To: <20080411113018.GD9205@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:

> well, your 2.6.26 plans, if i understand them correctly, is to move 
> currently working PCI IDs from e1000 to e1000e, like you attempted to d 
> it in v2.6.24, which Linus reverted - correct? I.e. e1000 simply wont 
> support eth0 on my T60 from 2.6.26 on? That is still an incredibly 
> stupid plan, and no amount of announcement on lkml will make it any less 
> stupid.

It seems like you're saying that once hardware is supported by a 
particular config option, it can never ever be split out to another 
config option, even if it makes both drivers cleaner.

A similar situation happened when the sk98lin driver was split into skge 
and sky2...I don't remember a big fuss back then.  Is it just that no 
major developers were using the hardware so they didn't notice?

Chris
