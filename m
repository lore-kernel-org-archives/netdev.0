From: David Miller <davem@davemloft.net>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 12 Nov 2008 01:49:23 -0800 (PST)
Message-ID: <20081112.014923.68124784.davem@davemloft.net>
References: <20081111.155041.90523159.davem@davemloft.net>
	<20081111.161849.251632080.davem@davemloft.net>
	<1226482593.6834.43.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper@krogh.cc, netdev@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34165
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751420AbYKLJta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 04:49:30 -0500
In-Reply-To: <1226482593.6834.43.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <jdb@comx.dk>
Date: Wed, 12 Nov 2008 10:36:33 +0100

> The thing I noticed is that it looks like the function niu_tx_work() is
> never called... (it contains a niudbg(TX_DONE, ...))

That means no interrupts are arriving at all for TX.

Oddly, you tried without MSI enabled (do I remember right ?) and that
still failed, so it doesn't seem like it could be a MSI specific
problem.

Get the dump from the patch I sent and I should be able to have some
idea why this problem might be happening.

Thanks.
