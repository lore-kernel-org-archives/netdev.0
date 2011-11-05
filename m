From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: pppol2tp over pppoe NULL pointer dereference
Date: Fri, 04 Nov 2011 22:28:51 -0400 (EDT)
Message-ID: <20111104.222851.1376278499619626232.davem@davemloft.net>
References: <CAKpUy7Z5KOfHbKfBp-qg+77cED=OxUAkm2P4pQacHaHKmKBQpw@mail.gmail.com>
	<1320191893.4728.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: spiked.yar@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962Ab1KEC2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 22:28:54 -0400
In-Reply-To: <1320191893.4728.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Nov 2011 00:58:13 +0100

> Please try following patch, thanks !
> 
> [PATCH] l2tp: handle fragmented skbs in receive path
> 
> Modern drivers provide skb with fragments, and L2TP doesnt properly
> handles them.
> 
> Some bad frames can also trigger panics because of insufficent checks.
> 
> Reported-by: Misha Labjuk <spiked.yar@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I'm still waiting for testing results of this patch.
