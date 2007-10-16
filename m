From: David Miller <davem@davemloft.net>
Subject: Re: new NAPI interface broken
Date: Tue, 16 Oct 2007 01:31:46 -0700 (PDT)
Message-ID: <20071016.013146.28785302.davem@davemloft.net>
References: <1192519787.7205.3.camel@pasglop>
	<20071016.004410.85411180.davem@davemloft.net>
	<1192523336.7205.13.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ossthema@de.ibm.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, themann@de.ibm.com, raisch@de.ibm.com,
	arjan@linux.intel.com
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41408
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755977AbXJPIbm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 04:31:42 -0400
In-Reply-To: <1192523336.7205.13.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 16 Oct 2007 18:28:56 +1000

> Allright, so that's an out of tree userland thingy... (which may well
> work on ppc too I suppose). Definitely not installed by default by my
> distro so IRQs from the network cards on all x86's using ubuntu gutsy at
> least are spread to all CPUs :-)

But the thing does treat network interfaces differently from
other devices.

Arjan ran over to my table at kernel summit when I presented this
topic to the audience, to remind me of all of this and he should be
included in on any discussions about this topic. :-)

I've CC:'d him.
