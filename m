From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] codel: use Newton method instead of sqrt()
 and divides
Date: Sat, 12 May 2012 16:45:13 -0400 (EDT)
Message-ID: <20120512.164513.1156706853054390966.davem@davemloft.net>
References: <1336829533.31653.1108.camel@edumazet-glaptop>
	<20120512.155259.1178343836887150194.davem@davemloft.net>
	<1336855256.31653.1329.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave.taht@bufferbloat.net, netdev@vger.kernel.org,
	nichols@pollere.com, van@pollere.net, codel@lists.bufferbloat.net,
	ycheng@google.com, mattmathis@google.com, therbert@google.com,
	shemminger@vyatta.com, nanditad@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756033Ab2ELUrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2012 16:47:19 -0400
In-Reply-To: <1336855256.31653.1329.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 12 May 2012 22:40:56 +0200

> 24 bit of precision for the reciprocal value is more than enough (Van
> suggested 16 bits in fact), so we have actually room for 7 bits if
> needed.

Using a u16 would also work for me.

> By the way, gcc on x86 generates nice "and 0xfffffffe,%eax" instruction
> for (vars->rec_inv_sqrt << 1).

Yeah but what do stores of ->rec_inv_sqrt look like?
