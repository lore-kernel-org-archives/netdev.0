From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [ANNOUNCE] e1000 to e1000e migration of PCI Express devices
Date: Tue, 08 Apr 2008 10:21:39 -0400
Message-ID: <47FB7F73.9020502@garzik.org>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
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
Received: from srv5.dvmed.net ([207.36.208.214]:42392 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752495AbYDHOVu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 10:21:50 -0400
In-Reply-To: <20080408083606.GA20863@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> ( sidenote: isnt there some facility that selects the "better" driver in 
>   case there is an overlap between PCI IDs - with the ability for users 
>   to override that selection? )


No.

Multiple PCI IDs in the same driver creates all sorts of problems, 
because it becomes an ambiguious selection where automated tools cannot 
make a choice for you.

Each one typically requires special case code in relevant distro 
installers, hardware detectors, and similar gadgets, since the normal 
modules.pcimap stuff doesn't work due to the duplicate IDs.

We have no way to export which is the "preferred" driver -- and indeed 
in many cases, that's an impossible task, since the "preferred" driver 
for a user sometimes depends on the hardware's programmed mode rather 
than just a choice.

	Jeff



