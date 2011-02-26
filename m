From: David Miller <davem@davemloft.net>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Fri, 25 Feb 2011 18:12:44 -0800 (PST)
Message-ID: <20110225.181244.104056532.davem@davemloft.net>
References: <20110225.112019.48513284.davem@davemloft.net>
	<20110226005718.GA19889@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, tgraf@infradead.org, therbert@google.com,
	wsommerfeld@google.com, daniel.baluta@gmail.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51510
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750797Ab1BZCMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 21:12:07 -0500
In-Reply-To: <20110226005718.GA19889@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 26 Feb 2011 08:57:18 +0800

> It isn't all that hard since the easy way would be to only take
> the lock if we're already corked or about to cork.

We take the lock unconditionally because we essentially have to after
UDP takes on the socket buffer accounting facilities similar to TCP.
