From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Tue, 8 Jul 2008 16:48:26 -0700
Message-ID: <20080708164826.2a2d52c2@infradead.org>
References: <4873BC67.8010205@opengridcomputing.com>
	<20080708.143158.182627862.davem@davemloft.net>
	<20080708144725.5b663d19@infradead.org>
	<20080708.145738.12692130.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: swise@opengridcomputing.com, rdreier@cisco.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56061 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753431AbYGHXsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 19:48:38 -0400
In-Reply-To: <20080708.145738.12692130.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 08 Jul 2008 14:57:38 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> What we need instead is to cache the info block into the netdev struct
> when the driver is ->open()'d, and then you can fetch it out of
> there however you like.

but.. isn't that like almost the same as using the object model data at
that point?

> 
> Or, at least, that is one possible approach.

I'll look at it; but this begs the question if this shouldn't turned
inside out.
I mean... if we had a "netdev_set_drivername()" thing with appropriate
arguments (well I suck at names, name it whatever you feel like), we
wouldn't need the drivers to implement each their own ethtool method,
since this could just be done in one place and pull the data from the
netdev.

(for the eeprom etc data that's different, but those are already
different ethtool methods last I looked)


-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
