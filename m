From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: new NAPI interface broken
Date: Tue, 16 Oct 2007 18:28:56 +1000
Message-ID: <1192523336.7205.13.camel@pasglop>
References: <200709071137.02801.ossthema@de.ibm.com>
	 <20070912.055004.88490155.davem@davemloft.net>
	 <1192519787.7205.3.camel@pasglop>
	 <20071016.004410.85411180.davem@davemloft.net>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ossthema@de.ibm.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, themann@de.ibm.com, raisch@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:58603 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763381AbXJPI3O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 04:29:14 -0400
In-Reply-To: <20071016.004410.85411180.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 2007-10-16 at 00:44 -0700, David Miller wrote:
> From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date: Tue, 16 Oct 2007 17:29:47 +1000
> 
> > Do you have any pointer to how that is done on x86 or sparc64 ?
> 
> Sparc64 does it statically in the kernel.
> 
> For x86, see http://irqbalance.org/

Allright, so that's an out of tree userland thingy... (which may well
work on ppc too I suppose). Definitely not installed by default by my
distro so IRQs from the network cards on all x86's using ubuntu gutsy at
least are spread to all CPUs :-)

There's also a balance kernel thread in x86 with has a notion of irq
that isn't moveable but that flag isn't set by any driver.

Cheers,
Ben.



