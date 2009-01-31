From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Sat, 31 Jan 2009 19:51:28 +0100
Message-ID: <200901311951.29677.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <alpine.LFD.2.00.0901301820080.3150@localhost.localdomain> <alpine.DEB.2.00.0901302136470.5643@parag-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Parag Warudkar <parag.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:54113 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751508AbZAaSwM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jan 2009 13:52:12 -0500
In-Reply-To: <alpine.DEB.2.00.0901302136470.5643@parag-desktop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 31 January 2009, Parag Warudkar wrote:
> 
> On Fri, 30 Jan 2009, Linus Torvalds wrote:
> 
> > If you can try the patch I just sent out, and use that as a base for 
> > trying to track down why the heck the legacy code doesn't work, that would 
> > be great. It might fix it (assuming my guess about "restore_state while in 
> > PCI_D3 doesn't work" was correct), but quite frankly, it's equally 
> > possible that it just makes things worse. But it would be really 
> > interesting to hear..
> 
> Sure - will do.
> 
> > 
> > Your machine does seem to be interesting, in that not only does it have a 
> > PCI-E bridge in it (the eeepc I was playing around with at LCA does not), 
> > but judging by the lost config state I also suspect that it actually loses 
> > power during STR.
> 
> Not sure what the significance of eeepc is in this case - mine being a 
> standard Intel 5400 chipset I would have thought that's the last 
> place to look for interesting things!
>  
> > Which is not at all necessarily a given - I suspect it depends on just how 
> > the power rails are set up on the motherboard. The fact that PCI-E bridges 
> > have apparently worked for others implies that your problems don't happen 
> > for everybody, and may relate to that issue.
> 
> Do we know this for sure that PCI-E bridges + Suspend have worked for 
> others - In this thread at least I think people reported tg3 worked but not 
> necessarily with a PCI-E bridge.

Technically, they are PCIe root ports and many systems have network adapters
connected through them (I have two such systems here, but none of them with
tg3-compatible hardware - my tg3 is a PCI device).

Thanks,
Rafael
