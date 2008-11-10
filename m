From: Michael Buesch <mb@bu3sch.de>
Subject: Re: ssb: Fix DMA-API compilation for non-PCI systems
Date: Tue, 11 Nov 2008 00:32:00 +0100
Message-ID: <200811110032.00814.mb@bu3sch.de>
References: <20081110.135231.96349017.davem@davemloft.net> <200811102307.37838.mb@bu3sch.de> <20081110.145343.171487164.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:37377 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752650AbYKJXcZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2008 18:32:25 -0500
In-Reply-To: <20081110.145343.171487164.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 10 November 2008 23:53:43 David Miller wrote:
> Then those architectures need to fix their implementations,
> simply.  They aren't implementing the generic DMA interfaces
> properly.  Other subsystems do make use of the generic DMA
> interfaces in this way.
> 
> Even something as simple as checking for &pci_bus_type in the
> dma_*() routines (like powerpc did for quite some time) is
> enough to fix the problem.

Yeah, sure. The architectures are broken.
But the bugreports hit _my_ code. I got pretty tired of forwarding stuff
to the arch maintainers, so I implemented something that does work in
every situation. The bugreports stopped immediately (Except this tiny build
failure that does only hit under rare circumstances).

DMA is pretty much a mess, if you look at how ever arch does implement the API
in a slightly different way.
If somebody wants to fix this, I'm certainly OK with it. But for now we will
have to live with SSB implementing a wrapper around the ssb-host-device DMA APIs.

-- 
Greetings Michael.
