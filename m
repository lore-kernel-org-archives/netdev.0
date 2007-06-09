From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Sat, 09 Jun 2007 18:14:04 -0400
Message-ID: <466B262C.6000109@garzik.org>
References: <1181168020.4064.46.camel@localhost> <D5C1322C3E673F459512FB59E0DDC32902FC61BF@orsmsx414.amr.corp.intel.com> <78C9135A3D2ECE4B8162EBDCE82CAD7701B7D69C@nekter> <1181417000.4043.34.camel@localhost> <78C9135A3D2ECE4B8162EBDCE82CAD7701B7D6BC@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	netdev@vger.kernel.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Alex Aizman <aaizman@neterion.com>
To: Leonid Grossman <Leonid.Grossman@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35092 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753001AbXFIWRY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2007 18:17:24 -0400
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7701B7D6BC@nekter>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Leonid Grossman wrote:
> But my point was that while virtualization capabilities of upcoming NICs
> may be not even relevant to Linux, the multi-channel hw designs (a side
> effect of virtualization push, if you will) will be there and a
> non-virtualized stack can take advantage of them.


I'm looking at the current hardware virtualization efforts, and often 
grimacing.  A lot of these efforts assume that "virtual PCI devices" 
will be wonderful virtualization solutions, without stopping to think 
about global events that affect all such devices, such as silicon resets 
or errata workarounds.  In the real world, you wind up having to 
un-virtualize to deal with certain exceptional events.

But as you point out, these hardware virt efforts can bestow benefits on 
non-virtualized stacks.

	Jeff
