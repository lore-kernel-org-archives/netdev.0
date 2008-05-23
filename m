From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: network interface *name* alias support?
Date: Fri, 23 May 2008 16:55:37 -0400
Message-ID: <1211576137.11907.59.camel@perihelion>
References: <alpine.LNX.1.10.0805231817100.25193@fbirervta.pbzchgretzou.qr>
	 <4836FB73.2010709@intel.com>  <4837026A.6000702@hp.com>
	 <1211569604.11907.37.camel@perihelion>
	 <alpine.LNX.1.10.0805232233270.19084@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>, johnathan@jonmasters.org,
	netdev@vger.kernel.org, dwmw2@infradead.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dallas.jonmasters.org ([72.29.103.172]:43953 "EHLO
	dallas.jonmasters.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756116AbYEWUzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 16:55:53 -0400
In-Reply-To: <alpine.LNX.1.10.0805232233270.19084@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-05-23 at 22:46 +0200, Jan Engelhardt wrote:
> On Friday 2008-05-23 21:06, Jon Masters wrote:
> >> > bus-info: 0000:00:19.0
> >> 
> >> And if it happens to be in a hotplug slot today with a suitable hotplug 
> >> module (term?) loaded like acpiphp you can then map that to a more human 
> >> friendly slot number/name.  In the future, once Alex Chiang's pci slots 
> >> patches make it to mainline it will be possible even with non-hotplug slots.
> >
> >Yep, that's all great until the bus topology changes underneath you.
> >There is a need for alias support, because it will allow distributions
> >to assign a name based upon the *slot ordering specified by the vendor*
> >and therefore allow a consistent slot number no matter what hotplug
> >happens, what devices are added or removed, which devices are on-board
> >vs. in cards, and even (eventually) for non-PCI cards.
> >
> >In the case of Fedora, right now, we have files:
> >
> >ifcfg-eth<whatever>
> 
> While it's gone now, openSUSE had support for ifcfg-bus-pci-0000:00:19.0
> in versions prior to 10.3. I suggest you kindly ask they reinstate it
> because with Fedora it is probably not going to happen that they
> bus-pci-.. gets added in the first place.

Yes but *that isn't what I'm talking about* :)

That doesn't infer the physical ordering of the devices on the back of
the machine, does it? How do I know which device is labeled "0" on the
back of the machine, and in the vendor documentation? The answer is,
because they added a DMI extension to tell us this information. So let's
please stop thinking about physical bus ordering and instead view this
as a simple problem of wanting to add an alias based on what the vendor
reports should be the ordering of the devices in the system :)

Jon.


