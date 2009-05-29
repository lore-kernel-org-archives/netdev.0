From: David Miller <davem@davemloft.net>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/5] netdev: bfin_mac: Blackfin
 EMAC interrupt may not be shared
Date: Fri, 29 May 2009 15:18:16 -0700 (PDT)
Message-ID: <20090529.151816.232829085.davem@davemloft.net>
References: <8bd0f97a0905290445x3b0829f3h657fec534f290c7f@mail.gmail.com>
	<20090529.150928.239765896.davem@davemloft.net>
	<8bd0f97a0905291513m780898e9j6bd4c0b3b9ae8528@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Michael.Hennerich@analog.com, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
To: vapier.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47152
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754229AbZE2WSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 18:18:16 -0400
In-Reply-To: <8bd0f97a0905291513m780898e9j6bd4c0b3b9ae8528@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier.adi@gmail.com>
Date: Fri, 29 May 2009 18:13:02 -0400

> the difference is that one of these is required in order for anything
> to get done and the other is always useless noise.  also, the Blackfin
> core does do speculative data fetching on external memory, but not
> MMRs, so the stalling due to the data cache line fills will be
> mitigated unlike the useless MMR reads.

You only need to read the register if the descriptor status is not
ready yet, and you're just spinning in that case anyways.

I doubt it makes any real difference if implemented properly.

But I guess it's more fun to speculate than to actually try it out.
:-/
