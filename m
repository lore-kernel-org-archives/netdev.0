From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: network interface *name* alias support?
Date: Fri, 23 May 2008 22:46:45 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0805232233270.19084@fbirervta.pbzchgretzou.qr>
References: <alpine.LNX.1.10.0805231817100.25193@fbirervta.pbzchgretzou.qr>  <4836FB73.2010709@intel.com>  <4837026A.6000702@hp.com> <1211569604.11907.37.camel@perihelion>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Rick Jones <rick.jones2@hp.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>, johnathan@jonmasters.org,
	netdev@vger.kernel.org, dwmw2@infradead.org
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:42016 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758476AbYEWUqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 16:46:47 -0400
In-Reply-To: <1211569604.11907.37.camel@perihelion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Friday 2008-05-23 21:06, Jon Masters wrote:
>> > bus-info: 0000:00:19.0
>> 
>> And if it happens to be in a hotplug slot today with a suitable hotplug 
>> module (term?) loaded like acpiphp you can then map that to a more human 
>> friendly slot number/name.  In the future, once Alex Chiang's pci slots 
>> patches make it to mainline it will be possible even with non-hotplug slots.
>
>Yep, that's all great until the bus topology changes underneath you.
>There is a need for alias support, because it will allow distributions
>to assign a name based upon the *slot ordering specified by the vendor*
>and therefore allow a consistent slot number no matter what hotplug
>happens, what devices are added or removed, which devices are on-board
>vs. in cards, and even (eventually) for non-PCI cards.
>
>In the case of Fedora, right now, we have files:
>
>ifcfg-eth<whatever>

While it's gone now, openSUSE had support for ifcfg-bus-pci-0000:00:19.0
in versions prior to 10.3. I suggest you kindly ask they reinstate it
because with Fedora it is probably not going to happen that they
bus-pci-.. gets added in the first place.

