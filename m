From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: e1000 performance issue in 4 simultaneous links
Date: Sat, 12 Jan 2008 07:13:06 +0200
Message-ID: <20080112050841.M73900@visp.net.lb>
References: <36D9DB17C6DE9E40B059440DB8D95F5204275B04@orsmsx418.amr.corp.intel.com> <20080110.172830.16409182.davem@davemloft.net> <m3ir20ipoz.fsf@ursa.amorsen.dk> <20080111.174109.57502326.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, benny+usenet@amorsen.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:59375 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783AbYALFNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 00:13:15 -0500
In-Reply-To: <20080111.174109.57502326.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry. that i interfere in this subject.

Do you recommend CONFIG_IRQBALANCE to be enabled?

If it is enabled - irq's not jumping nonstop over processors. softirqd 
changing this behavior.
If it is disabled, irq's distributed over each processor, and in loaded 
systems it seems harmful. 
I work a little yesterday with server with CONFIG_IRQBALANCE=no, 160kpps load.
It was packetloss-ing, till i set smp_affinity.

Maybe it is useful to put more info in Kconfig, since it is very important 
for performance option.

On Fri, 11 Jan 2008 17:41:09 -0800 (PST), David Miller wrote
> From: Benny Amorsen <benny usenet@amorsen.dk>
> Date: Fri, 11 Jan 2008 12:09:32  0100
> 
> > David Miller <davem@davemloft.net> writes:
> > 
> > > No IRQ balancing should be done at all for networking device
> > > interrupts, with zero exceptions.  It destroys performance.
> > 
> > Does irqbalanced need to be taught about this?
> 
> The userland one already does.
> 
> It's only the in-kernel IRQ load balancing for these (presumably
> powerpc) platforms that is broken.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

