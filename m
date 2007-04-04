From: Christian Kujau <christian@g-house.de>
Subject: Re: 2.6.20.4: NETDEV WATCHDOG and lockups
Date: Wed, 4 Apr 2007 14:20:23 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0704041412310.3963@sheep.housecafe.de>
References: <20070403065810.GA1832@ff.dom.local>
 <Pine.LNX.4.64.0704031618070.3963@sheep.housecafe.de> <20070404112100.GA1979@ff.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Christian Kujau <christian@g-house.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	malte@g-house.de, Francois Romieu <romieu@fr.zoreil.com>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.g-housing.de ([81.169.133.75]:58907 "EHLO mail.g-house.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753781AbXDDNUb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2007 09:20:31 -0400
In-Reply-To: <20070404112100.GA1979@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Apr 2007, Jarek Poplawski wrote:
> So, it's a lot sooner than before. (BTW, isn't there anything
> in debug log?)

No, nothing. I've set up remote-syslgging to the other node (node1 
logging to node2 and vice versa) - nothing :(

> I see both CPUs did interrupt handling again.

Yes, when booting with 'lapic' both CPUs/cores are handling interrupts 
again. However, since 'lapic' seems to lead to crashes here, we would be 
more than happy to just boot with 'noapic' but have 'irqbalance' 
working. Unfortunately, irqbalance is unable to write to 
/proc/irq/*/smp_affinity (did not help to disable CONFIG_IRQBALANCE).

> Maybe it's a real locking problem. Here are some more
> suggestions for testing (if you don't find anything better):
> - try without SMP, so: 'acpi=off lapic nosmp'

Yeah, we'll see if we still have time for trying this. But I figure this 
will not be a real (long term) option for us :(

> - lock debugging turned on as much as possible
>   plus maybe for curiosity:
> - different CONFIG_HZ > - 8139TOO_PIO = y

Indeed, that's what I too wanted to do.

@Malte: any plans for another downtime?

Thanks for your comments!

Christian.
-- 
BOFH excuse #265:

The mouse escaped.
