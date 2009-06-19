From: David Miller <davem@davemloft.net>
Subject: Re: can we reuse an skb
Date: Fri, 19 Jun 2009 16:29:57 -0700 (PDT)
Message-ID: <20090619.162957.156347025.davem@davemloft.net>
References: <962874.62146.qm@web94813.mail.in2.yahoo.com>
	<4A3BC326.4090203@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: radhamohan_ch@yahoo.com, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56301
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752257AbZFSX3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 19:29:53 -0400
In-Reply-To: <4A3BC326.4090203@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 19 Jun 2009 09:56:06 -0700

> Assuming a driver did have its own "pool" and didn't rely on the
> pool(s) from which skbs are drawn, doesn't that mean you have to now
> have another configuable?  There is no good guarantees on when the
> upper layers will be finished with the skb right?  Which means you
> would be requiring the admin(s) to have an idea of how long their
> applications wait to pull data from their sockets and configure your
> driver accordingly.
> 
> It would seem there would have to be a considerable performance gain
> demonstrated for that kind of thing?

Applications can hold onto such data "forever" if they want to.

Any scheme which doesn't allow dynamically increasing the pool
is prone to trivial DoS.
