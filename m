From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [regression] e1000e broke e1000
Date: Wed, 09 Apr 2008 15:33:09 -0400
Message-ID: <47FD19F5.9020509@garzik.org>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu> <47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu> <20080408193245.GG11962@parisc-linux.org> <20080408195123.GA28148@elte.hu> <47FBCE00.2020309@garzik.org> <20080408200652.GC28148@elte.hu> <47FBD620.1080508@intel.com> <20080409191256.GB9276@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40457 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753595AbYDITdj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 15:33:39 -0400
In-Reply-To: <20080409191256.GB9276@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> The most common distro setup is E1000=m and E1000E=m. The most common 
> embedded setup is _one_ of the two drivers as =y.

Agreed, and agreed.


> So i'm not sure why 
> you are arguing about all this. Please just fix this bug, simple as 
> that.

I haven't said NAK, but I think the suggested fix is a waste of time because

1) it breaks (by disallowing) a valid setup based on one report

2) it only happens to experienced kernel hackers with weird configs

3) the suggested fix binds together more tightly two drivers we are 
trying to keep separate

4) it is a temporary situation that will go away in 2.6.26 anyway

So from my point of view, your request is to pick the breakage you don't 
care about (#1, above) to fix the breakage you do care about.

It's a "pick your poison" choice, from my POV.

Given that POV, that's why I lean towards avoiding your Kconfig fix -- 
viewing this as a transition issue, and not something to be fixed by 
limiting the choices of others.

But if everyone strongly agrees with you... go ahead and patch, I won't 
NAK it.

I dislike the Kconfig system growing "temporary" hacks, which tend to 
accumulate false dependencies over time.  But I readily admit that's a 
general principle and not a hard rule...

	Jeff


