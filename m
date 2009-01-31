From: Parag Warudkar <parag.lkml@gmail.com>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Fri, 30 Jan 2009 21:40:15 -0500 (EST)
Message-ID: <alpine.DEB.2.00.0901302136470.5643@parag-desktop>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901310059.17746.rjw@sisk.pl> <alpine.DEB.2.00.0901301924550.5056@parag-desktop> <200901310138.51214.rjw@sisk.pl> <alpine.DEB.2.00.0901302016170.5643@parag-desktop>
 <alpine.LFD.2.00.0901301741380.3150@localhost.localdomain> <alpine.DEB.2.00.0901302051390.5643@parag-desktop> <alpine.LFD.2.00.0901301820080.3150@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.247]:29590 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751839AbZAaCkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 21:40:22 -0500
In-Reply-To: <alpine.LFD.2.00.0901301820080.3150@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 30 Jan 2009, Linus Torvalds wrote:

> If you can try the patch I just sent out, and use that as a base for 
> trying to track down why the heck the legacy code doesn't work, that would 
> be great. It might fix it (assuming my guess about "restore_state while in 
> PCI_D3 doesn't work" was correct), but quite frankly, it's equally 
> possible that it just makes things worse. But it would be really 
> interesting to hear..

Sure - will do.

> 
> Your machine does seem to be interesting, in that not only does it have a 
> PCI-E bridge in it (the eeepc I was playing around with at LCA does not), 
> but judging by the lost config state I also suspect that it actually loses 
> power during STR.

Not sure what the significance of eeepc is in this case - mine being a 
standard Intel 5400 chipset I would have thought that's the last 
place to look for interesting things!
 
> Which is not at all necessarily a given - I suspect it depends on just how 
> the power rails are set up on the motherboard. The fact that PCI-E bridges 
> have apparently worked for others implies that your problems don't happen 
> for everybody, and may relate to that issue.

Do we know this for sure that PCI-E bridges + Suspend have worked for 
others - In this thread at least I think people reported tg3 worked but not 
necessarily with a PCI-E bridge.

Parag
