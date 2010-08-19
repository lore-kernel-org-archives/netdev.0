From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] slip: fix get_stats() method
Date: Thu, 19 Aug 2010 00:17:56 -0700 (PDT)
Message-ID: <20100819.001756.43029083.davem@davemloft.net>
References: <1282137188.2194.74.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38224
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751018Ab0HSHRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 03:17:37 -0400
In-Reply-To: <1282137188.2194.74.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Aug 2010 15:13:08 +0200

> Use integrated net_device_stats instead of a static one, and make sure
> no transient values are feeded. ndo_get_stats() can be called by
> concurrent cpus.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.

It's pretty freaky how, even to this day, we keep finding these static
function local variables in code which potentially runs multithreaded.
