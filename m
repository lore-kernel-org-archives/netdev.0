From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [regression] e1000e broke e1000
Date: Tue, 8 Apr 2008 14:20:04 -0600
Message-ID: <20080408202003.GJ11962@parisc-linux.org>
References: <47F69965.7030303@intel.com> <20080408083606.GA20863@elte.hu> <47FB9ABB.9080403@intel.com> <20080408183921.GA20803@elte.hu> <36D9DB17C6DE9E40B059440DB8D95F5204E2A55C@orsmsx418.amr.corp.intel.com> <20080408195949.GB28148@elte.hu> <20080408200417.GI11962@parisc-linux.org> <47FBD1AD.1080700@isomerica.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	e1000-list <e1000-devel@lists.sourceforge.net>,
	linux-pci maillist <linux-pci@atrey.karlin.mff.cuni.cz>,
	Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	Greg KH <greg@kroah.com>,
	Arjan van de Ven <arjan@linux.intel.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Dan Noe <dpn@isomerica.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:37949 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbYDHUUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 16:20:21 -0400
Content-Disposition: inline
In-Reply-To: <47FBD1AD.1080700@isomerica.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 08, 2008 at 04:12:29PM -0400, Dan Noe wrote:
> It would be nice if lspci could display what driver had claimed a 
> particular device

You need to upgrade to a more recent version of lspci -- it already does
this ;-)

Maybe 'status' would be a better name than 'broken'.  We could even
default it to 'unclaimed' then.  Or 'driver_status' to avoid conflicting
with some bus that might have a 'status' bit we try to report through
sysfs.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
