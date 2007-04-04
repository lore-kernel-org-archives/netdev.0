From: "Denys" <denys@visp.net.lb>
Subject: Re: 2.6.20.4: NETDEV WATCHDOG and lockups
Date: Wed, 4 Apr 2007 16:53:59 +0300
Message-ID: <20070404135259.M91581@visp.net.lb>
References: <20070403065810.GA1832@ff.dom.local> <Pine.LNX.4.64.0704031618070.3963@sheep.housecafe.de> <20070404112100.GA1979@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	malte@g-house.de, Francois Romieu <romieu@fr.zoreil.com>
To: Jarek Poplawski <jarkao2@o2.pl>,
	Christian Kujau <christian@g-house.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:38540 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753891AbXDDOfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2007 10:35:52 -0400
In-Reply-To: <20070404112100.GA1979@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IMHO it can be hardware issue also, i had something very similar with faulty 
hardware combinations.

On Wed, 4 Apr 2007 13:21:00 +0200, Jarek Poplawski wrote
> On Tue, Apr 03, 2007 at 04:19:46PM +0100, Christian Kujau wrote:
> > On Tue, 3 Apr 2007, Jarek Poplawski wrote:
> > >Did you try with 8139cp instead of 8139too?
> > 
> > Tried that, 8139cp could not be loaded :(
> 
> Sorry for misleading!
> 
> > >(Maybe even try some other card to narrow the problem?)
> > >You could also try to test without ehci, if it's possible.
> > 
> > USB has been disabled completely. After booting with 'acpi=off lapic' 
> > the box survived ~30min then locked up again and rebooted.
> 
> So, it's a lot sooner than before. (BTW, isn't there anything
> in debug log?) I see both CPUs did interrupt handling again.
> Maybe it's a real locking problem. Here are some more
> suggestions for testing (if you don't find anything better):
> - try without SMP, so: 'acpi=off lapic nosmp'
> - lock debugging turned on as much as possible
> plus maybe for curiosity:
> - different CONFIG_HZ
> - 8139TOO_PIO = y
> 
> ....
> > IRQ-problems with the Un-Interruptible-Power-Supply
> 
> I wouldn't be surprised...
> 
> Cheers,
> Jarek P.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

