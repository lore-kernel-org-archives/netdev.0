From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] gro: __napi_gro_receive() optimizations
Date: Thu, 26 Aug 2010 00:51:39 -0700 (PDT)
Message-ID: <20100826.005139.183034040.davem@davemloft.net>
References: <1282768431.2681.144.camel@edumazet-laptop>
	<20100825.135726.189708768.davem@davemloft.net>
	<1282770911.2681.205.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35668
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751621Ab0HZHvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 03:51:23 -0400
In-Reply-To: <1282770911.2681.205.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Aug 2010 23:15:11 +0200

> Yes, we can inline it, this will speedup the non vlan case as well :)

Agreed.

But I believe you can find a better place to put __napi_gro_receive()
than etherdevice.h, even though yes it does have a hard dependency on
that thing. :-)

