From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [regression] e1000e broke e1000
Date: Fri, 11 Apr 2008 10:59:07 +0200
Message-ID: <20080411085907.GA10801@elte.hu>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu> <47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu> <20080408193245.GG11962@parisc-linux.org> <20080408195123.GA28148@elte.hu> <47FD64B5.1050309@tmr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <matthew@wil.cx>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	NetDev <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	Greg KH <greg@kroah.com>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Bill Davidsen <davidsen@tmr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:57582 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759588AbYDKI7o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 04:59:44 -0400
Content-Disposition: inline
In-Reply-To: <47FD64B5.1050309@tmr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Bill Davidsen <davidsen@tmr.com> wrote:

>> the solution is rather straightforward: if E1000 is built-in then 
>> E1000E should be built-in as well or disabled (i.e. it should not be 
>> possible to build it as a module in that case) - because the PCI ID 
>> stealing trick now connects the two drivers unconditionally. [ If 
>> e1000 is a module then e1000e can be a module (or disabled) - this 
>> would be the most common configuration. ]
>
> And this would seem to break the most common means of testing a new 
> driver for existing (and working!) hardware, which is to build both 
> drivers as modules, install the new one, and if it appears to have 
> problems either remove and insert the old driver by hand, or boot 
> forcing the old driver.
>
> I can't be the only person who tests kernels on machines I wouldn't 
> use to build a kernel, and uses modprobe.conf to test new driver 
> functionality.

yes, but note that the breakage you are talking about is not caused my 
patch, it is caused by the planned change to remove those PCI IDs from 
e1000.

my suggested change only solves part of the more general problem you 
touch upon. (and it does not make it worse in any way)

	Ingo
