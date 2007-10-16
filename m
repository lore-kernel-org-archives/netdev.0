From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: new NAPI interface broken
Date: Tue, 16 Oct 2007 19:01:49 +1000
Message-ID: <1192525309.7205.16.camel@pasglop>
References: <1192519787.7205.3.camel@pasglop>
	 <20071016.004410.85411180.davem@davemloft.net>
	 <1192523336.7205.13.camel@pasglop>
	 <20071016.013146.28785302.davem@davemloft.net>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ossthema@de.ibm.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, themann@de.ibm.com, raisch@de.ibm.com,
	arjan@linux.intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:47982 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752289AbXJPJCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 05:02:04 -0400
In-Reply-To: <20071016.013146.28785302.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 2007-10-16 at 01:31 -0700, David Miller wrote:
> From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date: Tue, 16 Oct 2007 18:28:56 +1000
> 
> > Allright, so that's an out of tree userland thingy... (which may well
> > work on ppc too I suppose). Definitely not installed by default by my
> > distro so IRQs from the network cards on all x86's using ubuntu gutsy at
> > least are spread to all CPUs :-)
> 
> But the thing does treat network interfaces differently from
> other devices.
> 
> Arjan ran over to my table at kernel summit when I presented this
> topic to the audience, to remind me of all of this and he should be
> included in on any discussions about this topic. :-)
> 
> I've CC:'d him.

As far as I know, the x86 in-kernel thingy doesn't but yeah, the
userland one seems much more evolved and does things based on the
"class" of the device.

Christoph, have any of you tried it on powerpc ?

Cheers,
Ben.


