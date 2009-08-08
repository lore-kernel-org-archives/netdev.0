From: Bill Fink <billfink@mindspring.com>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Fri, 7 Aug 2009 21:35:57 -0400
Message-ID: <20090807213557.d0faec23.billfink@mindspring.com>
References: <20090807170600.9a2eff2e.billfink@mindspring.com>
	<4A7C9A14.7070600@inria.fr>
	<20090807175112.a1f57407.billfink@mindspring.com>
	<4A7CCEFC.7020308@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brice Goglin <Brice.Goglin@inria.fr>,
	Linux Network Developers <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:60708 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754213AbZHHBf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 21:35:58 -0400
In-Reply-To: <4A7CCEFC.7020308@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 07 Aug 2009, Andrew Gallatin wrote:

> Bill Fink wrote:
> 
> > All sysfs local_cpus values are the same (00000000,000000ff),
> > so yes they are also wrong.
> 
> How were you handling IRQ binding?  If local_cpus is wrong,
> the irqbalance will not be able to make good decisions about
> where to bind the NICs' IRQs.  Did you try manually binding
> each NICs's interrupt to a separate CPU on the correct node?

Yes, all the NIC IRQs were bound to a CPU on the local NUMA node,
and the nuttcp application had its CPU affinity set to the same
CPU with its memory affinity bound to the same local NUMA node.
And the irqbalance daemon wasn't running.

						-Thanks

						-Bill
