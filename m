From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] aoe: reserve enough headroom on skbs
Date: Thu, 28 Mar 2013 14:30:54 -0400 (EDT)
Message-ID: <20130328.143054.1501826894226585575.davem@davemloft.net>
References: <alpine.LFD.2.03.1303261852220.8240@linux-mips.org>
	<5153C2E8.6050604@ll.mit.edu>
	<1364444921.15753.32.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daveo@ll.mit.edu, ecashin@coraid.com, macro@linux-mips.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44244 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727Ab3C1Sa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 14:30:56 -0400
In-Reply-To: <1364444921.15753.32.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Mar 2013 21:28:41 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Some network drivers use a non default hard_header_len
> 
> Transmitted skb should take into account dev->hard_header_len, or risk
> crashes or expensive reallocations.
> 
> In the case of aoe, lets reserve MAX_HEADER bytes.
> 
> David reported a crash in defxx driver, solved by this patch.
> 
> Reported-by: David Oostdyk <daveo@ll.mit.edu>
> Tested-by: David Oostdyk <daveo@ll.mit.edu>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
