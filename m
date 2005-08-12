From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Strange uses of netif_start_queue
Date: Fri, 12 Aug 2005 11:03:20 -0700 (PDT)
Message-ID: <20050812.110320.97292810.davem@davemloft.net>
References: <1123853714.22460.39.camel@localhost.localdomain>
	<20050812132758.GE2819@linux-mips.org>
	<20050812133905.GF2819@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ralf@linux-mips.org
In-Reply-To: <20050812133905.GF2819@linux-mips.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Fri, 12 Aug 2005 14:39:05 +0100

> To answer the fundamental question, I think netif_start_queue /
> netif_stop_queue should be allowed in case the driver for some reason has
> the desire to stop queueing of packet immediately after register_netdev.

I disagree.  register_netdev() does not make packets start getting
queued, you have to up the interface for that to start occuring.
And your ->open() routine has full control over that.
