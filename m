From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20.4: NETDEV WATCHDOG and lockups
Date: Thu, 5 Apr 2007 08:20:00 +0200
Message-ID: <20070405062000.GA1717@ff.dom.local>
References: <20070403065810.GA1832@ff.dom.local> <Pine.LNX.4.64.0704031618070.3963@sheep.housecafe.de> <20070404112100.GA1979@ff.dom.local> <Pine.LNX.4.64.0704041412310.3963@sheep.housecafe.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	malte@g-house.de, Francois Romieu <romieu@fr.zoreil.com>
To: Christian Kujau <christian@g-house.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:42345 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161216AbXDEGO7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 02:14:59 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704041412310.3963@sheep.housecafe.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 04, 2007 at 02:20:23PM +0100, Christian Kujau wrote:
> On Wed, 4 Apr 2007, Jarek Poplawski wrote:
> >So, it's a lot sooner than before. (BTW, isn't there anything
> >in debug log?)
> 
> No, nothing. I've set up remote-syslgging to the other node (node1 
> logging to node2 and vice versa) - nothing :(
> 
> >I see both CPUs did interrupt handling again.
> 
> Yes, when booting with 'lapic' both CPUs/cores are handling interrupts 
> again. However, since 'lapic' seems to lead to crashes here, we would be 
> more than happy to just boot with 'noapic' but have 'irqbalance' 
> working. Unfortunately, irqbalance is unable to write to 
> /proc/irq/*/smp_affinity (did not help to disable CONFIG_IRQBALANCE).

I hope you are right, but maybe it's not lapic's fault?
Probably the fastest way to know would be to try with
some other card, yet.

> >Maybe it's a real locking problem. Here are some more
> >suggestions for testing (if you don't find anything better):
> >- try without SMP, so: 'acpi=off lapic nosmp'

BTW, I'm not sure acpi should be turned off with any
modern hardware. Did you tried to compile with
CONFIG_ACPI = y, all other acpi options off, and maybe
to tweak only with 'pci=...' boot parameter?

Regards,
Jarek P.
