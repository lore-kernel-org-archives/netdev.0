From: Phil Sutter <phil@nwl.cc>
Subject: Re: ARM, AF_PACKET: caching problems on Marvell Kirkwood
Date: Fri, 6 May 2011 18:17:53 +0200
Message-ID: <20110506161753.GC20777@orbit.nwl.cc>
References: <20110408130643.GA8730@orbit.nwl.cc>
 <20110505141107.GC30443@orbit.nwl.cc>
 <20110505194601.GA10565@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	ne@erfurth.eu, Johann Baudy <johann.baudy@gnu-log.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Nicolas Pitre <nico@fluxnic.net>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.141.167]:56243 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755257Ab1EFQRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2011 12:17:55 -0400
Content-Disposition: inline
In-Reply-To: <20110505194601.GA10565@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, May 05, 2011 at 09:46:01PM +0200, Andrew Lunn wrote:
> I can reproduce it on a Kirkwood:
> 
> [    0.000000] CPU: Feroceon 88FR131 [56251311] revision 1 (ARMv5TE), cr=00053977

Thanks for the information. Seems like we have the same CPU:

| [    0.000000] CPU: Feroceon 88FR131 [56251311] revision 1 (ARMv5TE), cr=00053177
| [    0.000000] CPU: VIVT data cache, VIVT instruction cache

and it's actually VIVT, not VIPT as I wrote in an earlier mail.

Greetings, Phil
