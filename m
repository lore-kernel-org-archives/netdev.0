From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [regression] e1000e broke e1000
Date: Tue, 08 Apr 2008 16:56:09 -0400
Message-ID: <47FBDBE9.9040700@garzik.org>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu> <47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu> <20080408193245.GG11962@parisc-linux.org> <20080408195123.GA28148@elte.hu> <47FBCE00.2020309@garzik.org> <20080408200652.GC28148@elte.hu> <47FBD34A.6080508@garzik.org> <20080408203314.GA28952@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matthew Wilcox <matthew@wil.cx>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
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
Received: from srv5.dvmed.net ([207.36.208.214]:39510 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751776AbYDHU4S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 16:56:18 -0400
In-Reply-To: <20080408203314.GA28952@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> No other 
> PCI driver breaks like this.

That's because PCI ID transitions are extremely, extremely rare.

Not because this transition is particularly unusual.


> We've got three thousand Kconfig options - 
> it is clearly not realistic for users to keep such details in mind to 
> avoid pitfalls.

Agreed -- hence the multiple announcements, including in this thread, to 
put said details into mind.

It's an unusual situation, thus it received announcements so that people 
are aware of the transition taking place, and what to do about it.


> E1000=y && E1000E=m is uncommon but can easily happen. 
> E1000=y && E1000E=m simply makes no sense in light of the PCI ID 
> stealing that occurs if E1000E is enabled.

"makes no sense"...  for your personal situation.

They are two independent drivers, and that's a valid mix of Kconfig 
settings.

Someone could easily have an e1000 card in an e1000e machine, and come 
up with that specific config mix.

It is not denial to say "people other than Ingo might validly choose 
that config mix."



Overall, fundamentally, any transition of a user base from one driver to 
another is going to be an ad-hoc process.  That's the nature of the 
problem -- each case is different.

So we avoid driver transitions if at all possible, as a general rule. 
In this case, a rare exception to that rule, you have to hammer out a 
user-education process as best you can.

	Jeff


