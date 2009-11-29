From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] pktgen: NUMA aware
Date: Sun, 29 Nov 2009 00:44:47 -0800 (PST)
Message-ID: <20091129.004447.101479327.davem@davemloft.net>
References: <4B0D46AE.3070700@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andi@firstfloor.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43474
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754149AbZK2Iom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 03:44:42 -0500
In-Reply-To: <4B0D46AE.3070700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Nov 2009 16:01:02 +0100

> [PATCH net-next-2.6] pktgen: NUMA aware
> 
> pktgen threads are bound to given CPU, we can allocate memory for
> these threads in a NUMA aware way.
> 
> After a pktgen session on two threads, we can check flows memory was
> allocated on right node, instead of a not related one.
> 
> # grep pktgen_thread_write /proc/vmallocinfo 
> 0xffffc90007204000-0xffffc90007385000 1576960 pktgen_thread_write+0x3a4/0x6b0 [pktgen] pages=384 vmalloc N0=384
> 0xffffc90007386000-0xffffc90007507000 1576960 pktgen_thread_write+0x3a4/0x6b0 [pktgen] pages=384 vmalloc N1=384
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
