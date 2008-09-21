From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2]: Remote softirq invocation infrastructure.
Date: Sun, 21 Sep 2008 02:17:02 -0700 (PDT)
Message-ID: <20080921.021702.37632261.davem@davemloft.net>
References: <E1KhI4n-0002Fk-7C@gondolin.me.apana.org.au>
	<48D6104B.9040304@superbug.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, dwalker@mvista.com,
	arjan@infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com,
	steffen.klassert@secunet.com
To: James@superbug.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46633
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750733AbYIUJRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 05:17:15 -0400
In-Reply-To: <48D6104B.9040304@superbug.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Courtier-Dutton <James@superbug.co.uk>
Date: Sun, 21 Sep 2008 10:13:47 +0100

> Why do you have to preserve packet ordering?
> TCP/IP does not preserve packet ordering across the network.

Yes, but we should preserve per-flow ordering as much as
possible within the local system for optimal performance.

Things fall apart completely, even with TCP, once you reorder more
than 2 or 3 packets deep.

> Sharing the sliding window between CPUs might be interesting!

Again, Steffen's patches take care of this issue.
