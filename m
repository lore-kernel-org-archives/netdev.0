From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [Cbe-oss-dev] [PATCH 4/10] spidernet: zero out a pointer.
Date: Wed, 23 May 2007 13:23:27 +1000
Message-ID: <1179890607.32247.896.camel@localhost.localdomain>
References: <20070516215605.GA4325@austin.ibm.com>
	 <20070516220928.GD4997@austin.ibm.com>
	 <1179358376.4142.4.camel@concordia.ozlabs.ibm.com>
	 <20070522233517.GU5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>, cbe-oss-dev@ozlabs.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:43608 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755258AbXEWDXx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2007 23:23:53 -0400
In-Reply-To: <20070522233517.GU5921@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Here's a delusional reply: I didn't see any point to it. 
> 1) a wmb would add overhead
> 2) the hardware is supposed to be looking at the status flag,
>    anyway, and not misbehaving.
> 3) there is a wmb when the descr is actually refilled in such
>    a way as to actually mean something to the hardware.
> 
> All that I really acomplished here is a minor trick to 
> aid in debug printing when looking for something bad.

And the whole thing is moot because 0 is actually a perfectly valid DMA
address :-) I suspect spider will end up trying to hit some internal
register or it's PCIe or whatever it has mapped at 0 internally and will
blow up ... At least on spider, it's not RAM there....

Ben.


